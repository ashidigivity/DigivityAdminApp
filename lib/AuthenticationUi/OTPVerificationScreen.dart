import 'dart:async';
import 'package:digivity_admin_app/AdminPanel/Components/PopupNetworkImage.dart';
import 'package:digivity_admin_app/Authentication/LoginService.dart';
import 'package:digivity_admin_app/Authentication/SharedPrefHelper.dart';
import 'package:digivity_admin_app/AuthenticationUi/Loader.dart';
import 'package:digivity_admin_app/AuthenticationUi/PasswordInputField.dart';
import 'package:digivity_admin_app/AuthenticationUi/ResponsiveUserCard.dart';
import 'package:digivity_admin_app/Components/ApiMessageWidget.dart';
import 'package:digivity_admin_app/Components/BouncingBubble.dart';
import 'package:digivity_admin_app/Helpers/DeviceToken.dart';
import 'package:digivity_admin_app/Helpers/getApiService.dart';
import 'package:digivity_admin_app/Helpers/otphelperForLoginUi.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OTPOrPasswordScreen extends StatefulWidget {
  final Map<String, dynamic> schoolData;
  final Map<String, dynamic> userInfomation;
  final String loginMode;
  final String? username;

  const OTPOrPasswordScreen({
    super.key,
    required this.schoolData,
    required this.userInfomation,
    required this.loginMode,
    this.username,
  });

  @override
  State<OTPOrPasswordScreen> createState() => _OTPOrPasswordScreenState();
}

class _OTPOrPasswordScreenState extends State<OTPOrPasswordScreen> {
  late bool _isPasswordLogin;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  int? _lastExpireTime;
  int? _lastResendTime;

  late OtpHelperForLoginUi _otpHelper;

  // OTP Timer
  bool _isResendEnabled = false;
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  bool _timersInitialized = false;

  @override
  void initState() {
    super.initState();
    _otpHelper = OtpHelperForLoginUi();
    _isPasswordLogin = widget.loginMode == 'password';

    if (!_isPasswordLogin && !_timersInitialized) {
      _timersInitialized = true;

      _lastResendTime = widget.userInfomation["success"]["timetoresend"] ?? 60;
      _lastExpireTime =
          widget.userInfomation["success"]["otpExpireeTime"] ?? 300;

      _otpHelper.startResendTimer(
        totalSeconds: _lastResendTime!,
        onTick: () => setState(() {}),
        onComplete: () => setState(() {}),
      );

      _otpHelper.startExpireTimer(
        totalSeconds: _lastExpireTime!,
        onTick: () => setState(() {}),
        onExpire: () => setState(() {}),
      );
    }
  }

  Future<void> resendOtp(String ResendOtp) async {
    showLoaderDialog(context, message: "Please Wait To ReSend OTP ");
    try {
      final url =
          '${widget.schoolData['base_url']}/api/MobileApp/ResendOtp/$ResendOtp';
      final data = await getApiService.sendOtp(url);

      if (data["result"] == 1 && data["message"] is String) {
        showBottomMessage(context, "${data["message"]}", false);
        _otpHelper.cancelTimers();
        _otpHelper = OtpHelperForLoginUi();

        _lastResendTime = data["success"]["timetoresend"] ?? 60;
        _lastExpireTime = data["success"]["otpExpireeTime"] ?? 300;
        _otpHelper.startResendTimer(
          totalSeconds: _lastResendTime!,
          onTick: () => setState(() {}),
          onComplete: () => setState(() {}),
        );
        _otpHelper.startExpireTimer(
          totalSeconds: _lastExpireTime!,
          onTick: () => setState(() {}),
          onExpire: () => setState(() {}),
        );
        setState(() {});
      } else {
        showBottomMessage(context, "${data["message"]}", true);
      }
    } catch (e) {
      showBottomMessage(context, "$e", true);
    } finally {
      hideLoaderDialog(context);
    }
  }

  @override
  void dispose() {
    _otpHelper.cancelTimers();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool otpDisabled = widget.loginMode == 'password';
    final user = widget.userInfomation['success'];
    final height = MediaQuery.of(context).size.height;

    Future<void> _handleLogin() async {
      final service = LoginService();

      if (_passwordController.text.isEmpty && widget.loginMode == 'password') {
        if (mounted) showBottomMessage(context, "Please Enter Password", true);
        return;
      } else if (_otpController.text.isEmpty && widget.loginMode == 'otp') {
        if (mounted) showBottomMessage(context, "Please Enter OTP", true);
        return;
      }

      setState(() => _isLoading = true);
      showLoaderDialog(context, message: "Fetching data...");

      try {
        Map<String, dynamic> data;

        if (widget.loginMode == 'password') {
          data = await service.loginWithPassword(
            username: widget.username!,
            password: _passwordController.text.trim(),
            schoolData: widget.schoolData,
          );
        } else {
          data = await service.loginWithOTP(
            requestdata: {
              "otp": _otpController.text,
              "token": widget.userInfomation["token"],
            },
            loginurl: widget.schoolData["base_url"],
          );
        }

        if (!mounted) return; // 👈 add here

        if (widget.loginMode == "otp" && data["result"] == 0) {
          showBottomMessage(context, "${data["message"]}", true);
          hideLoaderDialog(context);
          setState(() => _isLoading = false);
          return;
        }

        final userData = {
          for (var item in data['success']) item['key']: item['value'],
          'base_url': widget.schoolData['base_url'],
          'isLogin': true,
        };

        if (!['master-admin', 'admin'].contains(userData['role'])) {
          showBottomMessage(context, "Invalid User", true);
          hideLoaderDialog(context);
          setState(() => _isLoading = false);
          return;
        }

        await SharedPrefHelper.storeSuccessData(userData);

        try {
          await DeviceToken().getDeviceToken();
        } catch (e) {
          debugPrint("Error generating device token: $e");
        }

        if (!mounted) return; // 👈 again before navigation
        hideLoaderDialog(context);
        context.goNamed('dashboard');
      } catch (e) {
        if (mounted) {
          hideLoaderDialog(context);
          showBottomMessage(context, e.toString(), true);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.purple.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          BouncingBubble(
            size: 60,
            left: width * 0.2,
            top: height * 0.1,
            color: Colors.purple,
          ),
          BouncingBubble(
            size: 80,
            left: width * 0.7,
            top: height * 0.2,
            color: Colors.blue,
            bounceHeight: 20,
            duration: const Duration(seconds: 3),
          ),
          BouncingBubble(
            size: 40,
            left: width * 0.5,
            top: height * 0.33,
            color: Colors.purpleAccent,
          ),
          BouncingBubble(
            size: 50,
            left: width * 0.1,
            top: height * 0.5,
            color: Colors.blueAccent,
          ),

          // Center Card
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Column(
                children: [
                  // ===== User Info Card =====
                  if (user != null) ResponsiveUserCard(user: user),

                  // ===== Login Card =====
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 20),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Column(
                          children: [
                            Text(
                              _isPasswordLogin
                                  ? "Login with Password"
                                  : "Login with OTP",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // Show OTP expiry timer only when login with OTP
                            if (!_isPasswordLogin)
                              Text(
                                _otpHelper.isOtpExpired
                                    ? "OTP expired"
                                    : "OTP valid for ${_otpHelper.formatTime(_otpHelper.expireSecondsRemaining)}",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        // Choice Chips
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 🔹 Password Chip
                            ChoiceChip(
                              label: const Text("Password"),
                              selected: _isPasswordLogin,
                              onSelected: widget.loginMode == 'otp'
                                  ? null
                                  : null, // fully disabled
                              backgroundColor: widget.loginMode == 'otp'
                                  ? Colors
                                        .grey
                                        .shade300 // disabled look
                                  : (_isPasswordLogin
                                        ? Colors
                                              .purple
                                              .shade100 // active look
                                        : Colors.grey.shade200), // normal look
                              labelStyle: TextStyle(
                                color: widget.loginMode == 'otp'
                                    ? Colors
                                          .grey // disabled text
                                    : (_isPasswordLogin
                                          ? Colors
                                                .purple
                                                .shade900 // active text
                                          : Colors.black54), // normal text
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(width: 10),

                            // 🔹 OTP Chip
                            ChoiceChip(
                              label: const Text("OTP"),
                              selected: !_isPasswordLogin,
                              onSelected: widget.loginMode == 'password'
                                  ? null
                                  : null, // fully disabled
                              backgroundColor: widget.loginMode == 'password'
                                  ? Colors
                                        .grey
                                        .shade300 // disabled look
                                  : (!_isPasswordLogin
                                        ? Colors
                                              .purple
                                              .shade100 // active look
                                        : Colors.grey.shade200), // normal look
                              labelStyle: TextStyle(
                                color: widget.loginMode == 'password'
                                    ? Colors
                                          .grey // disabled text
                                    : (!_isPasswordLogin
                                          ? Colors
                                                .purple
                                                .shade900 // active text
                                          : Colors.black54), // normal text
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Conditional Field
                        if (_isPasswordLogin)
                          Passwordinputfield(
                            controller: _passwordController,
                            hintText: "Enter Password",
                            isPasswordField: true,
                          )
                        else
                          Column(
                            children: [
                              Passwordinputfield(
                                controller: _otpController,
                                hintText: "Enter OTP",
                                isPasswordField: true,
                                prefixIcon: Icons.sms_outlined,
                                keyboardType: TextInputType.number,
                              ),

                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_otpHelper.isOtpExpired)
                                    const Text(
                                      "OTP expired, please resend.",
                                      style: TextStyle(color: Colors.red),
                                    )
                                  else
                                    Text(
                                      _otpHelper.isResendEnabled
                                          ? "Didn't receive OTP?"
                                          : "Resend in ${_otpHelper.formatTime(_otpHelper.resendSecondsRemaining)}",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  TextButton(
                                    onPressed: _otpHelper.isResendEnabled
                                        ? () async {
                                            final token =
                                                widget.userInfomation["token"];

                                            if (token == null ||
                                                token.toString().isEmpty) {
                                              showBottomMessage(
                                                context,
                                                "Token is not available or invalid",
                                                true,
                                              );
                                              return;
                                            }

                                            // 🔹 Call your resend OTP API
                                            await resendOtp(token);
                                          }
                                        : null, // disabled while timer is running
                                    child: Text(
                                      "Resend",
                                      style: TextStyle(
                                        color: _otpHelper.isResendEnabled
                                            ? Colors.purple.shade400
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.purple.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  _isPasswordLogin ? "Login" : "Verify OTP",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

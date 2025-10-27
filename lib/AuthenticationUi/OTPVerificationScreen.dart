import 'dart:async';
import 'package:digivity_admin_app/AdminPanel/Components/PopupNetworkImage.dart';
import 'package:digivity_admin_app/Authentication/LoginService.dart';
import 'package:digivity_admin_app/Authentication/SharedPrefHelper.dart';
import 'package:digivity_admin_app/AuthenticationUi/Loader.dart';
import 'package:digivity_admin_app/Components/ApiMessageWidget.dart';
import 'package:digivity_admin_app/Components/BouncingBubble.dart';
import 'package:digivity_admin_app/Helpers/DeviceToken.dart';
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
  bool _isPasswordVisible = false;
  bool _isOtpVisible = false;

  // OTP Timer
  bool _isResendEnabled = false;
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _isPasswordLogin = widget.loginMode == 'password';
    if (!_isPasswordLogin) _startOTPTimer();
  }

  void _startOTPTimer() {
    _secondsRemaining = 60;
    _isResendEnabled = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        setState(() => _isResendEnabled = true);
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
      if (_passwordController.text.length == 0) {
        showBottomMessage(context, "Please Enter Password", true);
        return;
      }
      setState(() => _isLoading = true);
      final service = LoginService();

      try {
        if (widget.loginMode == 'password') {
          showLoaderDialog(context, message: "Fetching data...");

          final Map<String, dynamic> data = await service.loginWithPassword(
            username: widget.username!,
            password: _passwordController.text.trim(),
            schoolData: widget.schoolData,
          );

          var successList = data['success'] as List? ?? [];

          if (data['result'] == "1" && data['success'].isEmpty) {
            hideLoaderDialog(context);
            showBottomMessage(context, data['message'], true);
            return;
          }

          Map<String, dynamic> userData = {};
          for (var item in data['success']) {
            userData[item['key']] = item['value'];
          }

          userData['base_url'] = widget.schoolData['base_url'];
          userData['isLogin'] = true;

          if (userData['role'] != 'master-admin' &&
              userData['role'] != 'admin') {
            hideLoaderDialog(context);
            showBottomMessage(context, "Invalid User", true);
            return;
          }

          if (!mounted) return;
          hideLoaderDialog(context);

          await SharedPrefHelper.storeSuccessData(userData);

          try {
            await DeviceToken().getDeviceToken();
          } catch (e) {
            debugPrint("Error generating device token: $e");
          }

          context.goNamed('dashboard');
        }
      } catch (e) {
        if (!mounted) return;
        hideLoaderDialog(context);
        showBottomMessage(context, e.toString(), true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
                  if (user != null)
                    IntrinsicHeight(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 12,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .stretch, // Make children fill vertical space
                          children: [
                            // Left Accent Border
                            Container(
                              width: 4,
                              decoration: BoxDecoration(
                                color: Colors.purple.shade400,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Profile Image
                            PopupNetworkImage(
                              imageUrl: user['profile_image'] ?? '',
                              radius: 90,
                            ),

                            const SizedBox(width: 16),

                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['full_name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        user['role'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone_android,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        user['mobile_no'] ??
                                            user['email_id'] ??
                                            '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_city,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Branch: ${user['branchname'] ?? '-'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.event_note,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Session: ${user['session'] ?? '-'}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Last Login: ${user['lastlogin'] ?? '-'}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

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
                        const SizedBox(height: 16),

                        // Choice Chips
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: const Text("Password"),
                              selected: _isPasswordLogin,
                              onSelected: (val) {
                                if (!otpDisabled)
                                  setState(() => _isPasswordLogin = true);
                              },
                            ),
                            const SizedBox(width: 10),
                            ChoiceChip(
                              label: const Text("OTP"),
                              selected: !_isPasswordLogin,
                              onSelected: otpDisabled
                                  ? null
                                  : (val) {
                                      setState(() {
                                        _isPasswordLogin = false;
                                        _startOTPTimer();
                                      });
                                    },
                              backgroundColor: otpDisabled
                                  ? Colors.grey.shade300
                                  : null,
                              labelStyle: TextStyle(
                                color: otpDisabled ? Colors.grey : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Conditional Field
                        if (_isPasswordLogin)
                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.purple.shade400, // Always visible
                                  width: 2,
                                ),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              hintText: "Enter Password",
                            ),
                          )
                        else
                          Column(
                            children: [
                              TextField(
                                controller: _otpController,
                                obscureText: !_isOtpVisible,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.purple.shade400, // Always visible
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.purple.shade400, // Always visible
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  hintText: "Enter Password",
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isResendEnabled
                                        ? "Didn't receive OTP?"
                                        : "Resend in $_secondsRemaining sec",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _isResendEnabled
                                        ? () {
                                            _startOTPTimer();
                                            // Call resend OTP API
                                          }
                                        : null,
                                    child: Text(
                                      "Resend",
                                      style: TextStyle(
                                        color: _isResendEnabled
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

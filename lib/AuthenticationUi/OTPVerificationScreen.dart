import 'dart:async';
import 'package:digivity_admin_app/Authentication/LoginService.dart';
import 'package:flutter/material.dart';
import 'package:digivity_admin_app/Authentication/SharedPrefHelper.dart';
import 'package:digivity_admin_app/AuthenticationUi/Loader.dart';
import 'package:go_router/go_router.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final Map<String, dynamic> schoolData;

  const OTPVerificationScreen({
    required this.verificationId,
    required this.schoolData,
    super.key,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResendEnabled = false;
  int _secondsRemaining = 60;
  Timer? _timer;
  late String _verificationId;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _startTimer();
  }

  void _startTimer() {
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
    _otpController.dispose();
    super.dispose();
  }

  // Future<void> _verifyOTP() async {
  //   if (_otpController.text.isEmpty) return;
  //
  //   setState(() => _isLoading = true);
  //   showLoaderDialog(context, message: "Verifying OTP...");
  //
  //   try {
  //     final success = await LoginService().verifyOTP(
  //       verificationId: widget.verificationId,
  //       otp: _otpController.text.trim(),
  //     );
  //
  //     hideLoaderDialog(context);
  //
  //     if (success) {
  //       // Optionally save login info here
  //       await SharedPrefHelper.storeSuccessData({
  //         'isLogin': true,
  //         'base_url': widget.schoolData['base_url'],
  //       });
  //
  //       if (!mounted) return;
  //       context.goNamed('dashboard');
  //     } else {
  //       if (!mounted) return;
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Invalid or expired OTP")),
  //       );
  //     }
  //   } catch (e) {
  //     hideLoaderDialog(context);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: $e")),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  Future<void> _resendOTP() async {
    if (!_isResendEnabled) return;

    setState(() => _isLoading = true);
    try {


      // Update verificationId

      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending OTP: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.purple.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Add your BouncingBubble widgets here for effect...

          // Center card
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 20),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Enter OTP",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "We have sent a 6-digit OTP to your phone number",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    // OTP Field
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        hintText: "Enter OTP",
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Verify button
                    ElevatedButton(
                      onPressed: _isLoading ? null : null,
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
                          : const Text(
                        "Verify OTP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    // Timer & Resend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isResendEnabled
                              ? "Didn't receive OTP?"
                              : "Resend in $_secondsRemaining sec",
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: _isResendEnabled ? _resendOTP : null,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:digivity_admin_app/Components/ApiMessageWidget.dart';
import 'package:flutter/material.dart';
import 'package:digivity_admin_app/Authentication/LoginService.dart';
import 'package:digivity_admin_app/AuthenticationUi/Loader.dart';
import 'package:digivity_admin_app/Components/BouncingBubble.dart';
import 'package:go_router/go_router.dart';

class LoginPageScreen extends StatefulWidget {
  final Map<String, dynamic> schoolData;
  const LoginPageScreen({required this.schoolData, super.key});

  @override
  State<LoginPageScreen> createState() => _LoginPageScreenState();
}

class _LoginPageScreenState extends State<LoginPageScreen>
    with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _loginMode = 'password';
  Map<String, dynamic> passdata = {}; // default

  late AnimationController _formAnimationController;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();
    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _formAnimation = CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeInOut,
    );
    _formAnimationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  void _switchLoginMode(String mode) {
    if (_loginMode != mode) {
      _formAnimationController.reverse().then((_) {
        setState(() => _loginMode = mode);
        _formAnimationController.forward();
      });
    }
  }

  Future<void> _handleLogin() async {
    if (_loginMode == "password") {
      if (_usernameController.text.length == 0) {
        showBottomMessage(context, "Please Enter Password First!", true);
        return;
      }
    } else if (_loginMode == "otp") {
      if (_phoneController.text.length == 0) {
        showBottomMessage(context, "Please Enter Phone Number First!", true);
        return;
      }
    }

    setState(() => _isLoading = true);
    final service = LoginService();

    // Common variables
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final schoolData = widget.schoolData;

    try {
      // Show loader based on mode
      final loaderMessage = _loginMode == 'password'
          ? "Fetching data..."
          : "Sending OTP...";
      showLoaderDialog(context, message: loaderMessage);

      Map<String, dynamic> response = {};

      // Make API call depending on login mode
      if (_loginMode == 'password') {
        response = await service.loginWithUserName(
          username: username,
          schoolData: schoolData,
        );
      } else {
        response = await service.sendOtp(phone: phone, schoolData: schoolData);
      }

      hideLoaderDialog(context);

      // Handle successful response
      final success = response["success"];
      final isSuccess = _loginMode == "password"
          ? success is Map && success.isNotEmpty
          : (response["result"] == 1 && success is Map && success.isNotEmpty);

      if (isSuccess) {
        if (!mounted) return;
        final passdata = {
          "userInfomation": response,
          "schoolData": schoolData,
          "loginMode": _loginMode,
          "username": _loginMode == "password" ? username : phone,
        };

        context.pushNamed('otp_verification', extra: passdata);
      } else {
        showBottomMessage(
          context,
          response["message"] ?? "Login failed. Please try again.",
          true,
        );
      }
    } catch (e) {
      hideLoaderDialog(context);
      showBottomMessage(context, e.toString(), true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolData = widget.schoolData;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    bool _isPressed = false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.purple.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Floating bubbles
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
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(schoolData['school_logo']),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    schoolData['school_name'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schoolData['school_address'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),

                  // Toggle
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          alignment: _loginMode == 'password'
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Container(
                            width: width * 0.42,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade400,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.shade200.withOpacity(
                                    0.4,
                                  ),
                                  offset: const Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _switchLoginMode('password'),
                                child: Center(
                                  child: Text(
                                    'Password Login',
                                    style: TextStyle(
                                      color: _loginMode == 'password'
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _switchLoginMode('otp'),
                                child: Center(
                                  child: Text(
                                    'OTP Login',
                                    style: TextStyle(
                                      color: _loginMode == 'otp'
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Animated Form
                  SizeTransition(
                    sizeFactor: _formAnimation,
                    axisAlignment: -1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 20),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (_loginMode == 'password') ...[
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ],

                            if (_loginMode == 'otp') ...[
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  hintText: 'Enter mobile number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  prefixIcon: const Icon(Icons.phone),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ],

                            const SizedBox(height: 24),
                            GestureDetector(
                              onTapDown: (_) =>
                                  setState(() => _isPressed = true),
                              onTapUp: (_) =>
                                  setState(() => _isPressed = false),
                              onTapCancel: () =>
                                  setState(() => _isPressed = false),
                              onTap: _isLoading ? null : _handleLogin,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                transform: Matrix4.identity()
                                  ..scale(_isPressed ? 0.95 : 1.0),
                                child: Container(
                                  height: 55,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade400,
                                        Colors.purple.shade300,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.shade200
                                            .withOpacity(0.5),
                                        offset: const Offset(0, 6),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            _loginMode == 'password'
                                                ? "Login"
                                                : "Send OTP",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

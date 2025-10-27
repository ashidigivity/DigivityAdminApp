import 'package:flutter/material.dart';

class Passwordinputfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPasswordField;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool autoFocus;

  const Passwordinputfield({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPasswordField = false,
    this.prefixIcon = Icons.lock_outline,
    this.keyboardType = TextInputType.text,
    this.autoFocus = false,
  });

  @override
  State<Passwordinputfield> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<Passwordinputfield> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPasswordField ? !_isVisible : false,
      keyboardType: widget.keyboardType,
      autofocus: widget.autoFocus,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          widget.prefixIcon,
          color: Colors.purple.shade500,
        ),
        suffixIcon: widget.isPasswordField
            ? IconButton(
          icon: Icon(
            _isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.purple.shade400,
          ),
          onPressed: () {
            setState(() {
              _isVisible = !_isVisible;
            });
          },
        )
            : null,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.purple.shade400, // always visible border
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.purple.shade700, // darker on focus
            width: 2,
          ),
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}

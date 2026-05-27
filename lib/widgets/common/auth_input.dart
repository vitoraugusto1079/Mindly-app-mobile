import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AuthInput extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool obscure;
  final TextInputType keyboardType;

  const AuthInput({
    super.key,
    required this.controller,
    required this.placeholder,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: Color(0xFFCFD8DC)),
          filled: true,
          fillColor: AppColors.loginInputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

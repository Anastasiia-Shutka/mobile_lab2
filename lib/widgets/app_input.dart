import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  final String h;
  final IconData i;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isPassword;

  const AppInput(
    this.h,
    this.i, {
    required this.controller,
    super.key,
    this.validator,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext bc) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      validator: validator,
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(i, color: Colors.blue[300]),
        hintText: h,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    ),
  );
}

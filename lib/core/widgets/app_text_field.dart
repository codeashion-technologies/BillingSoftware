import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.label,
    this.controller,
    this.hintText,
    this.obscureText = false,
    super.key,
  });
  final String? label;
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(labelText: label, hintText: hintText),
  );
}

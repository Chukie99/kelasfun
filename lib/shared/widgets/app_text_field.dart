import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? initialValue;
  final int? maxLines;

  const AppTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.initialValue,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

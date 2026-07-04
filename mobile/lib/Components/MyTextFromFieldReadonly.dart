import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';

class MyTextFieldReadOnly extends StatelessWidget {
  final String label;
  final String value;

  const MyTextFieldReadOnly({
    super.key,
    required this.value,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dividerColor),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
      ),
    );
  }
}

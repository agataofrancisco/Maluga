import 'package:flutter/material.dart';

class MyTextFieldReadOnly extends StatelessWidget {
  final String texto;
  const MyTextFieldReadOnly({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      textAlign: TextAlign.center,
      initialValue: texto,
      
      decoration: const InputDecoration(
        border:OutlineInputBorder(),
      ),
    );
  }
}
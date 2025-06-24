import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';

class MyElevatedbutton extends StatelessWidget {
  final String text;
  final action;

  const MyElevatedbutton({super.key, required this.text, required this.action});

  @override
  Widget build(BuildContext context,) {
    return ElevatedButton(
      onPressed: action,
      style:  ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(BaseColor), 
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: ForegroundColor
        ),
      ),
    );
  }
}
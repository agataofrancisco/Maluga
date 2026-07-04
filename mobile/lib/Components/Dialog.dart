import 'package:flutter/material.dart';

class Dialogo extends StatelessWidget {
  final List<Widget> botoes;
  final String title;
  final String content;
  const Dialogo({super.key, required this.title, required this.content, required this.botoes});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: botoes  
    );
  }
}
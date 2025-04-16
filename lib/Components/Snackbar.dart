import 'package:flutter/material.dart';

class Snackbar_ extends StatelessWidget {
  const Snackbar_({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10),
      child:  SnackBar(content: Text("teste"))
    );
  }
}
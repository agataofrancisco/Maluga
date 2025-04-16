import 'package:flutter/material.dart';

class Emptyalugo extends StatelessWidget {
  const Emptyalugo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
       child: Text(
                "Nenhum Alugo encontrado",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:FontWeight.bold,
                )
              ),
      ),
    );
  }
}
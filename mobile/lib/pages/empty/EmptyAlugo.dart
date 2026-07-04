import 'package:flutter/material.dart';
import 'package:flutter_/Components/EmptyState.dart';

class EmptyAlugo extends StatelessWidget {
  const EmptyAlugo({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.handshake_outlined,
      title: 'Nenhum aluguer registado',
      subtitle: 'Quando registar um aluguer, ele aparecerá aqui',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double size;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = 12,
  });

  Color _getColor() {
    switch (status.toLowerCase()) {
      case 'novo':
        return successColor;
      case 'semi-novo':
      case 'seminovo':
        return const Color(0xFF3B82F6);
      case 'antigo':
        return const Color(0xFF9CA3AF);
      case 'active':
      case 'ativo':
        return successColor;
      case 'returned':
      case 'devolvido':
        return const Color(0xFF3B82F6);
      case 'overdue':
      case 'atrasado':
        return errorColor;
      case 'cancelled':
      case 'cancelado':
        return const Color(0xFF9CA3AF);
      default:
        return textSecondary;
    }
  }

  String _getLabel() {
    switch (status.toLowerCase()) {
      case 'novo':
        return 'Novo';
      case 'semi-novo':
      case 'seminovo':
        return 'Semi-Novo';
      case 'antigo':
        return 'Antigo';
      case 'active':
      case 'ativo':
        return 'Ativo';
      case 'returned':
      case 'devolvido':
        return 'Devolvido';
      case 'overdue':
      case 'atrasado':
        return 'Atrasado';
      case 'cancelled':
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

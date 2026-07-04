import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';
import 'package:flutter_/Components/StatusBadge.dart';
import 'package:flutter_/db/Database.dart';
import 'package:flutter_/db/Models/alugo_model.dart';
import 'package:flutter_/pages/empty/EmptyAlugo.dart';

class PieceAlugos extends StatefulWidget {
  const PieceAlugos({super.key});
  @override
  State<PieceAlugos> createState() => _PieceAlugosState();
}

class _PieceAlugosState extends State<PieceAlugos> {
  List<AlugoModel> alugos = [];
  late Future<List<AlugoModel>> _alugos;

  void _loadAlugos() {
    final db = MalugaDatabase.instance;
    _alugos = db.getAllData('alugos', 'date_alugo').then((data) {
      return alugos = data.map((item) => AlugoModel.fromMap(item)).toList();
    }).catchError((error) {
      debugPrint('erro ao carregar os dados: $error');
      return <AlugoModel>[];
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0);
  }

  String _rentalStatus(DateTime endDate) {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 'overdue';
    final diff = endDate.difference(now).inDays;
    if (diff <= 1) return 'active';
    return 'active';
  }

  @override
  void initState() {
    super.initState();
    _loadAlugos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AlugoModel>>(
      future: _alugos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyAlugo();
        } else {
          final alugosList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: alugosList.length,
            itemBuilder: (context, index) {
              final alugo = alugosList[index];
              final status = _rentalStatus(alugo.date_return);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              alugo.name_alugador,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          StatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            'Devolução: ${_formatDate(alugo.date_return)}',
                            style: const TextStyle(color: textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16, color: textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                alugo.contact_alugador,
                                style: const TextStyle(color: textSecondary, fontSize: 14),
                              ),
                            ],
                          ),
                          Text(
                            '${_formatPrice(alugo.totalalugo)} Kz',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

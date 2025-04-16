import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';

class MylistTile extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String trallling;
  
  const MylistTile({super.key, required this.titulo, required this.subtitulo, required this.trallling});

  @override
  Widget build(BuildContext context) {
    return Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: BaseColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child:
                      ListTile(
                        title:Text(
                          titulo,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ForegroundColor,
                          ),
                        ),
                        subtitle: Text(
                          subtitulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          trallling,
                          style: TextStyle(
                            color: ForegroundColor
                          ),
                        ),
                      ),
                    ),
                  ),
                );
  }
}
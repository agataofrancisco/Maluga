import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';
import 'package:flutter_/Components/EmptyState.dart';
import 'package:flutter_/Components/MyElevatedButton.dart';
import 'package:flutter_/Components/MyTextField.dart';
import 'package:flutter_/db/Database.dart';
import 'package:flutter_/pages/Menu.dart';

class EmptyMaterial extends StatefulWidget {
  const EmptyMaterial({super.key});
  @override
  State<EmptyMaterial> createState() => _EmptyMaterialState();
}

class _EmptyMaterialState extends State<EmptyMaterial> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  TextEditingController quantitycontroller = TextEditingController();
  TextEditingController statuscontroller = TextEditingController();
  TextEditingController precocontroller = TextEditingController();

  void _addMaterialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Material'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextField(label: 'Nome', controller: namecontroller),
                MyTextField(label: 'Descrição', controller: descriptioncontroller),
                MyTextField(
                  label: 'Quantidade',
                  controller: quantitycontroller,
                  keyboardType: const TextInputType.numberWithOptions(),
                  prefixIcon: Icons.inventory,
                ),
                MyTextField(label: 'Estado', controller: statuscontroller, prefixIcon: Icons.star_outline),
                MyTextField(
                  label: 'Preço (Kz)',
                  controller: precocontroller,
                  keyboardType: const TextInputType.numberWithOptions(),
                  prefixIcon: Icons.attach_money,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            MyElevatedButton(
              text: 'Adicionar',
              icon: Icons.check,
              onPressed: () => _insert(),
            ),
          ],
        );
      },
    );
  }

  void _insert() async {
    final db = MalugaDatabase.instance;
    final material = {
      'name': namecontroller.text,
      'description': descriptioncontroller.text,
      'quantity': int.tryParse(quantitycontroller.text) ?? 0,
      'status': statuscontroller.text,
      'price': double.tryParse(precocontroller.text) ?? 0.0,
    };

    if (namecontroller.text.isEmpty ||
        descriptioncontroller.text.isEmpty ||
        quantitycontroller.text.isEmpty ||
        statuscontroller.text.isEmpty ||
        precocontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos'),
          backgroundColor: errorColor,
        ),
      );
    } else {
      await db.insert('materials', material);
      namecontroller.clear();
      descriptioncontroller.clear();
      quantitycontroller.clear();
      statuscontroller.clear();
      precocontroller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material adicionado com sucesso!'),
          backgroundColor: successColor,
        ),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Menu()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Nenhum material encontrado',
        subtitle: 'Adicione o seu primeiro material para começar',
        actionLabel: 'Adicionar Material',
        onAction: _addMaterialDialog,
      ),
    );
  }
}

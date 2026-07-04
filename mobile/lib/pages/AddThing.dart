import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';
import 'package:flutter_/Components/MyElevatedButton.dart';
import 'package:flutter_/Components/MyTextField.dart';
import 'package:flutter_/db/Database.dart';
import 'package:flutter_/pages/Menu.dart';

class AddThingPage extends StatefulWidget {
  const AddThingPage({super.key});

  @override
  State<AddThingPage> createState() => _AddThingPageState();
}

class _AddThingPageState extends State<AddThingPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  String _status = 'novo';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    final db = MalugaDatabase.instance;
    final material = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'quantity': int.tryParse(_quantityController.text) ?? 0,
      'status': _status,
      'price': double.tryParse(_priceController.text) ?? 0.0,
    };

    await db.insert('materials', material);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Material')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              MyTextField(
                label: 'Nome do material',
                controller: _nameController,
                prefixIcon: Icons.inventory_2_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              MyTextField(
                label: 'Descrição',
                controller: _descriptionController,
                prefixIcon: Icons.description_outlined,
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              MyTextField(
                label: 'Quantidade',
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(),
                prefixIcon: Icons.inventory,
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    prefixIcon: Icon(Icons.star_outline),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'novo', child: Text('Novo')),
                    DropdownMenuItem(value: 'semi-novo', child: Text('Semi-Novo')),
                    DropdownMenuItem(value: 'antigo', child: Text('Antigo')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'novo'),
                ),
              ),
              MyTextField(
                label: 'Preço (Kz)',
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(),
                prefixIcon: Icons.attach_money,
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              MyElevatedButton(
                text: 'Adicionar Material',
                icon: Icons.check,
                expanded: true,
                onPressed: _addMaterial,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

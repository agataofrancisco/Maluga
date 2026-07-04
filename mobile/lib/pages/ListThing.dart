import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';
import 'package:flutter_/Components/StatusBadge.dart';
import 'package:flutter_/Components/MyElevatedButton.dart';
import 'package:flutter_/Components/MyTextField.dart';
import 'package:flutter_/Components/MyTextFromFieldReadonly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_/db/Database.dart';
import 'package:flutter_/db/Models/material_model.dart';
import 'package:flutter_/pages/empty/EmptyMaterial.dart';
import 'package:flutter_/services/NifValidator.dart';

class ListThing extends StatefulWidget {
  const ListThing({super.key});

  @override
  State<ListThing> createState() => _ListThingState();
}

class _ListThingState extends State<ListThing> {
  bool isLoading = false;
  bool failed = false;
  bool showExtraFields = false;
  bool verification = false;
  late Future<List<Materialmodel>> _materials;
  List<Materialmodel> materials = [];
  Set<int> selectedMaterials = {};
  Map<int, TextEditingController> quantidadeController = {};
  int stepIndex = 0;
  String currentStep = '1- Identificação do Cliente';
  List<Materialmodel> searchResults = [];

  final nameMaterialController = TextEditingController();
  final nameAlugadorController = TextEditingController();
  final nameKilapeiroController = TextEditingController();
  final descriptionController = TextEditingController();
  final statusController = TextEditingController();
  final precoController = TextEditingController();
  final quantityController = TextEditingController();
  final nifController = TextEditingController();
  final telefoneController = TextEditingController();
  final enderecoController = TextEditingController();
  final searchController = TextEditingController();
  final dateController = TextEditingController();

  final List<String> steps = [
    '1- Identificação do Cliente',
    '2- Informar quantidade',
    '3- Data de devolução',
    '4- Foto do contrato (opcional)',
    '5- Resumo',
    '6- Concluir',
    '',
  ];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  @override
  void dispose() {
    nameMaterialController.dispose();
    nameAlugadorController.dispose();
    nameKilapeiroController.dispose();
    descriptionController.dispose();
    statusController.dispose();
    precoController.dispose();
    quantityController.dispose();
    nifController.dispose();
    telefoneController.dispose();
    enderecoController.dispose();
    searchController.dispose();
    dateController.dispose();
    for (final c in quantidadeController.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    if (stepIndex < steps.length - 1) {
      stepIndex++;
      currentStep = steps[stepIndex];
    }
  }

  void _prevStep() {
    if (stepIndex > 0) {
      stepIndex--;
      currentStep = steps[stepIndex];
    }
  }

  XFile? _image;

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _image = picked);
    }
  }

  String _formatPrice(double price) => price.toStringAsFixed(0);

  void _loadMaterials() {
    setState(() => isLoading = true);
    final db = MalugaDatabase.instance;
    _materials = db.getAllMaterials('materials').then((data) {
      materials = data.map((item) => Materialmodel.fromMap(item)).toList();
      searchResults = materials;
      return materials;
    }).catchError((error) {
      debugPrint('Erro ao carregar materiais: $error');
      return <Materialmodel>[];
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  void _toggleSelection(int materialId, {bool fromCheckbox = false}) {
    setState(() {
      if (fromCheckbox) {
        if (selectedMaterials.contains(materialId)) {
          selectedMaterials.remove(materialId);
          quantidadeController[materialId]?.dispose();
          quantidadeController.remove(materialId);
        } else {
          selectedMaterials.add(materialId);
          quantidadeController[materialId] = TextEditingController();
        }
      }
    });
  }

  void _onSearch(String query) {
    setState(() {
      searchResults = materials
          .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _nifVerify(String nif, void Function(VoidCallback) setDialogState) async {
    if (nif.length < 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O NIF deve ter exatamente 14 caracteres'),
          backgroundColor: errorColor,
        ),
      );
      return;
    }
    setDialogState(() => isLoading = true);
    String nome = await ValidarNif(nif);
    if (nome != 'Nome não encontrado') {
      setDialogState(() {
        isLoading = false;
        showExtraFields = true;
        verification = true;
        nameKilapeiroController.text = nome;
        failed = false;
      });
    } else {
      setDialogState(() {
        isLoading = false;
        failed = true;
      });
    }
  }

  void _insertAlugo() async {
    final db = MalugaDatabase.instance;
    final alugoData = {
      'name_alugador': nameKilapeiroController.text,
      'nif_alugador': nifController.text,
      'contact_alugador': telefoneController.text,
      'date_alugo': DateTime.now().toIso8601String(),
      'date_return': dateController.text,
      'total_alugo': 0.0,
      'contract_image': _image?.path,
    };

    final int idAlugo = await db.insert('alugos', alugoData);
    double totalAlugo = 0.0;

    for (final idMaterial in selectedMaterials) {
      final material = materials.firstWhere((p) => p.id == idMaterial);
      final qty = int.tryParse(quantidadeController[idMaterial]?.text ?? '0') ?? 0;
      totalAlugo += material.price * qty;

      await db.insert('alugo_items', {
        'id_alugo': idAlugo,
        'material': material.name,
        'quantity': qty,
      });
      await db.diminuirMaterialQuantidade(idMaterial, qty);
    }

    await db.update('alugos', {'total_alugo': totalAlugo},
        where: 'id_alugo = ?', whereArgs: [idAlugo]);

    await db.insert('alugador', {
      'name': nameKilapeiroController.text,
      'nif': nifController.text,
      'location': enderecoController.text,
      'phone_number': telefoneController.text,
      'classification': 0.0,
    });

    await db.insert('historico', {
      'nome': nameKilapeiroController.text,
      'data': DateTime.now().toIso8601String(),
      'materials': selectedMaterials.join(', '),
      'type': 'alugo',
      'total': totalAlugo,
    });

    _clearAlugoFields();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aluguer registado com sucesso!'),
          backgroundColor: successColor,
        ),
      );
      _loadMaterials();
    }
  }

  void _clearAlugoFields() {
    nameMaterialController.clear();
    descriptionController.clear();
    quantityController.clear();
    nifController.clear();
    telefoneController.clear();
    enderecoController.clear();
    selectedMaterials.clear();
    for (final c in quantidadeController.values) {
      c.dispose();
    }
    quantidadeController.clear();
    dateController.clear();
    _image = null;
    stepIndex = 0;
    currentStep = steps[0];
    showExtraFields = false;
    verification = false;
    failed = false;
  }

  void _insertMaterial() async {
    final db = MalugaDatabase.instance;
    final material = {
      'name': nameMaterialController.text,
      'description': descriptionController.text,
      'quantity': int.tryParse(quantityController.text) ?? 0,
      'status': statusController.text,
      'price': double.tryParse(precoController.text) ?? 0.0,
    };

    if (nameMaterialController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        quantityController.text.isEmpty ||
        statusController.text.isEmpty ||
        precoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos'),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    await db.insert('materials', material);
    nameMaterialController.clear();
    descriptionController.clear();
    quantityController.clear();
    statusController.clear();
    precoController.clear();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material adicionado com sucesso!'),
          backgroundColor: successColor,
        ),
      );
      _loadMaterials();
    }
  }

  // ===== WIZARD STEP WIDGETS =====

  Widget _stepClient() {
    return Column(
      children: [
        MyTextField(
          label: 'NIF do Cliente',
          controller: nifController,
          prefixIcon: Icons.badge,
          keyboardType: const TextInputType.numberWithOptions(),
        ),
        if (showExtraFields) ...[
          MyTextFieldReadOnly(label: 'Nome', value: nameKilapeiroController.text),
          MyTextField(label: 'Endereço', controller: enderecoController, prefixIcon: Icons.location_on),
          MyTextField(
            label: 'Telefone',
            controller: telefoneController,
            prefixIcon: Icons.phone,
            keyboardType: const TextInputType.numberWithOptions(),
          ),
        ],
      ],
    );
  }

  Widget _stepQuantity() {
    return Column(
      children: selectedMaterials.map((idMaterial) {
        final material = materials.firstWhere((p) => p.id == idMaterial);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2, color: primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(material.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text('${_formatPrice(material.price)} Kz',
                        style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                MyTextField(
                  label: 'Quantidade',
                  controller: quantidadeController[idMaterial],
                  keyboardType: const TextInputType.numberWithOptions(),
                  prefixIcon: Icons.numbers,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _stepDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: dateController,
        readOnly: true,
        decoration: const InputDecoration(
          labelText: 'Data de devolução',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            setState(() {
              dateController.text =
                  '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
            });
          }
        },
      ),
    );
  }

  Widget _stepContract() {
    return Column(
      children: [
        if (_image != null)
          Container(
            width: 200,
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(_image!.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        MyElevatedButton(
          text: _image != null ? 'Tirar outra foto' : 'Tirar foto do contrato',
          icon: Icons.camera_alt,
          onPressed: _takePicture,
        ),
      ],
    );
  }

  Widget _stepSummary() {
    double globalTotal = 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo do Pedido',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: textSecondary),
              const SizedBox(width: 8),
              Text('Cliente: ${nameKilapeiroController.text}',
                  style: const TextStyle(fontSize: 16, color: textSecondary)),
            ],
          ),
          const Divider(),
          ...selectedMaterials.map((idMaterial) {
            final material = materials.firstWhere((p) => p.id == idMaterial);
            final qty = int.tryParse(quantidadeController[idMaterial]?.text ?? '0') ?? 0;
            final total = qty * material.price;
            globalTotal += total;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${material.name} x$qty')),
                  Text('${_formatPrice(total.toDouble())} Kz',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
            );
          }),
          const Divider(),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: textSecondary),
              const SizedBox(width: 8),
              Text('Devolução: ${dateController.text}',
                  style: const TextStyle(fontSize: 16, color: textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Global:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${_formatPrice(globalTotal)} Kz',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepDone() {
    return const Column(
      children: [
        Icon(Icons.check_circle, color: successColor, size: 64),
        SizedBox(height: 16),
        Text('Aluguer concluído com sucesso!',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ===== DIALOGS =====

  void _showMaterialDialog(Materialmodel material) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(material.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.description, size: 18, color: textSecondary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(material.description)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.inventory, size: 18, color: textSecondary),
                  const SizedBox(width: 8),
                  Text('Quantidade: ${material.quantity}'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 18, color: textSecondary),
                  const SizedBox(width: 8),
                  Text('Preço: ${_formatPrice(material.price)} Kz',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Estado:', style: TextStyle(color: textSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              StatusBadge(status: material.status, size: 13),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Fechar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                _showAlugoWizard();
              },
              icon: const Icon(Icons.handshake),
              label: const Text('Alugar'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMaterialDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Adicionar Material'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextField(label: 'Nome', controller: nameMaterialController, prefixIcon: Icons.inventory_2_outlined),
                MyTextField(label: 'Descrição', controller: descriptionController, prefixIcon: Icons.description, maxLines: 2),
                MyTextField(
                  label: 'Quantidade',
                  controller: quantityController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  prefixIcon: Icons.numbers,
                ),
                MyTextField(label: 'Estado', controller: statusController, prefixIcon: Icons.star_outline),
                MyTextField(
                  label: 'Preço (Kz)',
                  controller: precoController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  prefixIcon: Icons.attach_money,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            MyElevatedButton(text: 'Adicionar', icon: Icons.check, onPressed: _insertMaterial),
          ],
        );
      },
    );
  }

  void _showAlugoWizard() {
    _clearAlugoFields();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Registar Aluguer'),
                  TextButton(
                    onPressed: () {
                      _clearAlugoFields();
                      Navigator.of(ctx).pop();
                    },
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: (stepIndex + 1) / steps.length,
                      color: primaryColor,
                      backgroundColor: dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                    Text(currentStep,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                    const SizedBox(height: 12),
                    if (stepIndex == 0) _stepClient(),
                    if (stepIndex == 1) _stepQuantity(),
                    if (stepIndex == 2) _stepDate(),
                    if (stepIndex == 3) _stepContract(),
                    if (stepIndex == 4) _stepSummary(),
                    if (stepIndex == 5) _stepDone(),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (stepIndex > 0 && verification)
                      TextButton.icon(
                        onPressed: () => setDialogState(() => _prevStep()),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar'),
                      ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    if (failed)
                      const Text('Falhou', style: TextStyle(color: errorColor, fontWeight: FontWeight.bold)),
                    if (verification && stepIndex < 5)
                      ElevatedButton.icon(
                        onPressed: () {
                          setDialogState(() => _nextStep());
                          if (stepIndex == 5) {
                            _insertAlugo();
                            Navigator.of(ctx).pop();
                          }
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Avançar'),
                      ),
                    if (!verification && stepIndex == 0)
                      ElevatedButton.icon(
                        onPressed: () => _nifVerify(nifController.text, setDialogState),
                        icon: const Icon(Icons.search),
                        label: const Text('Verificar NIF'),
                      ),
                    if (stepIndex == 5)
                      ElevatedButton.icon(
                        onPressed: () {
                          _insertAlugo();
                          Navigator.of(ctx).pop();
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Concluir'),
                      ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===== BUILD =====

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Materialmodel>>(
      future: _materials,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyMaterial();
        } else {
          return Scaffold(
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    onChanged: _onSearch,
                    decoration: const InputDecoration(
                      labelText: 'Pesquisar materiais',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: searchResults.isEmpty
                      ? const Center(
                          child: Text('Nenhum resultado',
                              style: TextStyle(color: textSecondary)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final material = searchResults[index];
                            final isSelected = selectedMaterials.contains(material.id);
                            return Card(
                              color: isSelected ? primaryColor.withValues(alpha: 0.1) : null,
                              child: ListTile(
                                onTap: () {
                                  if (!isSelected) _showMaterialDialog(material);
                                },
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.inventory_2, color: primaryColor),
                                ),
                                title: Text(
                                  material.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(material.description,
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: textSecondary, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '${_formatPrice(material.price)} Kz',
                                          style: const TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        StatusBadge(status: material.status, size: 11),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Checkbox(
                                  value: isSelected,
                                  onChanged: (v) => _toggleSelection(material.id, fromCheckbox: true),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            floatingActionButton: selectedMaterials.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        tooltip: 'Registar aluguer',
                        heroTag: 'alugo',
                        onPressed: _showAlugoWizard,
                        child: const Icon(Icons.send),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        tooltip: 'Adicionar material',
                        heroTag: 'add',
                        onPressed: _showAddMaterialDialog,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  )
                : FloatingActionButton(
                    tooltip: 'Adicionar material',
                    onPressed: _showAddMaterialDialog,
                    child: const Icon(Icons.add),
                  ),
          );
        }
      },
    );
  }
}

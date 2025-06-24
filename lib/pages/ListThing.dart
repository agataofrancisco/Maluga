import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_/Components/MyElevatedButton.dart';
import 'package:flutter_/Components/MyTextField.dart';
import 'package:flutter_/Components/MyTextFromFieldReadonly.dart';
import 'package:flutter_/db/Database.dart';
import 'package:flutter_/db/Models/material_model.dart';
import 'package:flutter_/pages/empty/EmptyMaterial.dart';
import 'package:flutter_/services/NifValidator.dart';

class ListThing extends StatefulWidget {
  const ListThing({super.key});

  @override
  State<ListThing> createState() => _ListThingState();
}

class _ListThingState extends State<ListThing>{
  bool isloading = false; //VERIFICA SE O APP ESTÁ A CARREGAR
  bool failed = false; //VERIFICA SE A REQUISIÇÃO FALHOU
  bool showExtrafields = false; //VERIFICA A NECESSIDADE DE ADICIONAR MAIS CAMPOS
  bool verification= false;
  late Future<List<Materialmodel>> _materials; 
  List<Materialmodel> materials = [];
  Set<int> selectedmaterials = {};
  Set<int> selectedmaterial = {};
  Map<int, TextEditingController> quantidadeController = {};
  int stepIndex = 0;
  String CurrentStep = "1- Identificação do Cliente";
  List<Materialmodel> pesquisaResults = [];
  int step = 0;
  double totalPrice = 0;

  //CONTROLLERS
  TextEditingController namematerialcontroller = TextEditingController();
  TextEditingController namealugadorcontroller = TextEditingController();
  TextEditingController namekilapeirocontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  TextEditingController statuscontroller = TextEditingController();
  TextEditingController precocontroller = TextEditingController();
  TextEditingController  quantitycontroller = TextEditingController();
  TextEditingController nifcontroller = TextEditingController();
  TextEditingController telefoneController = TextEditingController();
  TextEditingController enderecoController = TextEditingController();
  TextEditingController pesquisaController = TextEditingController();
  TextEditingController dateController = TextEditingController();

//VECTOR QUE ARMAZENA OS PASSOS PARA CONCLUIR UM ALUGO OU KILAPO
  final List<String> steps =[
    "1- Identificação do Cliente",
    "2- Informar quantidade",
    "3- Data de devolução",
    "4- Envie a foto do contrato (opcional)" ,
    "5- Resumo",
    "6- Concluir",
    ""
  ];

//FUNÇÃO PARA AVANÇAR ENTRE OS PASSOS ANTERIORES
  void _nextStep(){
    if(stepIndex < steps.length -1){
      stepIndex ++;
      CurrentStep = steps[stepIndex];
    }
  }

//FUNÇÃO PARA VOLTAR ENTRE OS PASSOS
void _prevStep(){
  if(stepIndex > 0){
    stepIndex --;
    CurrentStep = steps[stepIndex];
  }
}

XFile? _image; // Variável para armazenar a imagem capturada

Future<void> _takePicture() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);
  if (pickedImage != null) {
    setState(() {
      _image = pickedImage;
    });
  }
}

//PRIMEIRO PASSO: INFORMAR AS INFORMAÇÕES DO CLIENTE
Widget _idClientstep(){
  return Column(
    children: [
      Mytextfield(hintText: "NIF do KILAPEIRO", Controller: nifcontroller),if (showExtrafields) ...[
        Mytextfield(hintText: "Nome", Controller: namekilapeirocontroller),
        Mytextfield(hintText: "Endereço", Controller: enderecoController),
        Mytextfield(hintText: "Telefone", Controller: telefoneController, keyboardtype: const TextInputType.numberWithOptions(),),
        //DatePickerDialog(firstDate: currentdate, lastDate: lastDate)
      ]
    ],
  );
}

//SEGUNDO PASSO: DEFINIR AS QUANTIDADES
Widget _quantidadestep(){
  return Column(
    children: [
      ...selectedmaterials.map((idMaterial){
        final material = materials.firstWhere((p) => p.id == idMaterial);
        //final int quantidade = quantitycontroller.textt
       //final int total = (material.price * quantidade).toInt();
        return Column(
          children: [
             const Text("Alugador"),
            MyTextFieldReadOnly(texto: namealugadorcontroller.text),
            const Text("Pedido"),
            MyTextFieldReadOnly(texto: material.name),
            const Text("Preço"),
            MyTextFieldReadOnly(texto:"${material.price.toString()}Kz"),
            Mytextfield(hintText: "Quantidade", Controller: quantidadeController[idMaterial]!, keyboardtype: const TextInputType.numberWithOptions(),),
          ],
        );
    }),
    ],
  );
}

//TERCEIRO PASSP: INFORMAR A DATA DE DEVOLUÇÃO
Widget _dateStep(){
  return Column(
    children: [
      TextField(
        controller: dateController,
        readOnly: true,
        decoration: const InputDecoration(
          labelText: "Data de devolução",
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            });
          }
        },
      ),
    ],
  );
}


//QUARTO PASSO: CARREGAR UMA FOTO DO E CONTRACTO
Widget _contractStep(){
  print("imafekms $_image");
  return Column(
    children: [
      MyElevatedbutton(text: "Tire uma foto"
      , action: (){_takePicture();}),
      if(_image!=null) Container(
        width: 200,
        height: 200,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image:AssetImage("")
          )
        ),
      ),
      if(_image==null) const SizedBox(height: 10,),
    ],
  );
}

//Quinto PASSO: CONFIRMAÇÃO DO KILAPI
Widget _concluirstep(){
  return const Column(
    children: [
      Icon(Icons.check_circle,color: Colors.green,size: 50,),
      Text("O kilapi foi concluido com sucesso", style: TextStyle(
        fontSize: 17
      ),)
    ],
  );
}

//Sexto passo: resumo
Widget _Resumo() {
  double globalTotal = 0;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Resumo do Pedido",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        "Cliente: ${namekilapeirocontroller.text}",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
      const Divider(thickness: 1, color: Colors.grey),
      ...selectedmaterials.map((idMaterial) {
        final material = materials.firstWhere((p) => p.id == idMaterial);
        final quantity = int.tryParse(quantidadeController[idMaterial]?.text ?? '0') ?? 0;
        final total = quantity * material.price;
        globalTotal += total;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pedido: ${material.name}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Quantidade: $quantity",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                "Total: ${total}Kz",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const Divider(thickness: 1, color: Colors.grey),
            ],
          ),
        );
      }),
      const SizedBox(height: 10),
      Text(
        "Data de devolução: ${dateController.text}",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      Text(
        "Total Global: ${globalTotal}Kz",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    ],
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Snacbar(String text){
  return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("O NIF deve ter exatamente 14 caracteres")),
    );
}

Widget _sair(){
  return const Column(
    children: [
      Text("Sair", style: TextStyle(
        fontSize: 17
      ),)
    ],
  );
}

  @override
  void initState() {
  super.initState();
  _loadMaterials(); // CHAMA LOGO A FUNÇÃO DE PRIMEIRA
}



//FUNÇÃO QUE CARREGAR OS MATERIAIS DO BANCO
void _loadMaterials() {
  setState(() {
    isloading = true; //ENQUANTO O APP CARREGA ELE MUDA O ESTADO DA VARIAVEL PARA TURE, ASSIM ELE VAI APRESENTAR LOGO O CIRCULAR PROGRESS INDICATOR
  }); 
  final db = MalugaDatabase.instance;
  //db.createTable();
  //db.clearTable("alugos");
  
  /*db.printTableData("alugos").then((_) {
    print("Tabela alugos carregada com sucesso");
  }).catchError((error) {
    print("Error listing tables: $error");
  });*/

  //db.deleteTable("alugos");
  _materials = db.getAllMaterials('materials').then((data) {
    return materials =  data.map((item) => Materialmodel.fromMap(item)).toList();
  }).catchError((error) {
    print("Erro ao carregar materiais: $error");
  }).whenComplete(() {
    setState(() {
      isloading = false; //QUANDO ELE CONCLUIR MUDA O ESTADO PARA FALSO, REMOVENDO ASSIM O CIRCULAR PROGRESS INDICATOR
    });
  });
}

  // Alterna a seleção de um produto
  void _toggleSelection(int materialId, {bool fromCheckbox = false}) {
    setState(() {
      if (fromCheckbox) {
        if (selectedmaterials.contains(materialId)) {
          selectedmaterials.remove(materialId);
          quantidadeController.remove(materialId);
        } else {
          selectedmaterials.add(materialId);
          quantidadeController[materialId] = TextEditingController();
        }
      }
    });
  }

  //FUNÇÃO QUE VERIRICA SE O NIF É VERDADEIRO
  void _nifverify(String nif, void Function(VoidCallback) setDialogState) async {
    isloading = true; 
    //PARTE PARA TESTE
    /*
    final String nome = ValidarNif(nif) as String;
   //O DIALOG É STATEFULL, POR ISSO PODEMOS ALTERAR O ESTADO DOS ELEMENTOS NELE
  setDialogState(() {
      showExtrafields = true; //MUDA O ESTADO DA VARIAVEL PARA TRUE HABILITANDO A APRESENTAÇÃO DE OUTROS CAMPOS
      verification = true;
      namealugadorcontroller.text = nome; // Preenche automaticamente o campo Nome

    });*/

  if (nif.length < 14) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("O NIF deve ter exatamente 14 caracteres")),
    );
  } else {
    setDialogState(() {
      isloading = true; //MOSTRA O PROGRESS INDICATOR PARA PROCESSAR
    });
    String nome = await ValidarNif(nif); //PEGA O NOME COM BASE NO NIF INSERIDO E ARMAZENA O RESULTADO DA CONSULTA NA VAR
    if(nome!="Nome não encontrado"){
      setDialogState(() {
      isloading = false; //APOS CONCLUIR, CASO DÊ CERTO REMOVE O LOADING
      showExtrafields = true; //MUDA O ESTADO DA VARIAVEL PARA TRUE HABILITANDO A APRESENTAÇÃO DE OUTROS CAMPOS
      verification = true;
      namekilapeirocontroller.text = nome; // Preenche automaticamente o campo Nome
      failed = false;
    });
    }else{
      setDialogState(() {
        isloading=false;
        failed=true;
      });
    }
    
  }
}
  /*
  String formatarPreco(double preco) {
    final formatter = NumberFormat('#,##0.00', 'pt_BR'); // Formato brasileiro
    return formatter.format(preco);
  }
  */

void InserirAlugo() async {
  final db = MalugaDatabase.instance;

  // 1. Inserir na tabela "alugos"
  final alugoData = {
    'name_alugador': namekilapeirocontroller.text,
    'nif_alugador': nifcontroller.text,
    'contact_alugador': telefoneController.text,
    'date_alugo': DateTime.now().toIso8601String(),
    'date_return': dateController.text,
    'total_alugo': 0.0, // Vamos calcular depois com base nos itens
    'contract_image': _image?.path,
  };

  // Inserir e obter o ID gerado
  final int idAlugo = await db.insert('alugos', alugoData);

  double totalAlugo = 0.0;

  // 2. Inserir cada item na tabela "alugo_items"
  for (final idMaterial in selectedmaterials) {
    final material = materials.firstWhere((p) => p.id == idMaterial);
    final quantity = int.tryParse(quantidadeController[idMaterial]?.text ?? '0') ?? 0;
    final totalItem = material.price * quantity;
    totalAlugo += totalItem;

    await db.insert('alugo_items', {
      'id_alugo': idAlugo,
      'material': material.name,
      'quantity': quantity,
    });

    // Atualizar stock
    await db.diminuirMaterialQuantidade(idMaterial, quantity);
  }

  // 3. Atualizar o total no registro principal do aluguel
  await db.update('alugos', {'total_alugo': totalAlugo}, where: 'id_alugo = ?', whereArgs: [idAlugo]);

  // 4. Inserir ou atualizar "alugador"
  final alugadorData = {
    'name': namekilapeirocontroller.text,
    'nif': nifcontroller.text,
    'location': enderecoController.text,
    'phone_number': telefoneController.text,
    'classification': 0.0,
  };
  
  await db.insert('alugador', alugadorData);

  // 5. Inserir no "historico"
  final historicoData = {
    'nome': namekilapeirocontroller.text,
    'data': DateTime.now().toIso8601String(),
    'materials': selectedmaterials.join(', '), // Podes usar nomes se quiseres
    'type': 'alugo',
    'total': totalAlugo,
  };
  await db.insert('historico', historicoData);

  // 6. Limpar os campos
  namematerialcontroller.clear();
  descriptioncontroller.clear();
  quantitycontroller.clear();
  nifcontroller.clear();
  telefoneController.clear();
  enderecoController.clear();
  selectedmaterials.clear();
  quantidadeController.clear();
  dateController.clear();
  _image = null;

  // 7. Mostrar mensagem
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Alugo cadastrado com sucesso!"),
      backgroundColor: Colors.green,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    //DIALOG BOX TO REGISTER THE ALUGADOR OU KILAPEIRO
  void dialogoKilapeiroCad() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Kilapar"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: (stepIndex + 1) / steps.length,
                    color: BaseColor,
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(CurrentStep),
                  if(stepIndex==0)_idClientstep(),
                  if(stepIndex==1)_quantidadestep(),
                  if(stepIndex==2) _dateStep(),
                  if(stepIndex==3) _contractStep(),
                  if(stepIndex==4) _Resumo(),
                  if(stepIndex==5) _concluirstep(),
                  if(stepIndex==6) _sair(),
                ],
              ),
            ),
            actions: [
              Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isloading ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.amber),
                ) : const Icon(Icons.pending),

              MyElevatedbutton(
                text: '⬅️',
                action: () {
                  //VERIFICA SE A VERIFICAÇÃO FOI CONCLUIDA OU NÃO PARA ALTERAR A FUNÇÃO DO BOTÃO SEJA VERDADE, QUER DIZER QUE JÁ VERIFICOU E PODE PASSAR PARA O PRÓXIMA PAGINA, CASO NÃO MANDA O NIF PARA A VERIFICAÇÃO
                  if(verification){
                   setDialogState((){
                    _prevStep();
                   });
                  }
                },
              ),
              MyElevatedbutton(
                text: '❌',
                action: () {
                  namematerialcontroller.clear();
                  descriptioncontroller.clear();
                  quantitycontroller.clear();
                  nifcontroller.clear();
                  telefoneController.clear();
                  enderecoController.clear();
                  dateController.clear();
                  Navigator.of(context).pop();
                  showExtrafields=false;
                  stepIndex=0;
                  failed=false;
                  setDialogState((){
                  _image=null;

                  });
                },
              ),
              //IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward)),
               MyElevatedbutton(
                text: '➡️',
                action: () {
                    //VERIFICA SE A VERIFICAÇÃO FOI CONCLUIDA OU NÃO PARA ALTERAR A FUNÇÃO DO BOTÃO SEJA VERDADE, QUER DIZER QUE JÁ VERIFICOU E PODE PASSAR PARA O PRÓXIMA PAGINA, CASO NÃO MANDA O NIF PARA A VERIFICAÇÃO~
                  /*if(stepIndex==0){
                    setDialogState((){
                      showExtrafields=true;
                    });
                  }*/
                  if(verification){
                   setDialogState((){
                    _nextStep();
                   });
                   
                  }else{
                    _nifverify(nifcontroller.text, setDialogState);
                  }
                  if(stepIndex==6){
                    InserirAlugo();
                    Navigator.pop(context); 
                    showExtrafields=false;
                  }
                },
              ),
              ] ,
              ),
              failed ? 
                    const Padding(
                      padding: EdgeInsets.all(0.8),
                      child: Text(
                        "Falhou",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15
                        ),
                      ),
                    ) : const Text(""),
            ]
          );
        },
      );
    },
  );
}
    //DIALOG BOX TO SHOW DE SPECIFICATIONS OF THE MATERIAL
    void dialogoMaterial(String nome, String descricao, int  quantidade, String estado, double preco){
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(nome),
          content: Text(
            " Quantidade: $quantidade \n Descrição: $descricao\n Estado: $estado\n Preço: $preco",
            style: const TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
          actions: [
            MyElevatedbutton(
              text:'Alugar',
              action: (){
                Navigator.of(context).pop();
              }
            ),
            MyElevatedbutton(
              text:'Kilapar',
              action: (){
                Navigator.of(context).pop();
                dialogoKilapeiroCad();
                stepIndex=0;
                print(stepIndex);
              }
            ),
            MyElevatedbutton(
              text:'Editar',
              action: (){
                Navigator.of(context).pop();
              }
            )
            
          ],  
        );

      }
    );
  }
  //FUNÇÃO PARA CADAST((RAR CLIENTES
  void InserirCliente() async{
    final db = MalugaDatabase.instance;

    final dadosCliente = {
      'name':namealugadorcontroller.text,
      'nif':nifcontroller.text,
      'location':enderecoController.text,
      'nif':nifcontroller.text,
      'phone_number':telefoneController.text,
    };
  
    final alugo = {
      'name_kilapeiro':namealugadorcontroller.text,
      'nif_kilapeiro':nifcontroller.text,
      'contact_kilapeiro': telefoneController.text,
      'materials':namealugadorcontroller.text
    };
    
    

    if(namealugadorcontroller.text == '' || nifcontroller.text == '' || descriptioncontroller.text == '' || enderecoController.text == '' || telefoneController.text == ''){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
          "Preencha todos os campos",
          style:  TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.amber,
        ),
      );
    }else{
      await db.insert("kilapeiro", dadosCliente);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Kilapi adicionado com sucesso!"
          ),
          backgroundColor: Colors.green,
        )
      );

      namealugadorcontroller.clear();
      nifcontroller.clear();
      descriptioncontroller.clear();
      enderecoController.clear();
      enderecoController.clear();
      telefoneController.clear();
    }
  }
  ///FUNÇÃO PARA MANDAR OS DADOS PARA O BANCO
  void InserirMaterial() async{
    final db = MalugaDatabase.instance;
      //db.printTableData('materials');
      //PREPARING ALL DATA TO BE SENT TO THE DB
      final material = {
        'name':namematerialcontroller.text,
        'description': descriptioncontroller.text,
        'quantity': quantitycontroller.text,
        'status': statuscontroller.text,
        'price': precocontroller.text
      };

      //VERIFICATIONS TO MAKE SURE ALL THE FIELDS ARE FIELDS
      if(namematerialcontroller.text == '' || descriptioncontroller.text == '' || quantitycontroller.text == '' || statuscontroller.text == '' ||precocontroller.text == ''){
        //MESSAGE TO INFORM THE USER TO FILL ALL THE FIELD
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: 
        Text(
          "Preencha todos os campos",
          style:  TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.amber,
        ),
      );
      } else {
        //IF EVERYTHING IS RIGTH THE DATA IS ADDED
        await db.insert('materials', material);

        //AFTER ADDING, DELETE EVERYTHING IN THE FIELDS
        namematerialcontroller.clear();
        descriptioncontroller.clear();
        quantitycontroller.clear();
        statuscontroller.clear();
        precocontroller.clear();

        //MESSAGE TO INFORM THAT THE DATA WAS INSERT
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: 
        Text(
          "Material adicionado com sucesso!",
          style:  TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.green,
        )
        );
      }
  }
 Future<void> fetchAllProdutos() async {
    final data = await MalugaDatabase.instance.getAllMaterials('materials');
    setState(() {
      materials = data.map((item) => Materialmodel.fromMap(item)).toList();
      pesquisaResults = materials;
    });
  }
  void change(String query){
    setState(() {
      pesquisaResults = materials.where((material) => material.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }
  //DIALOG PARA INSERIR OS DADOS DOS MATERIAIS PRODUTOS AO BANCO
  void AddMaterial() async{
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text("Adicione produtos ao banco", style: TextStyle(
          fontSize: 17
        ),),
        content:SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Mytextfield(hintText: "Nome",Controller: namematerialcontroller,),
              Mytextfield(hintText: "Descrição", Controller: descriptioncontroller,),
              Mytextfield(hintText: "Quantidade", Controller: quantitycontroller,keyboardtype: const TextInputType.numberWithOptions(),),
              Mytextfield(hintText: "Estado", Controller: statuscontroller,),
              Mytextfield(hintText: "Preço", Controller: precocontroller,keyboardtype: const TextInputType.numberWithOptions(),)
            ],
          ),
        ),
        actions:[

          MyElevatedbutton(
            text: "Adicionar", 
            action: (){
              InserirMaterial();
            }
          ),
        ],
        );
      });
      
    }
  
    return FutureBuilder<List<Materialmodel>>(
      future: _materials, 
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(color: BaseColor,),
          );
        }else if(snapshot.hasError){
          return Center(child: Text("ERRO ${snapshot.error}"));
        }else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyMaterial();
        } else {
          final materials_ = snapshot.data!;
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: pesquisaController,
                    onChanged: change,
                    decoration: const InputDecoration(
                      labelText: "Pesquise os materiais",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder()
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: materials_.length,
                    itemBuilder: (context, index) {
                      final material = materials_[index];
                      return GestureDetector(
                        onTap: () {
                          if (!selectedmaterials.contains(material.id)) {
                            dialogoMaterial(material.name, material.description, material.quantity, material.status, material.price);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: BaseColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              title: Text(
                                material.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ForegroundColor,
                                ),
                              ),
                              subtitle: Text(
                                "${material.description} - ${material.price.toString()}Kz",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              trailing: Checkbox(
                                value: selectedmaterials.contains(material.id),
                                onChanged: (isChecked) {
                                  _toggleSelection(material.id, fromCheckbox: true);
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            floatingActionButton: selectedmaterials.isNotEmpty ?  Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(onPressed: (){dialogoKilapeiroCad();},backgroundColor:BaseColor, child: const Icon(Icons.send,color: ForegroundColor,),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(onPressed: (){},backgroundColor:BaseColor, child: const Icon(Icons.takeout_dining,color: ForegroundColor,),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(onPressed: (){AddMaterial();},backgroundColor:BaseColor, child: const Icon(Icons.edit,color: ForegroundColor,),),
                ),
              ],
            ) : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(onPressed: (){AddMaterial();},backgroundColor:BaseColor, child: const Icon(Icons.add,color: ForegroundColor,),),
                ),
          );
          }
        }
    );
  }
    
}
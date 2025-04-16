
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
  @override
  Widget build(BuildContext context) {
    TextEditingController namecontroller = TextEditingController();
    TextEditingController descriptioncontroller = TextEditingController();
    TextEditingController statuscontroller = TextEditingController();
    TextEditingController pricocontroller = TextEditingController();
    TextEditingController  quantitycontroller = TextEditingController();

    void AddMaterial() async{
      final db = MalugaDatabase.instance;
      //db.printTableData('materials');
      //PREPARING ALL DATA TO BE SENT TO THE DB
      final material = {
        'name':namecontroller.text,
        'description': descriptioncontroller.text,
        'quantity': quantitycontroller.text,
        'status': statuscontroller.text,
        'price': pricocontroller.text
      };

      //VERIFICATIONS TO MAKE SURE ALL THE FIELDS ARE FIELDS
      if(namecontroller.text == '' || descriptioncontroller.text == '' || quantitycontroller.text == '' || statuscontroller.text == '' ||pricocontroller.text == ''){
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
        namecontroller.clear();
        descriptioncontroller.clear();
        quantitycontroller.clear();
        statuscontroller.clear();
        pricocontroller.clear();

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
        ),
      );
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Adicionar Material",
          style: TextStyle(
            color: ForegroundColor,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: BaseColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Mytextfield(hintText: "nome", Controller: namecontroller),
              Mytextfield(hintText: "Descrição", Controller: descriptioncontroller),
              Mytextfield(hintText: "Quantidade", Controller: quantitycontroller),
              Mytextfield(hintText: "Estado", Controller: statuscontroller),
              Mytextfield(hintText: "Preço", Controller: pricocontroller),
              MyElevatedbutton(
                text: "Adicionar",
                action: (){
                  AddMaterial();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (build)=> const Menu()));
                }
              )
            ],
          )
        ),
      ),
    );
  }
}
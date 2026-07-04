import 'package:flutter/material.dart';
import 'package:flutter_/Components/MyElevatedButton.dart';
import 'package:flutter_/pages/AddThing.dart';
import 'package:flutter_/pages/ListThing.dart';
import 'package:flutter_/pages/PendingPage.dart';

class WellcomePage extends StatelessWidget {
  const WellcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Seja bem vindo",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
            ),
            MyElevatedbutton(
              text: "Cadastrar Material", 
              action: (){
                Navigator.push(context, MaterialPageRoute(builder: (build)=> const AddThingPage()));
              }
            ),
            MyElevatedbutton(
              text: "Listar materiais", 
              action: (){Navigator.push(context, MaterialPageRoute(builder: (build) => const ListThing()));}
            ),
            MyElevatedbutton(
              text: "Verificar Pendentes", 
              action: (){Navigator.push(context, MaterialPageRoute(builder: (build) => const PendingPage()));}
            )
          ],
        ),
      ),
    );
  }
}
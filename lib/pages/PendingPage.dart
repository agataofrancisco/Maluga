import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';
import 'package:flutter_/Components/MyElevatedButton.dart';
import 'package:flutter_/pages/ListThing.dart';

class PendingPage extends StatelessWidget {
  const PendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    void dialogo(){
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text("Alugos pendentes"),
          content: const Text("5 PAINEIS"),
          actions: [
            MyElevatedbutton(text: "Devolvido", action: (){Navigator.of(context).pop();})
          ], 
        );

      }
    );
  }
    return Scaffold(
      /*appBar: AppBar(
        title: Text(
          "Pendentes",
          style: TextStyle(
            color: ForegroundColor,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: BaseColor,
      ),*/
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Alugos",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            
        
              /////////////////////////////////////
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: BaseColor,
                  ),
                  child: ListTile(
                    title: const Text(
                      "Tia Bela",
                      style: TextStyle(
                        color: ForegroundColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      dialogo();
                    },
                  ),
                ),
              ),
        
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: BaseColor,
                  ),
                  child: ListTile(
                    title: const Text(
                      "Gelson",
                      style: TextStyle(
                        color: ForegroundColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      dialogo();
                    },
                  ),
                ),
              ),
        
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: BaseColor,
                  ),
                  child: ListTile(
                    title: const Text(
                      "Alexandrina",
                      style: TextStyle(
                        color: ForegroundColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      dialogo();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: BaseColor,
                  ),
                  child:ListTile(
                    title: const Text(
                      "Agatão",
                      style: TextStyle(
                        color: ForegroundColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      dialogo();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: BaseColor,
                  ),
                  child:ListTile(
                    title: const Text(
                      "Agatão",
                      style: TextStyle(
                        color: ForegroundColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      dialogo();
                    },
                  ),
                ),
              ),              
        
              const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Kilapis",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: BaseColor,
                  ),
                  child: const ListTile(
                    title: Text(
                      "Maria",
                      style: TextStyle(
                        color: ForegroundColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: BaseColor,
                  ),
                  child:ListTile(
                    title: const Text(
                      "Agatão",
                      style: TextStyle(
                        color: ForegroundColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      dialogo();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: BaseColor,
                  ),
                  child:ListTile(
                    title: const Text(
                      "Agatão",
                      style: TextStyle(
                        color: ForegroundColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      dialogo();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: BaseColor,
                  ),
                  child:ListTile(
                    title: const Text(
                      "Agatão",
                      style: TextStyle(
                        color: ForegroundColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      dialogo();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: BaseColor,
                  ),
                  child:ListTile(
                    title: const Text(
                      "Agatão",
                      style: TextStyle(
                        color: ForegroundColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      dialogo();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: BaseColor,
                  ),
                  child:ListTile(
                    title: const Text(
                      "Agatão",
                      style: TextStyle(
                        color: ForegroundColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      dialogo();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
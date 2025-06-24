import 'package:flutter/material.dart';
import 'package:flutter_/Components/Card_Feed.dart';
import 'package:flutter_/Components/MyElevatedButton.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context){
    void dialogo_(){
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text("Paineis"),
            content: const Text("ACÇÃO A REALIZAR"),
            actions: [
              MyElevatedbutton(text: "ADICIONAR", action: (){
                Navigator.of(context).pop();
              })
            ],
          );
        }
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                dialogo_();
              },
              child: const CardFeed(
                name: "Paineis",
                price: 200,
                location: "Morro Bento",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                dialogo_();
              },
              child: const CardFeed(
                name: "Paineis",
                price: 200,
                location: "Morro Bento",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                dialogo_();
              },
              child: const CardFeed(
                name: "Paineis",
                price: 200,
                location: "Morro Bento",
              ),
            ),
          ),
        ],
      )
    );
  }
}
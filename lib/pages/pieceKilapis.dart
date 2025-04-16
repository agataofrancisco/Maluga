/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';
import 'package:flutter_/db/Database.dart';
import 'package:flutter_/db/Models/alugo_model.dart';
import 'package:flutter_/pages/empty/EmptyAlugo.dart';
class PieceKilapis extends StatefulWidget {
  const PieceKilapis({super.key});
  @override
  State<PieceKilapis> createState() => _PieceKilapisState();
}

class _PieceKilapisState extends State<PieceKilapis> {

  List <KilapiModel> kilapis = [];
  late  Future<List<KilapiModel>> _kilapis;

  	void loadMaterials(){
      final db = MalugaDatabase.instance;
      _kilapis = db.getAllData("alugos", "date_kilapi").then((data){
        return kilapis = data.map((item) => KilapiModel.fromMap(item)).toList();
      }).catchError((error){
        print("erro ao carregar os dados: $error");
      });
    }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadMaterials();    
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<KilapiModel>>(
      future: _kilapis,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(color: BaseColor,),
          );
        }else if (snapshot.hasError){
          return Center(child: Text("erro: ${snapshot.error}"),);
        }else if(snapshot.hasData || snapshot.data!.isEmpty){
          return const Emptyalugo();
        }else{
          final kilapis_ = snapshot.data!;
          return Scaffold(
            body: Expanded(
              child: ListView.builder(
                itemCount: kilapis_.length,
                itemBuilder: (context
                , index){
                  final kilapi = kilapis_[index];
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color:BaseColor
                        ),
                        child: GestureDetector(
                          child: ListTile(
                            title: Text(kilapi.nameKilapeiro,
                            style: TextStyle(
                            color: ForegroundColor,
                            fontWeight: FontWeight.bold
                          ),
                          ),
                          trailing: Text(kilapi.datereturn.toString() ),
                          onTap: (){
                            print("ticado");
                          },
                          ),
                        ),
                      )
                    ],
                  );
                },
              )
            ),
          );
        }
      }
    );
  }
}*/
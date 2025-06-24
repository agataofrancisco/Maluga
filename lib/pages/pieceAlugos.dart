import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';
import 'package:flutter_/db/Database.dart';
import 'package:flutter_/db/Models/alugo_model.dart';
import 'package:flutter_/pages/empty/EmptyAlugo.dart';
class PieceAlugos extends StatefulWidget {
  const PieceAlugos({super.key});
  @override
  State<PieceAlugos> createState() => _PieceAlugosState();
}

class _PieceAlugosState extends State<PieceAlugos> {

  List <AlugoModel> alugos = [];
  late  Future<List<AlugoModel>> _alugos;

  	void loadMaterials(){
      final db = MalugaDatabase.instance;
      _alugos = db.getAllData("alugos", "date_alugo").then((data){
        return alugos = data.map((item) => AlugoModel.fromMap(item)).toList();
      }).catchError((error){
        print("erro ao carregar os dados: $error");
      });
    }
  @override
  void initState() {
    super.initState();
    loadMaterials();    
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AlugoModel>>(
      future: _alugos,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(color: BaseColor,),
          );
        }else if (snapshot.hasError){
          return Center(child: Text("erro:${snapshot.error}"),);
        }else if(snapshot.hasData || snapshot.data!.isEmpty){
          return const Emptyalugo();
        }else{
          final Alugos_ = snapshot.data!;
          return Scaffold(
            body: Expanded(
              child: ListView.builder(
                itemCount: Alugos_.length,
                itemBuilder: (context,
                index){
                  final Alugo = Alugos_[index];
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color:BaseColor
                        ),
                        child: GestureDetector(
                          child: ListTile(
                            title: Text(Alugo.name_alugador,
                            style: const TextStyle(
                            color: ForegroundColor,
                            fontWeight: FontWeight.bold
                          ),
                          ),
                          trailing: Text(Alugo. date_return.toString() ),
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
}
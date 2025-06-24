import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';
import 'package:flutter_/pages/ListThing.dart';
import 'package:flutter_/pages/PendingPage.dart';
import 'package:flutter_/pages/ProfilePage.dart';
import 'package:flutter_/pages/pieceAlugos.dart';
import 'package:flutter_/pages/pieceKilapis.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: BaseColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: const Row(
                  children: [
                    //Image.asset("lib/assets/logoMaluga4Semfundo.png", width: 50, height: 50,),
                    SizedBox(width: 5,),
                    Text(
                      "Maluga",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ForegroundColor
                      ),
                    ),
                  ],
                ),
              ),
        
              Container(child: Row(
                children: [
                  ElevatedButton.icon(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (build) => const ProfilePage()));}, label: const Icon(Icons.person, color: BaseColor,)),
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: IconButton(onPressed: (){}, icon: const Icon(Icons.notifications, color: ForegroundColor,)),
                  )
                ],
              )),
              //Icon(Icons.person)
            ],
          ),
          bottom: const TabBar(
            tabs:<Widget>[
                Center(
                  child: Icon(Icons.list_outlined,color: ForegroundColor,size: 30,)
                ),
                /*
                Center(
                  child: Icon(Icons.note_add_outlined,color: ForegroundColor,size: 30,)
                ),
                */
                Center(
                  child: Icon(Icons.pending_outlined,color: ForegroundColor,size: 30,)
                ),
                /*
                Center(
                  child: Icon(Icons.feed_outlined,color: ForegroundColor,size: 30,)
                ),
                */
          ]),
        ),
        body: const TabBarView(children: <Widget>[
          ListThing(),
          //AddThingPage(),
          PieceAlugos()
          //PieceKilapis()
          //PendingPage(),
          //FeedPage()
        ]),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_/pages/ListThing.dart';
import 'package:flutter_/pages/ProfilePage.dart';
import 'package:flutter_/pages/pieceAlugos.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Maluga'),
          actions: [
            IconButton(
              tooltip: 'Perfil',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              icon: const Icon(Icons.person_outline),
            ),
            IconButton(
              tooltip: 'Notificações',
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
            const SizedBox(width: 4),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Materiais'),
              Tab(icon: Icon(Icons.handshake_outlined), text: 'Alugueres'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ListThing(),
            PieceAlugos(),
          ],
        ),
      ),
    );
  }
}

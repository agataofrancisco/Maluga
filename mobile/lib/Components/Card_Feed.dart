import 'package:flutter/material.dart';
import 'package:flutter_/Components/Colors.dart';

class CardFeed extends StatelessWidget {
  final int price;
  final String name;
  final String location;
  
  const CardFeed({super.key, required this.price, required this.name, required this.location});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * .85,
          height: MediaQuery.of(context).size.height *.5,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              style: BorderStyle.solid,
              color: BaseColor,
            ),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            children: [
              const Center(child: Icon(Icons.ice_skating,size: 300,)),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25
                ),
              ),
              Text(
                price.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              Text(
                location,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
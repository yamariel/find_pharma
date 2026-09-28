import 'package:flutter/material.dart';

class PharmaciesPage extends StatelessWidget{
  const PharmaciesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pharmacie"),),
      body: Center(child: Text("Pharmacies Page"),
    ));
  }
}
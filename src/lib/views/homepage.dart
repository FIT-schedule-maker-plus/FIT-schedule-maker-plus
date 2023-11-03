// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FIT Schedule Maker+'),
        backgroundColor: Color.fromARGB(255, 212, 212, 212),
      ),
      body: Column(children: []),
    );
  }
}

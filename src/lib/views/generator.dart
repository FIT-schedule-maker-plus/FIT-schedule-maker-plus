// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Generator extends StatelessWidget {
  final AnimationController animationController;
  final Animation<Offset> ofssetAnimation;
  const Generator({required this.animationController, required this.ofssetAnimation, super.key});

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: ofssetAnimation,
      child: Container(
        // color: Colors.black.withOpacity(0.8),
        width: 300,
        height: double.infinity,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            offset: Offset(10.0, 0.0), // Shadow on the left side
            blurRadius: 6.0,
            spreadRadius: 6.0,
          ),
        ]),
        padding: EdgeInsets.only(right: 16.0, left: 16, top: 10, bottom: 20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => animationController.reverse(),
                  icon: Icon(Icons.keyboard_arrow_right),
                  color: Colors.white,
                  tooltip: "Hide",
                ),
                Expanded(
                  child: Text(
                    "Generátor rozvrhu",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Expanded(child: Container()),
            ElevatedButton(
                onPressed: () {
                  animationController.reverse();
                },
                child: Text("Generovat"))
          ],
        ),
      ),
    );
  }
}

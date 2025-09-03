import 'package:flutter/material.dart';

class Backgroud extends StatelessWidget {
  const Backgroud({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        child: Image.asset('assets/images/Hinhnen.jpg', fit: BoxFit.cover),
      ),
    );
  }
}

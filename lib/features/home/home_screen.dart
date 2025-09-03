import 'package:dovui/features/home/widgets/hometile.dart';
import 'package:dovui/widgets/background.dart';
import 'package:dovui/widgets/button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Backgroud(),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: size.width * 0.08,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hometile(),
                    ButtonCustom(title: 'Bắt đầu thôi',),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

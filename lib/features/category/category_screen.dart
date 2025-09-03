import 'package:dovui/app/utils/const.dart';
import 'package:dovui/widgets/background.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Backgroud(),
            Container(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: getWidth(context) * 0.04,vertical: getHeight(context) * 0.02),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2
              ),
              itemCount: 16,
              itemBuilder: (BuildContext context, int index){
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.primaries[index],
                  ),
                   child: Align(
                    child: Text('Item + $index'),
                   ),
                );
              }),
          ),
          ]
        ),
      ),
    );
  }
}
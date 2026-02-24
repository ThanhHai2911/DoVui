import 'package:flutter/material.dart';

class CategoriesItem extends StatelessWidget {
  final String title;
  final String image;

  const CategoriesItem({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error, color: Colors.red);
            },
          ),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}

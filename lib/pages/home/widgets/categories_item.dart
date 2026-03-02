import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/pages/it_topic/topic_screen.dart';
import 'package:dovui/pages/level/level_screen.dart';
import 'package:dovui/pages/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';

class CategoriesItem extends StatelessWidget {
  final String title;
  final String image;
  final String categoryId;
  final String type;

  const CategoriesItem({
    super.key,
    required this.title,
    required this.image,
    required this.categoryId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (type == "kythuat") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ITTopicScreen(categoryId: categoryId),
            ),
          );
        } else if (type == "level") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Levelscreen(categoryId: categoryId, type: type),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizScreen(categoryId: categoryId, type: type),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.cardColor,
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
            Text(title, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

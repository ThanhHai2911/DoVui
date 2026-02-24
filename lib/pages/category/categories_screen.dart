import 'package:dovui/pages/home/widgets/categories_item.dart';
import 'package:flutter/material.dart';

class Categoriesscreen extends StatelessWidget {
  const Categoriesscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Center(
              child: Text(
                "Thể loại",
                style: TextStyle(
                  color: Color(0xff2E2B72),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.95,
                  children: const [
                    CategoriesItem(
                      title: "Âm nhạc",
                      image: "assets/images/nhac.png",
                    ),
                    CategoriesItem(
                      title: "Đố mẹo",
                      image: "assets/images/dovui.png",
                    ),
                    CategoriesItem(
                      title: "Đố vui",
                      image: "assets/images/nao.png",
                    ),
                    CategoriesItem(title: "IT", image: "assets/images/it.png"),
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

import 'package:flutter/material.dart';
import 'categories_item.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Thể loại",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1,
          children: [
            CategoriesItem(title: "Đố mẹo", image: "assets/images/dovui.png", categoryId: "domeo",),
            CategoriesItem(title: "Đố vui", image: "assets/images/nao.png",  categoryId: "dovui",),
            CategoriesItem(title: "IT", image: "assets/images/it.png", categoryId: "it",),
            CategoriesItem(title: "Âm nhạc", image: "assets/images/nhac.png", categoryId: "amnhac",),
          ],
        ),
      ],
    );
  }
}

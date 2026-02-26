import 'package:dovui/pages/category/widgets/category_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:dovui/models/category_model.dart';
import 'categories_item.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryModel>>(
      stream: QuizService.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const CategoryShimmer();
        }

        final categories = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thể loại",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];

                return CategoriesItem(
                  title: category.name,
                  image: category.image,
                  categoryId: category.id,
                  type: category.type, 
                );
              },
            ),
          ],
        );
      },
    );
  }
}

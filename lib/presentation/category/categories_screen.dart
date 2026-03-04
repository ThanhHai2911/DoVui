import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/data/models/category_model.dart';
import 'package:dovui/presentation/category/bloc/categori_even.dart';
import 'package:dovui/presentation/category/bloc/category_bloc.dart';
import 'package:dovui/presentation/category/widgets/category_shimmer.dart';
import 'package:dovui/presentation/home/widgets/categories_item.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Categoriesscreen extends StatelessWidget {
  const Categoriesscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryBloc()..add(LoadCategories()),
      child: Scaffold(
        backgroundColor: ColorManager.scaffoldBackground,
        body: SafeArea(
          child: StreamBuilder<List<CategoryModel>>(
            stream: QuizService.getCategories(),
            builder: (context, snapshot) {
              final bool isLoading =
                  snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty;

              final categories = snapshot.data ?? [];

              return Column(
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "Thể loại",
                      style: TextStyle(
                        color: ColorManager.primaryDark,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child:
                          isLoading
                              ? const CategoryShimmer() // chỉ shimmer grid
                              : GridView.builder(
                                itemCount: categories.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 20,
                                      crossAxisSpacing: 20,
                                      childAspectRatio: 0.95,
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
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

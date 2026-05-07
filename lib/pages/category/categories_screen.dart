import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/data/repositories/firebase_quiz_repository.dart';
import 'package:dovui/pages/category/bloc/category_state.dart';
import 'package:dovui/pages/category/widgets/animated_category_item.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/data/models/category_model.dart';
import 'package:dovui/pages/category/bloc/categori_even.dart';
import 'package:dovui/pages/category/bloc/category_bloc.dart';
import 'package:dovui/pages/category/widgets/category_shimmer.dart';
import 'package:dovui/pages/home/widgets/categories_item.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Categoriesscreen extends StatefulWidget {
  const Categoriesscreen({super.key});

  @override
  State<Categoriesscreen> createState() => _CategoriesscreenState();
}

class _CategoriesscreenState extends State<Categoriesscreen>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  late AnimationController _floatCtrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _float = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _entryCtrl.forward();
    AudioManager().init().then((_) {
      AudioManager().playBackgroundMusic();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 390;

    double sp(double size) => size * scale;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: BlocProvider(
        create:
            (_) =>
                CategoryBloc(quizService: QuizService(FirebaseQuizRepository()))
                  ..add(LoadCategories()),
        child: Scaffold(
          backgroundColor: ColorManager.scaffoldBackground,
          body: Stack(
            children: [
              /// ===== BACKGROUND BLOBS =====
              AnimatedBuilder(
                animation: _float,
                builder: (_, __) {
                  return Stack(
                    children: [
                      Positioned(
                        top: -40 + _float.value,
                        left: -40,
                        child: _blob(180, const Color(0xFF6C63FF), 0.08),
                      ),
                      Positioned(
                        bottom: 120 - _float.value,
                        right: -30,
                        child: _blob(150, const Color(0xFFFF6584), 0.07),
                      ),
                    ],
                  );
                },
              ),

              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: SafeArea(
                    child: BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (context, state) {
                        final bool isLoading =
                            state is CategoryLoading ||
                            state is CategoryInitial;
                        final categories =
                            state is CategoryLoaded
                                ? state.categories
                                : <CategoryModel>[];

                        return Column(
                          children: [
                            SizedBox(height: sp(20)),

                            /// ===== TITLE =====
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  colors: [
                                    Color(0xFF6C63FF),
                                    Color(0xFF9B8FFF),
                                  ],
                                ).createShader(bounds);
                              },
                              child: Text(
                                "Thể loại",
                                style: TextStyle(
                                  fontSize: sp(36),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            SizedBox(height: sp(30)),

                            /// ===== GRID =====
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(sp(20)),
                                child:
                                    isLoading
                                        ? const CategoryShimmer()
                                        : GridView.builder(
                                          itemCount: categories.length,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                mainAxisSpacing: sp(20),
                                                crossAxisSpacing: sp(20),
                                                childAspectRatio:
                                                    screenWidth < 360
                                                        ? 0.9
                                                        : 0.95,
                                              ),
                                          itemBuilder: (context, index) {
                                            final category = categories[index];

                                            return AnimatedCategoryItem(
                                              index: index,
                                              child: CategoriesItem(
                                                title: category.name,
                                                image: category.image,
                                                categoryId: category.id,
                                                type: category.type,
                                              ),
                                            );
                                          },
                                        ),
                              ),
                            ),
                            const SizedBox(height: 70),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}

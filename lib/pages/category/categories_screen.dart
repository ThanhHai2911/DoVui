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

    _fade = CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _float = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _entryCtrl.forward();
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

    return BlocProvider(
      create: (_) => CategoryBloc()..add(LoadCategories()),
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
                  child: StreamBuilder<List<CategoryModel>>(
                    stream: QuizService.getCategories(),
                    builder: (context, snapshot) {

                      final bool isLoading =
                          snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty;

                      final categories = snapshot.data ?? [];

                      return Column(
                        children: [

                          SizedBox(height: sp(20)),

                          /// ===== TITLE =====
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [
                                  Color(0xFF6C63FF),
                                  Color(0xFF9B8FFF)
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
                              child: isLoading
                                  ? const CategoryShimmer()
                                  : GridView.builder(
                                      itemCount: categories.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: sp(20),
                                            crossAxisSpacing: sp(20),
                                            childAspectRatio:
                                                screenWidth < 360 ? 0.9 : 0.95,
                                          ),
                                      itemBuilder: (context, index) {

                                        final category = categories[index];

                                        return _AnimatedCategoryItem(
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

class _AnimatedCategoryItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedCategoryItem({
    required this.child,
    required this.index,
  });

  @override
  State<_AnimatedCategoryItem> createState() => _AnimatedCategoryItemState();
}

class _AnimatedCategoryItemState extends State<_AnimatedCategoryItem>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
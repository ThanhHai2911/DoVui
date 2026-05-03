import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/ads/widgets/adsService.dart';
import 'package:dovui/pages/home/widgets/animated_section.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/pages/home/bloc/home_bloc.dart';
import 'package:dovui/pages/home/bloc/home_event.dart';
import 'package:dovui/pages/home/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/home_header.dart';
import 'widgets/streak_card.dart';
import 'widgets/quiz_of_week.dart';
import 'widgets/categories_section.dart';
import 'widgets/home_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _float = Tween<double>(
      begin: -12,
      end: 12,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _entryCtrl.forward();

    AudioManager().init().then((_) {
      AudioManager().playBackgroundMusic();
    });

    if (AdsService().isVip) return;
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: BlocProvider(
        create: (_) => HomeBloc()..add(LoadHome()),
        child: Scaffold(
          backgroundColor: ColorManager.scaffoldBackground,
          body: Stack(
            children: [
              AnimatedBuilder(
                animation: _float,
                builder: (_, __) {
                  return Stack(
                    children: [
                      Positioned(
                        top: -60 + _float.value,
                        left: -40,
                        child: _blob(200, const Color(0xFF6C63FF), 0.07),
                      ),
                      Positioned(
                        top: 260 - _float.value,
                        right: -50,
                        child: _blob(160, const Color(0xFFFF6584), 0.06),
                      ),
                      Positioned(
                        bottom: 120 + _float.value,
                        left: -40,
                        child: _blob(150, const Color(0xFF43C6AC), 0.06),
                      ),
                    ],
                  );
                },
              ),

              SafeArea(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) return const HomeShimmer();

                    if (state is HomeLoaded) {
                      final size = MediaQuery.sizeOf(context);
                      return FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              size.width * 0.06,
                              0,
                              size.width * 0.06,
                              70,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                const HomeHeader(),
                                const SizedBox(height: 25),
                                AnimatedSection(
                                  delay: 0,
                                  child: StreakCard(
                                    days: state.days,
                                    name: state.name,
                                    score: state.score,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const AnimatedSection(
                                  delay: 120,
                                  child: QuizOfWeek(),
                                ),
                                const SizedBox(height: 30),
                                const AnimatedSection(
                                  delay: 240,
                                  child: CategoriesSection(),
                                ),
                                const SizedBox(height: 30),

                                if (!state.isVip) ...[
                                  Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6C63FF),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "Quảng cáo",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E1B4B),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const RepaintBoundary(
                                    child: NativeAdWidget(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return const SizedBox();
                  },
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
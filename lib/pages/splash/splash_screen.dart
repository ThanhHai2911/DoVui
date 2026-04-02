import 'dart:async';
import 'dart:math';
import 'package:dovui/pages/user/login_screen.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/pages/home/widgets/home_bottom_nav.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:dovui/pages/user/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _floatController;
  late AnimationController _progressController;

  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _floatAnim;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    /// Logo pop animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _logoController.forward();

    /// Float animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    /// Progress animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _progressAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _progressController.forward();

    /// Check user after splash
    Future.delayed(const Duration(seconds: 2), () {
      context.read<UserBloc>().add(CheckUserEvent());
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _floatController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserRegistered) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeBottomNav()),
            );
          }

          if (state is UserNotRegistered) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        child: Stack(
          children: [
            /// Animated Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE6F0FA),
                    Color(0xFFDDE8FF),
                    Color(0xFFEAF3FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            /// Floating particles
            const _Particles(),

            /// Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Floating logo
                      AnimatedBuilder(
                        animation: _floatAnim,
                        builder: (_, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnim.value),
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 25,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              "assets/images/logo.png",
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        "ĐỐ VUI",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.primaryDark,
                          letterSpacing: 4,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Animated progress bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 80),
                        child: AnimatedBuilder(
                          animation: _progressAnim,
                          builder: (_, __) {
                            return LinearProgressIndicator(
                              value: _progressAnim.value,
                              minHeight: 6,
                              backgroundColor: Colors.white70,
                              valueColor: const AlwaysStoppedAnimation(
                                ColorManager.primaryDark,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Đang tải dữ liệu...",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Particles extends StatefulWidget {
  const _Particles();

  @override
  State<_Particles> createState() => _ParticlesState();
}

class _ParticlesState extends State<_Particles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose(); // 🔥 QUAN TRỌNG
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          children: List.generate(15, (index) {
            final size = random.nextDouble() * 12 + 6;
            final dx = random.nextDouble() * MediaQuery.of(context).size.width;
            final dy = random.nextDouble() * MediaQuery.of(context).size.height;

            return Positioned(
              left: dx,
              top: dy - (_controller.value * 80),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

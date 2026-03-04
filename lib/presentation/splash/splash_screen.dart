import 'dart:async';
import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/presentation/home/widgets/home_bottom_nav.dart';
import 'package:dovui/presentation/user/bloc/user_bloc.dart';
import 'package:dovui/presentation/user/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Sau 2s thì check user từ Firebase
    Future.delayed(const Duration(seconds: 2), () {
      context.read<UserBloc>().add(CheckUserEvent());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserRegistered) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeBottomNav(),
              ),
            );
          }

          if (state is UserNotRegistered) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const RegisterScreen(),
              ),
            );
          }
        },
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "ĐỐ VUI",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.primaryDark,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorManager.primaryDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
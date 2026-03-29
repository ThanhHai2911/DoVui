import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/pages/home/widgets/home_bottom_nav.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveRegisterFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isRegistered", true);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showGameDialog(
      context: context,
      icon: "👤",
      iconColor: Colors.orange,
      title: "Tên đã được sử dụng",
      description:
          "Tên người dùng đã tồn tại trong hệ thống.\nVui lòng chọn tên khác để tiếp tục!",
      costIcon: "✏️",
      costText: "Thử tên khác",
      confirmText: "Đồng ý",
      confirmColor: Colors.orange,
      showCancel: false,
      onConfirm: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) async {
          if (state is UserRegistered) {
            try {
              final userCredential =
                  await FirebaseAuth.instance.signInAnonymously();

              final uid = userCredential.user!.uid;

              await FirebaseFirestore.instance.collection('users').doc(uid).set(
                {
                  'name': state.user.name,
                  'createdAt': FieldValue.serverTimestamp(),
                },
              );

              await _saveRegisterFlag();

              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeBottomNav()),
              );
            } catch (e) {
              print("ERROR $e");
            }
          }

          if (state is UserError) {
            _showErrorDialog(context, state.message);
          }
        },

        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE6F0FA), Color(0xFFDDE8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          child: Stack(
            children: [
              /// background blob
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),

              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),

              /// MAIN CONTENT
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      final isLoading = state is UserLoading;

                      return TweenAnimationBuilder(
                        tween: Tween(begin: 0.9, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },

                        child: Form(
                          key: _formKey,

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /// ICON FLOAT
                              AnimatedBuilder(
                                animation: _floatAnim,
                                builder: (_, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _floatAnim.value),
                                    child: child,
                                  );
                                },
                                child: const Text(
                                  "🎮",
                                  style: TextStyle(fontSize: 60),
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "Nhập tên của bạn",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// TEXT FIELD
                              TextFormField(
                                controller: controller,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: "Ví dụ: Hải mê vui",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Vui lòng nhập tên";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              /// BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 55,

                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorManager.primaryColor,
                                    disabledBackgroundColor:
                                        Colors.grey.shade400,
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),

                                  onPressed:
                                      isLoading
                                          ? null
                                          : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              context.read<UserBloc>().add(
                                                RegisterUserEvent(
                                                  controller.text.trim(),
                                                ),
                                              );
                                            }
                                          },

                                  child:
                                      isLoading
                                          ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: ColorManager.cardColor,
                                            ),
                                          )
                                          : const Text(
                                            "Bắt đầu",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: ColorManager.cardColor,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

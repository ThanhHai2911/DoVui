import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/presentation/home/widgets/home_bottom_nav.dart';
import 'package:dovui/presentation/user/bloc/user_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _saveRegisterFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isRegistered", true);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Thông báo"),
          content: Text(message),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocListener<UserBloc, UserState>(
          listener: (context, state) async {
            /// ✅ Đăng ký thành công
            if (state is UserRegistered) {
              try {
                final userCredential =
                    await FirebaseAuth.instance.signInAnonymously();

                final uid = userCredential.user!.uid;

                print("✅ UID: $uid");

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .set({
                      'name': state.user.name,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                await _saveRegisterFlag();

                if (!mounted) return;

                print("➡️ NAVIGATE"); // 👈 check dòng này

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeBottomNav()),
                );
              } catch (e) {
                print("❌ ERROR: $e");
              }
            }

            /// 🔥 Tên đã tồn tại hoặc lỗi khác
            if (state is UserError) {
              _showErrorDialog(context, state.message);
            }
          },
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              final isLoading = state is UserLoading;

              return Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Nhập tên của bạn",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Ví dụ: Hải",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Vui lòng nhập tên";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.primaryColor,
                          disabledBackgroundColor: Colors.grey.shade400,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<UserBloc>().add(
                                      RegisterUserEvent(controller.text.trim()),
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
              );
            },
          ),
        ),
      ),
    );
  }
}

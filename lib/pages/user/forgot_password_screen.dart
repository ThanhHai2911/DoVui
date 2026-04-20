import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/pages/user/login_screen.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Extracted widgets:
import 'widgets/auth_widgets.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  bool _isCheckingEmail = false;
  bool _emailFound = false;
  bool _isSubmitting = false;
  String? _emailError;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _emailController.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    setState(() { _emailError = null; _emailFound = false; });
    _debounce?.cancel();
    final email = value.trim();
    if (email.isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 600), () => _checkEmailExists(email));
  }

  Future<void> _checkEmailExists(String email) async {
    setState(() => _isCheckingEmail = true);
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (!mounted) return;
      setState(() {
        _emailFound = query.docs.isNotEmpty;
        _emailError = query.docs.isEmpty ? 'Email không tồn tại' : null;
        _isCheckingEmail = false;
      });
    } catch (_) {
      setState(() { _emailError = 'Lỗi kết nối'; _isCheckingEmail = false; });
    }
  }

  Future<void> _onSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) { setState(() => _emailError = 'Vui lòng nhập email'); return; }
    if (!_emailFound) { setState(() => _emailError = 'Email không tồn tại'); return; }

    setState(() => _isSubmitting = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showSuccessDialog();
    } catch (_) {
      setState(() => _emailError = 'Không thể gửi email');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AuthSuccessDialog(
        title: 'Gửi email thành công!',
        message: 'Một email đặt lại mật khẩu đã được gửi.\nVui lòng kiểm tra email của bạn.',
        buttonLabel: 'Đăng nhập ngay',
        onConfirm: () {
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        },
      ),
    );
  }

  Widget _buildSuffixIcon() {
    if (_isCheckingEmail) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C63FF))),
      );
    }
    if (_emailFound) return const Icon(Icons.check_circle_outline, color: Color(0xFF43C6AC), size: 20);
    if (_emailError != null) return const Icon(Icons.cancel_outlined, color: Color(0xFFFF6584), size: 20);
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              const AuthBackgroundBlobs(),
              Column(
                children: [
                  // AppBar custom
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1E1B4B)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text('Đặt lại mật khẩu',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                      child: TweenAnimationBuilder(
                        tween: Tween(begin: 0.95, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        builder: (_, value, child) => Transform.scale(scale: value, child: child),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FloatingEmojiIcon(
                              floatAnim: _floatAnim,
                              emoji: '🔑',
                              bgColor: const Color(0xFF6C63FF).withOpacity(0.1),
                              borderColor: const Color(0xFF6C63FF).withOpacity(0.2),
                            ),
                            const SizedBox(height: 24),
                            const Text('Quên mật khẩu?',
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                            const SizedBox(height: 6),
                            Text('Nhập email để đặt lại mật khẩu',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                            const SizedBox(height: 32),

                            const AuthFieldLabel('Email'),
                            const SizedBox(height: 8),
                            AuthTextFieldTriState(
                              controller: _emailController,
                              hint: 'Vui lòng nhập email',
                              icon: Icons.person_outline_rounded,
                              errorText: _emailError,
                              isSuccess: _emailFound,
                              suffix: _buildSuffixIcon(),
                              onChanged: _onEmailChanged,
                            ),

                            const SizedBox(height: 30),
                            if (_emailFound)
                              AuthPrimaryButton(
                                label: 'Gửi link đặt lại mật khẩu',
                                isLoading: _isSubmitting,
                                onPressed: _onSubmit,
                                backgroundColor: ColorManager.gamecomplete,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
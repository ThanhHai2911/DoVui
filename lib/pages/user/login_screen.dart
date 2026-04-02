import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/pages/home/widgets/home_bottom_nav.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:dovui/pages/user/logic/auth_service.dart';
import 'package:dovui/pages/user/register_screen.dart';
import 'package:dovui/pages/user/forgot_password_screen.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  String? _nameError;
  String? _passwordError;

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
    _nameController.dispose();
    _passwordController.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    setState(() {
      _nameError = null;
      _passwordError = null;
    });

    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = "Vui lòng nhập tên người dùng");
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = "Vui lòng nhập mật khẩu");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(name, password);

      // 🔥 ADMIN
      if (result["type"] == "admin") {
        await _authService.loginAdmin(name);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng nhập Admin thành công 👑"),
            backgroundColor: Colors.blue,
          ),
        );

        context.read<UserBloc>().add(CheckUserEvent());
        return;
      }

      // 🔥 USER
      final userDoc = result["userDoc"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", userDoc.id);
      await prefs.setBool("isRegistered", true);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng nhập thành công 🎉"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      if (!mounted) return;
      context.read<UserBloc>().add(CheckUserEvent());
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeBottomNav()),
      );
    } catch (e) {
      final error = e.toString();

      if (error.contains("USER_NOT_FOUND")) {
        setState(() => _nameError = "Tên người dùng không tồn tại");
      } else if (error.contains("WRONG_PASSWORD")) {
        setState(() => _passwordError = "Mật khẩu không đúng");
      } else if (error.contains("NO_EMAIL")) {
        setState(() => _nameError = "Tài khoản chưa có email");
      } else {
        setState(() => _passwordError = "Đăng nhập thất bại");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserRegistered) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeBottomNav()),
            );
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF43C6AC).withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                right: -40,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6C63FF).withOpacity(0.08),
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: TweenAnimationBuilder(
                    tween: Tween(begin: 0.95, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    builder:
                        (context, value, child) =>
                            Transform.scale(scale: value, child: child),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: AnimatedBuilder(
                            animation: _floatAnim,
                            builder:
                                (_, child) => Transform.translate(
                                  offset: Offset(0, _floatAnim.value),
                                  child: child,
                                ),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF43C6AC).withOpacity(0.1),
                                border: Border.all(
                                  color: const Color(
                                    0xFF43C6AC,
                                  ).withOpacity(0.25),
                                ),
                              ),
                              child: const Text(
                                "🕹️",
                                style: TextStyle(fontSize: 44),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),
                        const Text(
                          "Chào mừng trở lại!",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Đăng nhập để tiếp tục hành trình",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),

                        const SizedBox(height: 32),

                        _fieldLabel("Tên người dùng"),
                        const SizedBox(height: 8),
                        _buildField(
                          controller: _nameController,
                          hint: "Nhập tên người dùng",
                          icon: Icons.person_outline_rounded,
                          errorText: _nameError,
                          onChanged: (_) => setState(() => _nameError = null),
                        ),

                        const SizedBox(height: 20),

                        _fieldLabel("Mật khẩu"),
                        const SizedBox(height: 8),
                        _buildField(
                          controller: _passwordController,
                          hint: "Nhập mật khẩu",
                          icon: Icons.lock_outline_rounded,
                          obscure: !_isPasswordVisible,
                          errorText: _passwordError,
                          onChanged:
                              (_) => setState(() => _passwordError = null),
                          suffix: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                            onPressed:
                                () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => const ForgotPasswordScreen(),
                                  ),
                                ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 0,
                              ),
                            ),
                            child: Text(
                              "Quên mật khẩu?",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.gamecomplete,
                              disabledBackgroundColor: Colors.grey.shade200,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isLoading ? null : _onLogin,
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      "Đăng nhập",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Chưa có tài khoản? ",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    ),
                                child: const Text(
                                  "Tạo tài khoản",
                                  style: TextStyle(
                                    color: Color(0xFF6C63FF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1E1B4B),
    ),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    String? errorText,
    Widget? suffix,
    void Function(String)? onChanged,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow:
                hasError
                    ? [
                      BoxShadow(
                        color: const Color(0xFFFF6584).withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            onChanged: onChanged,
            style: const TextStyle(color: Color(0xFF1E1B4B), fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(
                icon,
                color:
                    hasError
                        ? const Color(0xFFFF6584)
                        : const Color(0xFF43C6AC).withOpacity(0.7),
                size: 20,
              ),
              suffixIcon: suffix,
              filled: true,
              fillColor:
                  hasError
                      ? const Color(0xFFFF6584).withOpacity(0.04)
                      : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      hasError ? const Color(0xFFFF6584) : Colors.grey.shade200,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      hasError ? const Color(0xFFFF6584) : Colors.grey.shade200,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      hasError
                          ? const Color(0xFFFF6584)
                          : const Color(0xFF43C6AC),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 13,
                  color: Color(0xFFFF6584),
                ),
                const SizedBox(width: 4),
                Text(
                  errorText,
                  style: const TextStyle(
                    color: Color(0xFFFF6584),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

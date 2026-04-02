import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/pages/home/widgets/home_bottom_nav.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:dovui/pages/user/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  String? _nameError;
  String? _passwordError;
  String? _confirmError;
  String? _emailError;

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
    _confirmController.dispose();
    _floatCtrl.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ─── Validate local ──────────────────────────────────────────────────────────
  bool _validate() {
    String? nameErr;
    String? passErr;
    String? confirmErr;
    String? emailErr; // ✅ dùng local

    final name = _nameController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final email = _emailController.text.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty) {
      emailErr = "Vui lòng nhập email";
    } else if (!emailRegex.hasMatch(email)) {
      emailErr = "Email không hợp lệ";
    }

    if (name.isEmpty) nameErr = "Vui lòng nhập tên người dùng";

    if (pass.isEmpty) {
      passErr = "Vui lòng nhập mật khẩu";
    } else if (pass.length < 6) {
      passErr = "Mật khẩu tối thiểu 6 ký tự";
    }

    if (confirm.isEmpty) {
      confirmErr = "Vui lòng nhập lại mật khẩu";
    } else if (confirm != pass) {
      confirmErr = "Mật khẩu nhập lại không khớp";
    }

    setState(() {
      _nameError = nameErr;
      _passwordError = passErr;
      _confirmError = confirmErr;
      _emailError = emailErr;
    });

    return nameErr == null &&
        passErr == null &&
        confirmErr == null &&
        emailErr == null;
  }

  // ─── Submit ──────────────────────────────────────────────────────────────────
  Future<void> _onSubmit(BuildContext context, bool isLoading) async {
    if (isLoading) return;
    if (!_validate()) return;

    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final email = _emailController.text.trim(); // ✅ FIX

    final adminQuery =
        await FirebaseFirestore.instance
            .collection('admin')
            .where('Name', isEqualTo: name)
            .limit(1)
            .get();

    if (!context.mounted) return;

    if (adminQuery.docs.isNotEmpty) {
      setState(() => _nameError = "Tên này không thể sử dụng");
      return;
    }

    context.read<UserBloc>().add(RegisterUserEvent(name, password, email));
    final emailCheck =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (emailCheck.docs.isNotEmpty) {
      setState(() => _emailError = "Email đã được sử dụng");
      return;
    }
  }

  // ─── Thông báo thành công → chuyển Login ────────────────────────────────────
  void _showSuccessAndNavigate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43C6AC).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Text("🎉", style: TextStyle(fontSize: 40)),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Đăng ký thành công!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tài khoản của bạn đã được tạo.\nHãy đăng nhập để bắt đầu!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43C6AC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Đăng nhập ngay",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserRegistered) {
            _showSuccessAndNavigate();
          }
          if (state is UserError) {
            if (state.message.contains("tồn tại") ||
                state.message.contains("EXISTS")) {
              setState(() => _nameError = "Tên người dùng đã được sử dụng");
            }
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              // Accent blob góc trên phải
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6C63FF).withOpacity(0.08),
                  ),
                ),
              ),
              // Accent blob góc dưới trái
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF43C6AC).withOpacity(0.08),
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      final isLoading = state is UserLoading;
                      return TweenAnimationBuilder(
                        tween: Tween(begin: 0.95, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        builder:
                            (context, value, child) =>
                                Transform.scale(scale: value, child: child),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon nổi căn giữa
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
                                    color: const Color(
                                      0xFF6C63FF,
                                    ).withOpacity(0.1),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF6C63FF,
                                      ).withOpacity(0.2),
                                    ),
                                  ),
                                  child: const Text(
                                    "🎮",
                                    style: TextStyle(fontSize: 44),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            const Text(
                              "Tạo tài khoản",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Điền thông tin để bắt đầu hành trình!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Tên người dùng
                            _fieldLabel("Tên người dùng"),
                            const SizedBox(height: 8),
                            _buildField(
                              controller: _nameController,
                              hint: "Nhập tên hiển thị",
                              icon: Icons.person_outline_rounded,
                              errorText: _nameError,
                              onChanged:
                                  (_) => setState(() => _nameError = null),
                            ),
                            // Tên người dùng
                            const SizedBox(height: 20),

                            _fieldLabel("Email"),
                            const SizedBox(height: 8),
                            _buildField(
                              controller: _emailController,
                              hint: "Nhập email",
                              icon: Icons.email_outlined,
                              errorText: _emailError,
                              onChanged:
                                  (_) => setState(() => _emailError = null),
                            ),

                            const SizedBox(height: 20),

                            // Mật khẩu
                            _fieldLabel("Mật khẩu"),
                            const SizedBox(height: 8),
                            _buildField(
                              controller: _passwordController,
                              hint: "Tối thiểu 6 ký tự",
                              icon: Icons.lock_outline_rounded,
                              obscure: !_isPasswordVisible,
                              errorText: _passwordError,
                              onChanged:
                                  (_) => setState(() => _passwordError = null),
                              suffix: _eyeButton(
                                visible: _isPasswordVisible,
                                onTap:
                                    () => setState(
                                      () =>
                                          _isPasswordVisible =
                                              !_isPasswordVisible,
                                    ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Nhập lại mật khẩu
                            _fieldLabel("Nhập lại mật khẩu"),
                            const SizedBox(height: 8),
                            _buildField(
                              controller: _confirmController,
                              hint: "Nhập lại mật khẩu",
                              icon: Icons.lock_outline_rounded,
                              obscure: !_isConfirmVisible,
                              errorText: _confirmError,
                              onChanged:
                                  (_) => setState(() => _confirmError = null),
                              suffix: _eyeButton(
                                visible: _isConfirmVisible,
                                onTap:
                                    () => setState(
                                      () =>
                                          _isConfirmVisible =
                                              !_isConfirmVisible,
                                    ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Nút đăng ký
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  disabledBackgroundColor: Colors.grey.shade200,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed:
                                    isLoading
                                        ? null
                                        : () => _onSubmit(context, isLoading),
                                child:
                                    isLoading
                                        ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Text(
                                          "Đăng ký",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Link đăng nhập
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Đã có tài khoản? ",
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
                                            builder: (_) => const LoginScreen(),
                                          ),
                                        ),
                                    child: const Text(
                                      "Đăng nhập",
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

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E1B4B),
      ),
    );
  }

  Widget _eyeButton({required bool visible, required VoidCallback onTap}) {
    return IconButton(
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
        color: Colors.grey.shade400,
      ),
      onPressed: onTap,
    );
  }

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
                        : const Color(0xFF6C63FF).withOpacity(0.6),
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
                          : const Color(0xFF6C63FF),
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

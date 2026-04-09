import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/pages/user/login_screen.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  // Trạng thái kiểm tra tên
  bool _isCheckingName = false; // đang query Firestore
  bool _nameFound = false; // tên đã tồn tại
  String? _nameError;
  String? _passwordError;
  String? _confirmError;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _isSubmitting = false;

  // Debounce timer
  Timer? _debounce;
  String _lastCheckedName = '';

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
    _debounce?.cancel();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  // ─── Tự động kiểm tra tên sau 600ms dừng gõ ─────────────────────────────────
  void _onEmailChanged(String value) {
    setState(() {
      _nameError = null;
      _nameFound = false;
    });

    _debounce?.cancel();

    final email = value.trim();
    if (email.isEmpty) return;

    _debounce = Timer(const Duration(milliseconds: 600), () {
      _checkEmailExists(email);
    });
  }

  Future<void> _checkEmailExists(String email) async {
    setState(() => _isCheckingName = true);

    try {
      final query =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (!mounted) return;

      setState(() {
        _nameFound = query.docs.isNotEmpty;
        _nameError = query.docs.isEmpty ? "Email không tồn tại" : null;
        _isCheckingName = false;
      });
    } catch (e) {
      setState(() {
        _nameError = "Lỗi kết nối";
        _isCheckingName = false;
      });
    }
  }

  // ─── Xác nhận đổi mật khẩu ──────────────────────────────────────────────────
  Future<void> _onSubmit() async {
    final email = _nameController.text.trim();

    if (email.isEmpty) {
      setState(() => _nameError = "Vui lòng nhập email");
      return;
    }

    if (!_nameFound) {
      setState(() => _nameError = "Email không tồn tại");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      setState(() => _nameError = "Không thể gửi email");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
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
                  child: const Text("✅", style: TextStyle(fontSize: 40)),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Gửi email thành công!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Một email đặt lại mật khẩu đã được gửi.\nVui lòng kiểm tra email của bạn.",
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Accent blobs
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6C63FF).withOpacity(0.07),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF43C6AC).withOpacity(0.07),
                  ),
                ),
              ),

              Column(
                children: [
                  // AppBar custom
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: Color(0xFF1E1B4B),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "Đặt lại mật khẩu",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 8,
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
                            // Icon nổi
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
                                    "🔑",
                                    style: TextStyle(fontSize: 44),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              "Quên mật khẩu?",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Nhập email để đặt lại mật khẩu",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ── Ô nhập tên ──────────────────────────────────────
                            _fieldLabel("Email"),
                            const SizedBox(height: 8),
                            _buildNameField(),

                            const SizedBox(height: 20),
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

  // Ô tên đặc biệt: có loading indicator + icon check/error
  Widget _buildNameField() {
    final hasError = _nameError != null;
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
                    : _nameFound
                    ? [
                      BoxShadow(
                        color: const Color(0xFF43C6AC).withOpacity(0.15),
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
            controller: _nameController,
            onChanged: _onEmailChanged,
            style: const TextStyle(color: Color(0xFF1E1B4B), fontSize: 15),
            decoration: InputDecoration(
              hintText: "Vui lòng nhập email",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color:
                    hasError
                        ? const Color(0xFFFF6584)
                        : _nameFound
                        ? const Color(0xFF43C6AC)
                        : const Color(0xFF6C63FF).withOpacity(0.6),
                size: 20,
              ),
              // Suffix: loading / check / error icon
              suffixIcon:
                  _isCheckingName
                      ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      )
                      : _nameFound
                      ? const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF43C6AC),
                        size: 20,
                      )
                      : hasError
                      ? const Icon(
                        Icons.cancel_outlined,
                        color: Color(0xFFFF6584),
                        size: 20,
                      )
                      : null,
              filled: true,
              fillColor:
                  hasError
                      ? const Color(0xFFFF6584).withOpacity(0.04)
                      : _nameFound
                      ? const Color(0xFF43C6AC).withOpacity(0.04)
                      : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      hasError
                          ? const Color(0xFFFF6584)
                          : _nameFound
                          ? const Color(0xFF43C6AC)
                          : Colors.grey.shade200,
                  width: (hasError || _nameFound) ? 1.5 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      hasError
                          ? const Color(0xFFFF6584)
                          : _nameFound
                          ? const Color(0xFF43C6AC)
                          : Colors.grey.shade200,
                  width: (hasError || _nameFound) ? 1.5 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      hasError
                          ? const Color(0xFFFF6584)
                          : _nameFound
                          ? const Color(0xFF43C6AC)
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
                  _nameError!,
                  style: const TextStyle(
                    color: Color(0xFFFF6584),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 30),
        if (_nameFound)
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
              onPressed: _isSubmitting ? null : _onSubmit,
              child:
                  _isSubmitting
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        "Gửi link đặt lại mật khẩu",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
            ),
          ),
      ],
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

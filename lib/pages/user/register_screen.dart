import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:dovui/pages/user/login_screen.dart';
// Extracted widgets:
import 'widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _emailController = TextEditingController();

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
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailController.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    String? nameErr, passErr, confirmErr, emailErr;

    if (email.isEmpty) emailErr = 'Vui lòng nhập email';
    else if (!emailRegex.hasMatch(email)) emailErr = 'Email không hợp lệ';

    if (name.isEmpty) nameErr = 'Vui lòng nhập tên người dùng';

    if (pass.isEmpty) passErr = 'Vui lòng nhập mật khẩu';
    else if (pass.length < 6) passErr = 'Mật khẩu tối thiểu 6 ký tự';

    if (confirm.isEmpty) confirmErr = 'Vui lòng nhập lại mật khẩu';
    else if (confirm != pass) confirmErr = 'Mật khẩu nhập lại không khớp';

    setState(() {
      _nameError = nameErr;
      _passwordError = passErr;
      _confirmError = confirmErr;
      _emailError = emailErr;
    });

    return nameErr == null && passErr == null && confirmErr == null && emailErr == null;
  }

  Future<void> _onSubmit(BuildContext context, bool isLoading) async {
    if (isLoading || !_validate()) return;

    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final email = _emailController.text.trim();

    final emailCheck = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (!context.mounted) return;
    if (emailCheck.docs.isNotEmpty) {
      setState(() => _emailError = 'Email đã được sử dụng');
      return;
    }

    final adminQuery = await FirebaseFirestore.instance
        .collection('admin')
        .where('Name', isEqualTo: name)
        .limit(1)
        .get();

    if (adminQuery.docs.isNotEmpty) {
      setState(() => _nameError = 'Tên này không thể sử dụng');
      return;
    }

    context.read<UserBloc>().add(RegisterUserEvent(name, password, email));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserRegistered) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Đăng ký thành công! Hãy đăng nhập.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              Future.delayed(const Duration(milliseconds: 800), () {
                if (!context.mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              });
            }
            if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
              if (state.message.contains('tồn tại') || state.message.contains('EXISTS')) {
                setState(() => _nameError = 'Tên người dùng đã được sử dụng');
              }
            }
          },
          child: SafeArea(
            child: Stack(
              children: [
                const AuthBackgroundBlobs(),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: BlocBuilder<UserBloc, UserState>(
                      builder: (context, state) {
                        final isLoading = state is UserLoading;
                        return TweenAnimationBuilder(
                          tween: Tween(begin: 0.95, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutBack,
                          builder: (_, value, child) => Transform.scale(scale: value, child: child),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FloatingEmojiIcon(
                                floatAnim: _floatAnim,
                                emoji: '🎮',
                                bgColor: const Color(0xFF6C63FF).withOpacity(0.1),
                                borderColor: const Color(0xFF6C63FF).withOpacity(0.2),
                              ),
                              const SizedBox(height: 28),
                              const Text('Tạo tài khoản',
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                              const SizedBox(height: 6),
                              Text('Điền thông tin để bắt đầu hành trình!',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                              const SizedBox(height: 32),

                              const AuthFieldLabel('Tên người dùng'),
                              const SizedBox(height: 8),
                              AuthTextField(
                                controller: _nameController,
                                hint: 'Nhập tên hiển thị',
                                icon: Icons.person_outline_rounded,
                                errorText: _nameError,
                                onChanged: (_) => setState(() => _nameError = null),
                              ),
                              const SizedBox(height: 20),

                              const AuthFieldLabel('Email'),
                              const SizedBox(height: 8),
                              AuthTextField(
                                controller: _emailController,
                                hint: 'Nhập email',
                                icon: Icons.email_outlined,
                                errorText: _emailError,
                                onChanged: (_) => setState(() => _emailError = null),
                              ),
                              const SizedBox(height: 20),

                              const AuthFieldLabel('Mật khẩu'),
                              const SizedBox(height: 8),
                              AuthTextField(
                                controller: _passwordController,
                                hint: 'Tối thiểu 6 ký tự',
                                icon: Icons.lock_outline_rounded,
                                obscure: !_isPasswordVisible,
                                errorText: _passwordError,
                                onChanged: (_) => setState(() => _passwordError = null),
                                suffix: EyeToggleButton(
                                  visible: _isPasswordVisible,
                                  onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                              ),
                              const SizedBox(height: 20),

                              const AuthFieldLabel('Nhập lại mật khẩu'),
                              const SizedBox(height: 8),
                              AuthTextField(
                                controller: _confirmController,
                                hint: 'Nhập lại mật khẩu',
                                icon: Icons.lock_outline_rounded,
                                obscure: !_isConfirmVisible,
                                errorText: _confirmError,
                                onChanged: (_) => setState(() => _confirmError = null),
                                suffix: EyeToggleButton(
                                  visible: _isConfirmVisible,
                                  onTap: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                                ),
                              ),
                              const SizedBox(height: 32),

                              AuthPrimaryButton(
                                label: 'Đăng ký',
                                isLoading: isLoading,
                                onPressed: () => _onSubmit(context, isLoading),
                              ),
                              const SizedBox(height: 20),

                              AuthLinkRow(
                                prefixText: 'Đã có tài khoản? ',
                                linkText: 'Đăng nhập',
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Loading overlay
                BlocBuilder<UserBloc, UserState>(
                  builder: (_, state) => state is UserLoading
                      ? Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
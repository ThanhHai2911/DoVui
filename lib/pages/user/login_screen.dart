import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/pages/home/widgets/home_bottom_nav.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:dovui/pages/user/logic/auth_service.dart';
import 'package:dovui/pages/user/register_screen.dart';
import 'package:dovui/pages/user/forgot_password_screen.dart';
import 'package:dovui/resources/color_manager.dart';
// Extracted widgets:
import 'widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  String? _nameError;
  String? _passwordError;

  bool get _anyLoading => _isLoading || _isGoogleLoading;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    AudioManager().stopBackgroundMusic();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _navigateHome() {
    context.read<UserBloc>().add(CheckUserEvent());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeBottomNav(initialIndex: 0)),
    );
  }

  Future<void> _onLogin() async {
    setState(() { _nameError = null; _passwordError = null; });

    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) { setState(() => _nameError = 'Vui lòng nhập tên người dùng'); return; }
    if (password.isEmpty) { setState(() => _passwordError = 'Vui lòng nhập mật khẩu'); return; }

    setState(() => _isLoading = true);
    try {
      final result = await _authService.login(name, password);

      if (result['type'] == 'admin') {
        _authService.loginAdmin(name);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập Admin thành công 👑'), backgroundColor: Colors.blue),
        );
        context.read<UserBloc>().add(CheckUserEvent());
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', result['userDoc'].id);
      await prefs.setBool('isRegistered', true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thành công 🎉'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
      );
      _navigateHome();
    } catch (e) {
      final error = e.toString();
      if (error.contains('USER_NOT_FOUND')) setState(() => _nameError = 'Tên người dùng không tồn tại');
      else if (error.contains('WRONG_PASSWORD')) setState(() => _passwordError = 'Mật khẩu không đúng');
      else if (error.contains('NO_EMAIL')) setState(() => _nameError = 'Tài khoản chưa có email');
      else setState(() => _passwordError = 'Đăng nhập thất bại');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      final result = await _authService.loginWithGoogle();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Chào mừng ${result['name']} 🎉"), backgroundColor: Colors.green, duration: const Duration(seconds: 1)),
      );
      _navigateHome();
    } catch (e) {
      if (!mounted) return;
      if (!e.toString().contains('GOOGLE_CANCELLED')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập Google thất bại'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeBottomNav(initialIndex: 0)),
              );
            }
          },
          child: SafeArea(
            child: Stack(
              children: [
                const AuthBackgroundBlobs(topLeftVariant: true),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
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
                            emoji: '🕹️',
                            bgColor: const Color(0xFF43C6AC).withOpacity(0.1),
                            borderColor: const Color(0xFF43C6AC).withOpacity(0.25),
                          ),
                          const SizedBox(height: 28),
                          const Text('Chào mừng trở lại!',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                          const SizedBox(height: 6),
                          Text('Đăng nhập để tiếp tục hành trình',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                          const SizedBox(height: 20),

                          const AuthFieldLabel('Tên người dùng'),
                          const SizedBox(height: 8),
                          AuthTextField(
                            controller: _nameController,
                            hint: 'Nhập tên người dùng',
                            icon: Icons.person_outline_rounded,
                            errorText: _nameError,
                            iconColor: _nameError != null ? const Color(0xFFFF6584) : const Color(0xFF43C6AC).withOpacity(0.7),
                            onChanged: (_) => setState(() => _nameError = null),
                          ),
                          const SizedBox(height: 20),

                          const AuthFieldLabel('Mật khẩu'),
                          const SizedBox(height: 8),
                          AuthTextField(
                            controller: _passwordController,
                            hint: 'Nhập mật khẩu',
                            icon: Icons.lock_outline_rounded,
                            obscure: !_isPasswordVisible,
                            errorText: _passwordError,
                            iconColor: _passwordError != null ? const Color(0xFFFF6584) : const Color(0xFF43C6AC).withOpacity(0.7),
                            onChanged: (_) => setState(() => _passwordError = null),
                            suffix: EyeToggleButton(
                              visible: _isPasswordVisible,
                              onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                              ),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 6)),
                              child: Text('Quên mật khẩu?', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                            ),
                          ),

                          const SizedBox(height: 4),
                          AuthPrimaryButton(
                            label: 'Đăng nhập',
                            isLoading: _isLoading,
                            disabled: _anyLoading,
                            onPressed: _onLogin,
                            backgroundColor: ColorManager.gamecomplete,
                          ),
                          const SizedBox(height: 20),

                          Row(children: [
                            Expanded(child: Divider(color: Colors.grey.shade200)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('hoặc', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade200)),
                          ]),
                          const SizedBox(height: 20),

                          _GoogleButton(isLoading: _isGoogleLoading, disabled: _anyLoading, onPressed: _onGoogleLogin),
                          const SizedBox(height: 20),

                          AuthLinkRow(
                            prefixText: 'Chưa có tài khoản? ',
                            linkText: 'Tạo tài khoản',
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
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
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool isLoading;
  final bool disabled;
  final VoidCallback onPressed;

  const _GoogleButton({required this.isLoading, required this.disabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
        ),
        child: isLoading
            ? SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.grey.shade600),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.network(
                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                    width: 20, height: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('Đăng nhập bằng Google', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/user/login_screen.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// Extracted widgets:
import 'widgets/settings_widgets.dart';
import 'widgets/policy_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isMusicOn = true;
  bool _isSfxOn = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMusicOn = prefs.getBool('music_enabled') ?? true;
      _isSfxOn = prefs.getBool('sfx_enabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _toggleMusic(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isMusicOn = value);
    await prefs.setBool('music_enabled', value);
    if (value) {
      await AudioManager().init();
      AudioManager().playBackgroundMusic();
    } else {
      AudioManager().stopBackgroundMusic();
    }
  }

  Future<void> _toggleSfx(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isSfxOn = value);
    await prefs.setBool('sfx_enabled', value);
    if (!value) AudioManager().stopSfx();
  }

  void _openPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const PolicySheet(),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => ConfirmActionDialog(
        emoji: '👋',
        emojiBg: Colors.orange.shade50,
        title: 'Đăng xuất?',
        message: 'Bạn có chắc muốn đăng xuất không?\nTiến trình của bạn sẽ được lưu lại.',
        confirmText: 'Đăng xuất',
        confirmColor: Colors.orange.shade600,
        onConfirm: () async {
          Navigator.pop(context);
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          if (context.mounted) {
            context.read<UserBloc>().add(LogoutUserEvent());
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => ConfirmActionDialog(
        emoji: '🗑️',
        emojiBg: Colors.red.shade50,
        title: 'Xóa tài khoản?',
        message: 'Toàn bộ dữ liệu của bạn, bao gồm điểm số và tiến trình, sẽ bị xóa vĩnh viễn. Hành động này không thể hoàn tác.',
        confirmText: 'Xóa vĩnh viễn',
        confirmColor: Colors.red.shade400,
        onConfirm: () async {
          Navigator.pop(context);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
              await user.delete();
            }
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            if (context.mounted) Navigator.pop(context);
            if (context.mounted) {
              context.read<UserBloc>().add(LogoutUserEvent());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          } catch (e) {
            debugPrint('Delete account error: $e');
            if (context.mounted) Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Xóa tài khoản thất bại. Vui lòng đăng nhập lại.')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1E1B4B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cài đặt', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                const SectionLabel(label: 'ÂM THANH'),
                const SizedBox(height: 8),
                SettingsCard(children: [
                  ToggleRow(
                    emoji: _isMusicOn ? '🎵' : '🔕',
                    title: 'Nhạc nền',
                    subtitle: _isMusicOn ? 'Đang bật' : 'Đã tắt',
                    value: _isMusicOn,
                    activeColor: Colors.deepPurple,
                    onChanged: _toggleMusic,
                  ),
                  const SettingsDivider(),
                  ToggleRow(
                    emoji: _isSfxOn ? '🔊' : '🔇',
                    title: 'Âm thanh hiệu ứng',
                    subtitle: _isSfxOn ? 'Đang bật' : 'Đã tắt',
                    value: _isSfxOn,
                    activeColor: const Color(0xFF43C6AC),
                    onChanged: _toggleSfx,
                  ),
                ]),
                const SizedBox(height: 24),
                const SectionLabel(label: 'ỨNG DỤNG'),
                const SizedBox(height: 8),
                SettingsCard(children: [
                  ChevronRow(
                    emoji: '🛡️',
                    emojiBg: const Color(0xFFEEEDFE),
                    title: 'Chính sách ứng dụng',
                    subtitle: 'Quyền riêng tư & điều khoản',
                    onTap: _openPolicy,
                  ),
                ]),
                const SizedBox(height: 24),
                const SectionLabel(label: 'TÀI KHOẢN'),
                const SizedBox(height: 8),
                SettingsCard(children: [
                  ChevronRow(
                    emoji: '👋',
                    emojiBg: Colors.orange.shade50,
                    title: 'Đăng xuất',
                    titleColor: Colors.orange.shade700,
                    subtitle: 'Tiến trình của bạn sẽ được lưu lại',
                    chevronColor: Colors.orange.shade300,
                    onTap: _confirmLogout,
                  ),
                  const SettingsDivider(),
                  ChevronRow(
                    emoji: '🗑️',
                    emojiBg: Colors.red.shade50,
                    title: 'Xóa tài khoản',
                    titleColor: Colors.red.shade400,
                    subtitle: 'Xóa vĩnh viễn dữ liệu của bạn',
                    chevronColor: Colors.red.shade300,
                    onTap: _confirmDeleteAccount,
                  ),
                ]),
                const SizedBox(height: 50),
                Center(
                  child: Text(
                    'Đố Vui - Quiz App · Phiên bản 1.0.4',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
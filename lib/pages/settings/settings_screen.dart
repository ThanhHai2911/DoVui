import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/user/login_screen.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
      builder: (_) => const _PolicySheet(),
    );
  }

  // ── ĐĂNG XUẤT ──────────────────────────────────────────
  void _confirmLogout() {
    showDialog(
      context: context,
      builder:
          (_) => _ConfirmDialog(
            emoji: '👋',
            emojiBg: Colors.orange.shade50,
            title: 'Đăng xuất?',
            message:
                'Bạn có chắc muốn đăng xuất không?\nTiến trình của bạn sẽ được lưu lại.',
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

  // ── XÓA TÀI KHOẢN ──────────────────────────────────────
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder:
          (_) => _ConfirmDialog(
            emoji: '🗑️',
            emojiBg: Colors.red.shade50,
            title: 'Xóa tài khoản?',
            message:
                'Toàn bộ dữ liệu của bạn, bao gồm điểm số và tiến trình, sẽ bị xóa vĩnh viễn. Hành động này không thể hoàn tác.',
            confirmText: 'Xóa vĩnh viễn',
            confirmColor: Colors.red.shade400,
            onConfirm: () async {
              Navigator.pop(context);

              // 👉 HIỆN LOADING
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (_) => const Center(child: CircularProgressIndicator()),
              );

              try {
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // 1. Xóa Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .delete();

                  // 2. Xóa Auth
                  await user.delete();
                }

                // 3. Clear local
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // 👉 ĐÓNG LOADING
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
                print("Delete account error: $e");

                // 👉 ĐÓNG LOADING nếu lỗi
                if (context.mounted) Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Xóa tài khoản thất bại. Vui lòng đăng nhập lại.",
                    ),
                  ),
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF1E1B4B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        centerTitle: false,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                children: [
                  // ── Âm thanh ───────────────────────────────
                  _SectionLabel(label: 'ÂM THANH'),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _ToggleRow(
                        emoji: _isMusicOn ? '🎵' : '🔕',
                        title: 'Nhạc nền',
                        subtitle: _isMusicOn ? 'Đang bật' : 'Đã tắt',
                        value: _isMusicOn,
                        activeColor: Colors.deepPurple,
                        onChanged: _toggleMusic,
                      ),
                      _DividerLine(),
                      _ToggleRow(
                        emoji: _isSfxOn ? '🔊' : '🔇',
                        title: 'Âm thanh hiệu ứng',
                        subtitle: _isSfxOn ? 'Đang bật' : 'Đã tắt',
                        value: _isSfxOn,
                        activeColor: const Color(0xFF43C6AC),
                        onChanged: _toggleSfx,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Ứng dụng ───────────────────────────────
                  _SectionLabel(label: 'ỨNG DỤNG'),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _ChevronRow(
                        emoji: '🛡️',
                        emojiBg: const Color(0xFFEEEDFE),
                        title: 'Chính sách ứng dụng',
                        subtitle: 'Quyền riêng tư & điều khoản',
                        onTap: _openPolicy,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Tài khoản ──────────────────────────────
                  _SectionLabel(label: 'TÀI KHOẢN'),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      // Đăng xuất — nằm trên
                      _ChevronRow(
                        emoji: '👋',
                        emojiBg: Colors.orange.shade50,
                        title: 'Đăng xuất',
                        titleColor: Colors.orange.shade700,
                        subtitle: 'Tiến trình của bạn sẽ được lưu lại',
                        chevronColor: Colors.orange.shade300,
                        onTap: _confirmLogout,
                      ),
                      _DividerLine(),
                      // Xóa tài khoản — nằm dưới
                      _ChevronRow(
                        emoji: '🗑️',
                        emojiBg: Colors.red.shade50,
                        title: 'Xóa tài khoản',
                        titleColor: Colors.red.shade400,
                        subtitle: 'Xóa vĩnh viễn dữ liệu của bạn',
                        chevronColor: Colors.red.shade300,
                        onTap: _confirmDeleteAccount,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // RepaintBoundary(child: NativeAdWidget()),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Đố Vui - Quiz App · Phiên bản 1.0.1',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0.5,
      thickness: 0.5,
      color: Colors.grey.shade200,
      indent: 62,
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  value
                      ? activeColor.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }
}

class _ChevronRow extends StatelessWidget {
  final String emoji;
  final Color emojiBg;
  final String title;
  final Color? titleColor;
  final String subtitle;
  final Color? chevronColor;
  final VoidCallback onTap;

  const _ChevronRow({
    required this.emoji,
    required this.emojiBg,
    required this.title,
    this.titleColor,
    required this.subtitle,
    this.chevronColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: emojiBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? const Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: chevronColor ?? Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PRIVACY POLICY BOTTOM SHEET
// ═══════════════════════════════════════════════════════════

class _PolicySheet extends StatelessWidget {
  const _PolicySheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Chính sách ứng dụng',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 0.5, thickness: 0.5, color: Colors.grey.shade200),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(
                        'https://thanhhai2911.github.io/Dovui_Privacy-Policy/privacy-policy.html',
                      );
                      if (await canLaunchUrl(uri)) launchUrl(uri);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEDFE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF534AB7).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 14,
                            color: Color(0xFF534AB7),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Xem trang web chính thức',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF534AB7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Có hiệu lực từ ngày: 11 tháng 4, 2026',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  _h2('1. Giới thiệu'),
                  _body(
                    'Chào mừng bạn đến với Đố Vui - Quiz App. Chính sách này giải thích cách chúng tôi thu thập, sử dụng và bảo vệ thông tin khi bạn dùng ứng dụng.',
                  ),
                  _h2('2. Thông tin chúng tôi thu thập'),
                  _h3('a. Thông tin cá nhân'),
                  _bullets([
                    'Địa chỉ email (qua Firebase Authentication)',
                    'User ID (UID)',
                  ]),
                  _h3('b. Dữ liệu sử dụng'),
                  _bullets([
                    'Tiến trình & điểm số trò chơi',
                    'Thông tin thiết bị (loại máy, phiên bản HĐH)',
                    'Nhật ký sự cố, hiệu suất',
                  ]),
                  _h3('c. Dữ liệu quảng cáo'),
                  _bullets([
                    'Advertising ID',
                    'Định danh thiết bị',
                    'Tương tác với quảng cáo',
                  ]),
                  _h2('3. Cách chúng tôi sử dụng thông tin'),
                  _bullets([
                    'Cung cấp & duy trì ứng dụng',
                    'Xác thực người dùng',
                    'Lưu tiến trình & điểm số',
                    'Cải thiện hiệu suất & trải nghiệm',
                    'Hiển thị quảng cáo',
                  ]),
                  _h2('4. Dịch vụ bên thứ ba'),
                  _bullets([
                    'Google Firebase (Authentication, Firestore, Analytics)',
                    'Google AdMob (Quảng cáo)',
                  ]),
                  _h2('5. Chia sẻ dữ liệu'),
                  _body('Chúng tôi không bán dữ liệu cá nhân của bạn.'),
                  _h2('6. Bảo mật dữ liệu'),
                  _body(
                    'Chúng tôi áp dụng các biện pháp hợp lý để bảo vệ dữ liệu của bạn.',
                  ),
                  _h2('7. Quyền của người dùng'),
                  _bullets(['Truy cập dữ liệu của bạn', 'Yêu cầu chỉnh sửa']),
                  _h3('Yêu cầu xóa dữ liệu'),
                  _body(
                    'Bạn có thể yêu cầu xóa dữ liệu bằng cách liên hệ qua email bên dưới.',
                  ),
                  _h2('8. Quyền riêng tư của trẻ em'),
                  _body('Ứng dụng không dành cho trẻ em dưới 13 tuổi.'),
                  _h2('9. Thay đổi chính sách'),
                  _body(
                    'Chúng tôi có thể cập nhật chính sách này theo thời gian.',
                  ),
                  _h2('10. Liên hệ'),
                  _body('Email: thanhhai291120@gmail.com'),
                  _body('Developer: Thanh Hải'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _h2(String t) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 6),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E1B4B),
      ),
    ),
  );
  Widget _h3(String t) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF333333),
      ),
    ),
  );
  Widget _body(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF555555),
        height: 1.6,
      ),
    ),
  );
  Widget _bullets(List<String> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children:
        items
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                    ),
                    Expanded(
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF555555),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
  );
}

// ═══════════════════════════════════════════════════════════
//  GENERIC CONFIRM DIALOG (dùng cho cả logout lẫn xóa TK)
// ═══════════════════════════════════════════════════════════

class _ConfirmDialog extends StatelessWidget {
  final String emoji;
  final Color emojiBg;
  final String title;
  final String message;
  final String confirmText;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.emoji,
    required this.emojiBg,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: emojiBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onConfirm,
                child: Text(
                  confirmText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: const Color(0xFF1E1B4B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Hủy bỏ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

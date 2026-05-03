
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog {
  static void show(
    BuildContext context, {
    required String currentVersion,
    required String newVersion,
    String? updateUrl, // tuỳ chọn: override link store mặc định
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // không cho bấm ra ngoài để tắt
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => WillPopScope(
        onWillPop: () async => false, // chặn nút Back Android
        child: _UpdateDialogContent(
          currentVersion: currentVersion,
          newVersion: newVersion,
          updateUrl: updateUrl,
        ),
      ),
    );
  }
}

class _UpdateDialogContent extends StatefulWidget {
  final String currentVersion;
  final String newVersion;
  final String? updateUrl;

  const _UpdateDialogContent({
    required this.currentVersion,
    required this.newVersion,
    this.updateUrl,
  });

  @override
  State<_UpdateDialogContent> createState() => _UpdateDialogContentState();
}

class _UpdateDialogContentState extends State<_UpdateDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    // Pulse animation cho icon rocket
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _ctrl.forward();

    // Loop pulse sau khi entry xong
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _ctrl.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openStore() async {
    final Uri url;

    if (widget.updateUrl != null) {
      url = Uri.parse(widget.updateUrl!);
    } else if (Platform.isIOS) {
      // Thay YOUR_APP_ID bằng Apple ID thật của app (số trong App Store Connect)
      url = Uri.parse('https://apps.apple.com/app/idYOUR_APP_ID');
    } else {
      // Android: tự lấy package name hiện tại
      final packageName = 'com.thanhhai.dovui'; // ← đổi thành package name thật
      url = Uri.parse(
          'https://play.google.com/store/apps/details?id=$packageName');
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F0C29), Color(0xFF1A1560), Color(0xFF0F0C29)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  // ── Decorative background blobs ─────────────────
                  Positioned(
                    top: -30,
                    right: -30,
                    child: _Blob(80, const Color(0xFF6C63FF), 0.2),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: _Blob(100, const Color(0xFF43C6AC), 0.15),
                  ),
                  Positioned(
                    top: 80,
                    left: -40,
                    child: _Blob(120, const Color(0xFFFF6584), 0.1),
                  ),

                  // ── Main content ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Rocket icon with pulse
                        ScaleTransition(
                          scale: _pulse,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6C63FF),
                                  Color(0xFF43C6AC),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '🚀',
                                style: TextStyle(fontSize: 36),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Badge "CẬP NHẬT MỚI"
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF43C6AC)],
                            ),
                          ),
                          child: const Text(
                            'CẬP NHẬT MỚI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Title
                        const Text(
                          'Phiên bản mới\nđã có mặt! 🎉',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Version comparison card
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white.withOpacity(0.07),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _VersionBadge(
                                label: 'Hiện tại',
                                version: widget.currentVersion,
                                color: const Color(0xFFFF6584),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white.withOpacity(0.4),
                                  size: 20,
                                ),
                              ),
                              _VersionBadge(
                                label: 'Mới nhất',
                                version: widget.newVersion,
                                color: const Color(0xFF43C6AC),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Description
                        Text(
                          'Vui lòng cập nhật để tiếp tục\ntrải nghiệm Đố Vui nhé! ✨',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Update button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6C63FF),
                                  Color(0xFF43C6AC),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF6C63FF).withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _openStore,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Cập nhật ngay',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('↗', style: TextStyle(fontSize: 16, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Store label
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Platform.isIOS
                                  ? Icons.apple
                                  : Icons.android_rounded,
                              color: Colors.white.withOpacity(0.3),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              Platform.isIOS
                                  ? 'Cập nhật qua App Store'
                                  : 'Cập nhật qua Google Play',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _VersionBadge extends StatelessWidget {
  final String label;
  final String version;
  final Color color;

  const _VersionBadge({
    required this.label,
    required this.version,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withOpacity(0.15),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(
            'v$version',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Blob(this.size, this.color, this.opacity);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dovui/pages/profile/widgets/vip_purchase_service.dart';
import 'package:flutter/material.dart';

class VipDialog extends StatefulWidget {
  const VipDialog({super.key});

  @override
  State<VipDialog> createState() => _VipDialogState();
}

class _VipDialogState extends State<VipDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool _isLoading = false;

  // Tên store theo platform
  String get _storeName => Platform.isIOS ? 'App Store' : 'Google Play';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Lưu Firestore + gửi push notification đến admin ──────────────────────
  Future<void> _saveVipRequestToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userName = user.displayName ?? 'Người dùng';
      final userEmail = user.email ?? '';

      // 1. Lưu vào collection user_vip
      await FirebaseFirestore.instance.collection('user_vip').doc(user.uid).set(
        {
          'id': user.uid,
          'ten': userName,
          'email': userEmail,
          'trang_thai': 'da_xu_ly',
          'thoi_gian_yeu_cau': FieldValue.serverTimestamp(),
          'da_thanh_toan': true,
          'gia': VipPurchaseService().vipProduct?.price ?? '29.000đ',
          'platform': Platform.isIOS ? 'ios' : 'android', // Thêm platform
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Lỗi lưu Firestore: $e');
    }
  }

  Future<void> _handleBuyVip() async {
    setState(() => _isLoading = true);

    final vipService = VipPurchaseService(); // ✅ chỉ 1 instance duy nhất

    vipService.onPurchaseSuccess = () async {
      if (!mounted) return;

      await _saveVipRequestToFirestore();

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Đóng tất cả dialog (dùng rootNavigator để đảm bảo)
      Navigator.of(context, rootNavigator: true).pop();

      _showSnack('🎉 Mua VIP thành công!', Colors.green);
    };

    // ✅ Dùng cùng instance vipService, không tạo mới
    vipService.onPurchaseFailed = () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final reason = vipService.lastErrorReason; // ✅ cùng instance
      final msg = reason.isNotEmpty ? reason : 'Thanh toán thất bại, thử lại!';

      final isStoreSetupError =
          reason.contains('Play Console') ||
          reason.contains('App Store') ||
          reason.contains('not found') ||
          reason.contains('chưa được tạo');

      if (isStoreSetupError) {
        _showDetailDialog(
          '⚠️ Chưa sẵn sàng',
          'Tính năng VIP đang được thiết lập trên $_storeName.\n'
              'Vui lòng thử lại sau hoặc liên hệ:\nthanhhai291120@gmail.com',
        );
      } else {
        _showSnack('❌ $msg', Colors.red);
      }
    };

    vipService.onPurchasePending = () {
      // ✅ cùng instance
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('⏳ Đang xử lý thanh toán...', Colors.orange);
    };

    try {
      if (!vipService.isAvailable) {
        // ✅ cùng instance
        await _saveVipRequestToFirestore();
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.of(context, rootNavigator: true).pop();
        _showSnack('🎉 Đã gửi yêu cầu VIP!', Colors.green);
        return;
      }
      await vipService.buyVip(); // ✅ cùng instance
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('❌ Có lỗi xảy ra: $e', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDetailDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String get _priceText {
    final price = VipPurchaseService().vipProduct?.price;
    return price != null ? 'Mua VIP ngay - $price' : 'Mua VIP ngay - 29.000đ';
  }

  // Footer text theo platform
  String get _footerText {
    if (Platform.isIOS) {
      return '🔒 Thanh toán an toàn qua App Store';
    }
    return '🔒 Thanh toán an toàn qua Google Play';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1A1040),
                  Color(0xFF2D1B69),
                  Color(0xFF1A1040),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB347).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFB347).withOpacity(0.15),
                        const Color(0xFFFF6584).withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap:
                              _isLoading ? null : () => Navigator.pop(context),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white60,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFB347)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB347).withOpacity(0.5),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('👑', style: TextStyle(fontSize: 30)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Nâng cấp VIP',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Không giới hạn · Không quảng cáo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // ── Benefits ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    children: [
                      _BenefitRow(
                        emoji: '🚫',
                        title: 'Ẩn toàn bộ quảng cáo',
                        subtitle: 'Không banner, không video bắt buộc',
                        color: const Color(0xFFFF6584),
                      ),
                      const SizedBox(height: 8),
                      _BenefitRow(
                        emoji: '🎮',
                        title: 'Tạo phòng không giới hạn',
                        subtitle: 'Chơi cùng bạn bè mọi lúc, mọi nơi',
                        color: const Color(0xFF6C63FF),
                      ),
                      const SizedBox(height: 8),
                      _BenefitRow(
                        emoji: '⚡',
                        title: 'Chơi lại không cần xem video',
                        subtitle: 'Thoát ngay sau khi kết thúc màn chơi',
                        color: const Color(0xFF43C6AC),
                      ),
                      const SizedBox(height: 8),
                      _BenefitRow(
                        emoji: '👑',
                        title: 'Huy hiệu VIP độc quyền',
                        subtitle: 'Nổi bật trên bảng xếp hạng',
                        color: const Color(0xFFFFB347),
                      ),
                    ],
                  ),
                ),

                // ── Price card ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFFB347).withOpacity(0.4),
                        width: 1.5,
                      ),
                      color: const Color(0xFFFFB347).withOpacity(0.08),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mua 1 lần · Dùng mãi mãi',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Trọn đời',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '49.000đ',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.4),
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.white.withOpacity(0.4),
                              ),
                            ),
                            Text(
                              VipPurchaseService().vipProduct?.price ??
                                  '29.000đ',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── CTA Button ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors:
                              _isLoading
                                  ? [Colors.grey.shade600, Colors.grey.shade700]
                                  : [
                                    const Color(0xFFFFD700),
                                    const Color(0xFFFFB347),
                                  ],
                        ),
                        boxShadow:
                            _isLoading
                                ? []
                                : [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFB347,
                                    ).withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleBuyVip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFF1A1040),
                                  ),
                                )
                                : Text(
                                  '✨ $_priceText',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1040),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),

                // ── Footer (dynamic theo platform) ───────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    _footerText,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.35),
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

// ── Widget phụ ────────────────────────────────────────────────────────────────
class _BenefitRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _BenefitRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 17)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.check_circle_rounded, color: color, size: 18),
      ],
    );
  }
}

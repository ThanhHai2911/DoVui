// lib/pages/level/widgets/banner_ad_slot.dart

import 'package:dovui/pages/ads/ads_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  static const String _adUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111' // Google test ID
      : 'ca-app-pub-3766615924961894/2558866294'; // Production ID

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // Tạo BannerAd mới hoàn toàn — không dùng lại từ Manager
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          debugPrint('[BannerAdSlot] Failed: ${error.message}');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
    return const SizedBox.shrink();
  }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: AdWidget(ad: _bannerAd!), // ← mỗi slot có ad riêng
      ),
    );
  }
}
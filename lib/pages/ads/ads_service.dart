import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ═══════════════════════════════════════════
//  REWARDED AD
// ═══════════════════════════════════════════
class RewardedAdManager {
  static final RewardedAdManager _instance = RewardedAdManager._internal();
  factory RewardedAdManager() => _instance;
  RewardedAdManager._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  // ⚠️ Thay bằng Ad Unit ID thật khi release
  static const String _adUnitId = 'ca-app-pub-2371706562137273/3413210599';

  void loadAd() {
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
        },
      ),
    );
  }

  bool get isAdLoaded => _isAdLoaded;

  void showAd({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) {
    if (!_isAdLoaded || _rewardedAd == null) {
      onFailed();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isAdLoaded = false;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isAdLoaded = false;
        onFailed();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded();
      },
    );
  }
}

// ═══════════════════════════════════════════
//  BANNER AD
// ═══════════════════════════════════════════
class BannerAdManager {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // ⚠️ Thay bằng Ad Unit ID thật khi release
  static const String _adUnitId = 'ca-app-pub-2371706562137273/2149499308';

  bool get isLoaded => _isLoaded;
  BannerAd? get bannerAd => _bannerAd;

  void loadAd({VoidCallback? onLoaded}) {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isLoaded = true;
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isLoaded = false;
        },
      ),
    )..load();
  }

  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }

  /// Widget hiển thị banner, dùng trực tiếp trong build()
  Widget buildBannerWidget() {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
  
}
// ═══════════════════════════════════════════
//  APP OPEN AD
// ═══════════════════════════════════════════
class AppOpenAdManager {
  static final AppOpenAdManager _instance = AppOpenAdManager._internal();
  factory AppOpenAdManager() => _instance;
  AppOpenAdManager._internal();

  AppOpenAd? _appOpenAd;
  bool _isAdLoaded = false;
  bool _isShowingAd = false;

  // ⚠️ Thay bằng ID thật khi release
  static const String _adUnitId = 'ca-app-pub-2371706562137273/3293791094'; // ID test

  void loadAd() {
    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
        },
      ),
    );
  }

  void showAdIfAvailable() {
    if (!_isAdLoaded || _isShowingAd || _appOpenAd == null) return;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => _isShowingAd = true,
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _isAdLoaded = false;
        ad.dispose();
        loadAd(); // load lại cho lần sau
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        _isAdLoaded = false;
        ad.dispose();
        loadAd();
      },
    );

    _appOpenAd!.show();
  }
}
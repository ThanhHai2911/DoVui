import 'dart:async';
import 'package:flutter/foundation.dart';
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

  static const String _adUnitId =
      kDebugMode
          ? 'ca-app-pub-3766615924961894/9560952011' // Test ID
          : 'ca-app-pub-3766615924961894/9560952011';

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

  static const String _adUnitId =
      kDebugMode
          ? 'ca-app-pub-3766615924961894/2558866294' // Test ID
          : 'ca-app-pub-3766615924961894/2558866294';

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
//  INTERSTITIAL AD
// ═══════════════════════════════════════════
class InterstitialAdManager {
  static final InterstitialAdManager _instance =
      InterstitialAdManager._internal();
  factory InterstitialAdManager() => _instance;
  InterstitialAdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isShowingAd = false;
  bool _isLoading = false;

  // --- Frequency capping ---
  int _showCount = 0;
  static const int _maxShowsPerSession = 5;

  // --- Retry logic ---
  int _retryAttempt = 0;
  static const int _maxRetryAttempts = 3;
  Timer? _retryTimer;

  static const String _adUnitId =
      kDebugMode
          ? 'ca-app-pub-3766615924961894/4808587708' // Test ID
          : 'ca-app-pub-3766615924961894/4808587708';

  bool get isReady => _isAdLoaded && !_isShowingAd && _interstitialAd != null;
  bool get hasReachedCap => _showCount >= _maxShowsPerSession;

  void loadAd() {
    if (_isLoading || _isAdLoaded) return;
    _isLoading = true;
    _log('Loading ad... (attempt ${_retryAttempt + 1})');

    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _isLoading = false;
          _retryAttempt = 0;
          _log('Ad loaded.');
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          _isLoading = false;
          _log('Failed: ${error.message}');
          _scheduleRetry();
        },
      ),
    );
  }

  void _scheduleRetry() {
    if (_retryAttempt >= _maxRetryAttempts) return;
    final delay = Duration(seconds: (2 << _retryAttempt));
    _retryAttempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, loadAd);
  }

  /// [force] = true để bỏ qua frequency cap
  void showAdIfAvailable({
    required VoidCallback onAdClosed,
    bool force = false,
  }) {
    if (!isReady) {
      _log('Ad not ready, skipping.');
      onAdClosed();
      return;
    }
    if (!force && hasReachedCap) {
      _log('Frequency cap reached ($_showCount/$_maxShowsPerSession).');
      onAdClosed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        _showCount++;
      },
      onAdDismissedFullScreenContent: (ad) {
        _handleAdClosed(ad);
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _log('Show failed: ${error.message}');
        _handleAdClosed(ad);
        onAdClosed();
      },
    );

    _interstitialAd!.show();
  }

  void _handleAdClosed(InterstitialAd ad) {
    _isShowingAd = false;
    _isAdLoaded = false;
    ad.dispose();
    loadAd();
  }

  void resetSession() {
    _showCount = 0;
  }

  void dispose() {
    _retryTimer?.cancel();
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
    _isLoading = false;
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[InterstitialAdManager] $msg');
  }
}


// ═══════════════════════════════════════════
//  NATIVE AD MANAGER (Singleton)
// ═══════════════════════════════════════════
class NativeAdManager {
  static final NativeAdManager _instance = NativeAdManager._internal();
  factory NativeAdManager() => _instance;
  NativeAdManager._internal();

  final List<NativeAd> _adPool = [];
  int _loadingCount = 0; // ✅ đếm thay vì boolean
  bool _initialized = false;

  static const int _poolSize = 2;
  final List<VoidCallback> _listeners = [];

  static const String _adUnitId = kDebugMode
        ? 'ca-app-pub-3940256099942544/2247696110'
        : 'ca-app-pub-3766615924961894/8788265127';

  bool get isReady => _adPool.isNotEmpty;

  void preloadPool() {
    if (_initialized) return; // ✅ chỉ chạy 1 lần dù gọi nhiều nơi
    _initialized = true;
    _fillPool();
  }

  void _fillPool() {
    final needed = _poolSize - _adPool.length - _loadingCount;
    for (int i = 0; i < needed; i++) {
      _loadOne();
    }
  }

  void _loadOne() {
    if (_loadingCount + _adPool.length >= _poolSize) return; // ✅ không load thừa
    _loadingCount++;

    NativeAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _adPool.add(ad as NativeAd);
          _loadingCount--;

          for (final cb in List.of(_listeners)) {
            cb();
          }

          _fillPool(); // ✅ fill lại nếu còn thiếu
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _loadingCount--;
          if (kDebugMode) debugPrint('[NativeAdManager] Failed: ${error.message}');
          Future.delayed(const Duration(seconds: 30), _fillPool);
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 16,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFFFF9800),
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
      ),
    ).load();
  }

  void addListener(VoidCallback cb) => _listeners.add(cb);
  void removeListener(VoidCallback cb) => _listeners.remove(cb);

  NativeAd? takeAd() {
    if (_adPool.isEmpty) return null;
    final ad = _adPool.removeAt(0);
    _fillPool(); // ✅ bù ngay
    return ad;
  }
}

// ═══════════════════════════════════════════
//  NATIVE AD WIDGET
// ═══════════════════════════════════════════
class NativeAdWidget extends StatefulWidget {
  final Color backgroundColor;
  final Color ctaColor;

  const NativeAdWidget({
    super.key,
    this.backgroundColor = Colors.white,
    this.ctaColor = const Color(0xFFFF9800),
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;

  @override
  void initState() {
    super.initState();
    // ✅ Đợi frame đầu render xong → tránh jank trên Samsung
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tryTakeAd();
    });
  }

  void _tryTakeAd() {
    final manager = NativeAdManager();
    if (manager.isReady) {
      setState(() => _nativeAd = manager.takeAd());
    } else {
      manager.addListener(_onAdReady);
    }
  }

  void _onAdReady() {
    if (!mounted) return;
    final ad = NativeAdManager().takeAd();
    if (ad == null) return;
    NativeAdManager().removeListener(_onAdReady);
    setState(() => _nativeAd = ad);
  }

  @override
  void dispose() {
    NativeAdManager().removeListener(_onAdReady);
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_nativeAd == null) {
      return const SizedBox(height: 160);
    }

    return RepaintBoundary( // ✅ isolate render layer, giảm repaint trên Samsung
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.ctaColor.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Text(
                'Quảng cáo',
                style: TextStyle(
                  fontSize: 11,
                  color: widget.ctaColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 160, child: AdWidget(ad: _nativeAd!)),
          ],
        ),
      ),
    );
  }
}

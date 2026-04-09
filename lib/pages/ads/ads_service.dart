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

    static const String _adUnitId = kDebugMode
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

    static const String _adUnitId = kDebugMode
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

    static const String _adUnitId = kDebugMode
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

  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  // --- Retry logic ---
  int _retryAttempt = 0;
  static const int _maxRetryAttempts = 3;
  Timer? _retryTimer;

  static const String _adUnitId = kDebugMode
      ? 'ca-app-pub-3766615924961894/8788265127'
      : 'ca-app-pub-3766615924961894/8788265127';

  bool get isReady => _isAdLoaded && _nativeAd != null;

  void loadAd({
    Color backgroundColor = Colors.white,
    Color ctaColor = const Color(0xFFFF9800),
  }) {
    if (_isLoading || _isAdLoaded) return;
    _isLoading = true;
    _log('Loading native ad... (attempt ${_retryAttempt + 1})');

    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          _isAdLoaded = true;
          _isLoading = false;
          _retryAttempt = 0;
          _log('Native ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          _isAdLoaded = false;
          _isLoading = false;
          _log('Failed: ${error.message}');
          ad.dispose();
          _nativeAd = null;
          _scheduleRetry();
        },
        onAdOpened: (_) => _log('Native ad opened.'),
        onAdClosed: (_) => _log('Native ad closed.'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: backgroundColor,
        cornerRadius: 16,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: ctaColor,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black87,
          style: NativeTemplateFontStyle.bold,
          size: 15,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black54,
          style: NativeTemplateFontStyle.normal,
          size: 13,
        ),
      ),
    )..load();
  }

  void _scheduleRetry() {
    if (_retryAttempt >= _maxRetryAttempts) {
      _log('Max retry attempts reached.');
      return;
    }
    final delay = Duration(seconds: (2 << _retryAttempt));
    _retryAttempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, loadAd);
  }

  /// Lấy ad hiện tại để hiển thị
  NativeAd? getAd() => isReady ? _nativeAd : null;

  /// Gọi sau khi widget bị dispose để preload lại cho lần sau
  void onAdWidgetDisposed() {
    _isAdLoaded = false;
    _nativeAd?.dispose();
    _nativeAd = null;
    loadAd();
  }

  void dispose() {
    _retryTimer?.cancel();
    _nativeAd?.dispose();
    _nativeAd = null;
    _isAdLoaded = false;
    _isLoading = false;
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[NativeAdManager] $msg');
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
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _initAd();
  }

  void _initAd() {
    final manager = NativeAdManager();

    if (manager.isReady) {
      // ✅ Manager đã preload sẵn → dùng luôn, không chờ
      _nativeAd = manager.getAd();
      _isLoaded = true;
      // Không cần setState vì initState chưa build xong
    } else {
      // ⏳ Chưa có → load trực tiếp qua manager và lắng nghe
      manager.loadAd(
        backgroundColor: widget.backgroundColor,
        ctaColor: widget.ctaColor,
      );
      // Poll mỗi 500ms cho đến khi ready
      _pollUntilReady();
    }
  }

  void _pollUntilReady() {
    Future.doWhile(() async {
      Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return false; // dừng nếu widget bị dispose
      if (NativeAdManager().isReady) {
        setState(() {
          _nativeAd = NativeAdManager().getAd();
          _isLoaded = true;
        });
        return false; // dừng poll
      }
      return true; // tiếp tục poll
    });
  }

  @override
  void dispose() {
    // KHÔNG dispose ad ở đây vì manager đang giữ
    // Chỉ báo manager reset để preload lại
    NativeAdManager().onAdWidgetDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox(height: 160);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(
            width: double.infinity,
            height: 160,
            child: AdWidget(ad: _nativeAd!),
          ),
        ],
      ),
    );
  }
}
import 'dart:async';
import 'dart:ui';
import 'package:dovui/pages/ads/ads_service.dart';

/// ✅ Safe ad loader that never blocks UI or crashes
class SafeAdLoader {
  static const _loadTimeout = Duration(seconds: 5);
  static const _loadDelay = Duration(milliseconds: 800);

  /// Load native ad safely (non-blocking, non-crashing)
  static void loadNativeAdSafely({
    bool skipIfDebug = true,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) {
    // Skip ad loading in debug mode to avoid device issues
    if (skipIfDebug) {
      print('[SafeAdLoader] Skipping ad load (debug)');
      return;
    }

    // Delay ad load to avoid contention with navigation
    // Future.delayed(_loadDelay, () {
    //   _loadWithTimeout(
    //     () async {
    //       try {
    //         NativeAdWidget();
    //         onSuccess?.call();
    //       } catch (e) {
    //         onError?.call(e.toString());
    //         print('[SafeAdLoader] Native ad failed: $e');
    //       }
    //     },
    //   );
    // });
  }

  /// Load interstitial ad safely
  static void loadInterstitialAdSafely({
    bool skipIfDebug = true,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) {
    if (skipIfDebug) {
      print('[SafeAdLoader] Skipping interstitial (debug)');
      return;
    }

    Future.delayed(_loadDelay, () {
      _loadWithTimeout(
        () async {
          try {
            InterstitialAdManager().loadAd();
            onSuccess?.call();
          } catch (e) {
            onError?.call(e.toString());
            print('[SafeAdLoader] Interstitial failed: $e');
          }
        },
      );
    });
  }

  /// Load rewarded ad safely
  static void loadRewardedAdSafely({
    bool skipIfDebug = true,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) {
    if (skipIfDebug) {
      print('[SafeAdLoader] Skipping rewarded (debug)');
      return;
    }

    Future.delayed(_loadDelay, () {
      _loadWithTimeout(
        () async {
          try {
            RewardedAdManager().loadAd();
            onSuccess?.call();
          } catch (e) {
            onError?.call(e.toString());
            print('[SafeAdLoader] Rewarded ad failed: $e');
          }
        },
      );
    });
  }

  /// Internal: Load with timeout protection
  static Future<void> _loadWithTimeout(Future<void> Function() loader) async {
    try {
      await loader().timeout(
        _loadTimeout,
        onTimeout: () {
          print('[SafeAdLoader] Ad load timed out after ${_loadTimeout.inSeconds}s');
        },
      );
    } catch (e) {
      print('[SafeAdLoader] Ad load exception: $e');
      // Continue silently - ads are not critical
    }
  }

  /// Check if we're in debug mode
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(() {
      inDebugMode = true;
      return true;
    }());
    return inDebugMode;
  }
}

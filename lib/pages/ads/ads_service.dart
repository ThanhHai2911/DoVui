import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static RewardedAd? _rewardedAd;

  // ID thật của bạn
  static const String rewardedAdUnitId =
    'ca-app-pub-2371706562137273~1093591053';

  /// Load quảng cáo
  static void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      // Callback khi load xong
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          print('✅ Rewarded Ad Loaded');
        },
        onAdFailedToLoad: (error) {
          print('❌ Failed to load rewarded ad: $error');
        },
      ),
    );
  }

  /// Hiển thị quảng cáo
  static void showRewardedAd(Function onRewardEarned) {
    if (_rewardedAd == null) {
      print('⚠️ Ad chưa load');
      loadRewardedAd(); // load lại cho lần sau
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('🛑 Rewarded Ad dismissed');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Failed to show rewarded ad: $error');
        ad.dispose();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('🎁 User earned reward: ${reward.amount} ${reward.type}');
        onRewardEarned();
      },
    );

    _rewardedAd = null;
    loadRewardedAd(); // load sẵn cho lần sau
  }
}
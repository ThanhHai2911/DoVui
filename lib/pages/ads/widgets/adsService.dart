import 'package:shared_preferences/shared_preferences.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  bool isVip = false;

  void setVip(bool value) {
    isVip = value;
  }

  bool get shouldShowAds => !isVip;
  // Gọi khi app khởi động
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isVip = prefs.getBool('is_vip') ?? false;
  }
}
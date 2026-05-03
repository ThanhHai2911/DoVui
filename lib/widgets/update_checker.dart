import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'update_dialog.dart';

class UpdateChecker {
  static final UpdateChecker _instance = UpdateChecker._internal();
  factory UpdateChecker() => _instance;
  UpdateChecker._internal();

  // ── Config ─────────────────────────────────────────────────────────────────
  // Android: package name của app
  static const String _androidPackage = 'com.thanhhai.dovui';
  // iOS: Apple ID (số) trong App Store Connect — ví dụ: '123456789'
  static const String _iosAppId = 'YOUR_APPLE_APP_ID';
  // ───────────────────────────────────────────────────────────────────────────

  /// Gọi hàm này trong HomeScreen.initState() hoặc sau khi user login
  Future<void> checkAndShow(BuildContext context) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      final storeVersion = Platform.isIOS
          ? await _getIosVersion()
          : await _getAndroidVersion();

      if (storeVersion == null) {
        debugPrint('UpdateChecker: không lấy được version từ store');
        return;
      }

      debugPrint('UpdateChecker: current=$currentVersion store=$storeVersion');

      if (_isNewer(storeVersion, currentVersion)) {
        if (context.mounted) {
          UpdateDialog.show(
            context,
            currentVersion: currentVersion,
            newVersion: storeVersion,
          );
        }
      }
    } catch (e) {
      debugPrint('UpdateChecker error: $e');
    }
  }

  // ── Android: lấy version từ Google Play ────────────────────────────────────
  Future<String?> _getAndroidVersion() async {
    try {
      final url = Uri.parse(
          'https://play.google.com/store/apps/details?id=$_androidPackage&hl=vi');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Parse version từ HTML của Play Store
        final regex = RegExp(r'\[\[\["(\d+\.\d+\.?\d*)"');
        final match = regex.firstMatch(response.body);
        return match?.group(1);
      }
    } catch (e) {
      debugPrint('Android version check failed: $e');
    }
    return null;
  }

  // ── iOS: lấy version từ iTunes API ─────────────────────────────────────────
  Future<String?> _getIosVersion() async {
    try {
      final url = Uri.parse(
          'https://itunes.apple.com/lookup?id=$_iosAppId&country=vn');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['results'] as List?;
        if (results != null && results.isNotEmpty) {
          return results.first['version'] as String?;
        }
      }
    } catch (e) {
      debugPrint('iOS version check failed: $e');
    }
    return null;
  }

  /// So sánh version: trả về true nếu storeVersion > currentVersion
  bool _isNewer(String storeVersion, String currentVersion) {
    final store = _parseVersion(storeVersion);
    final current = _parseVersion(currentVersion);

    for (int i = 0; i < store.length; i++) {
      final s = i < store.length ? store[i] : 0;
      final c = i < current.length ? current[i] : 0;
      if (s > c) return true;
      if (s < c) return false;
    }
    return false;
  }

  List<int> _parseVersion(String version) {
    return version
        .split('.')
        .map((v) => int.tryParse(v.trim()) ?? 0)
        .toList();
  }
}
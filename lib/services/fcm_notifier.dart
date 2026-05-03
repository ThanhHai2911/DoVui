import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FcmNotifier {
  static final FcmNotifier _instance = FcmNotifier._internal();
  factory FcmNotifier() => _instance;
  FcmNotifier._internal();

  // ────────────────────────────────────────────────────────────────────────────
  // Lấy tại: Firebase Console → Project Settings → Service Accounts
  //          → Generate new private key → mở file JSON → copy các giá trị
  // ────────────────────────────────────────────────────────────────────────────
  static const _projectId = 'dovui-53c35';

  static const _serviceAccountEmail =
      'firebase-adminsdk-fbsvc@dovui-53c35.iam.gserviceaccount.com'; // ← thay

  // Copy đúng nguyên văn từ file JSON, giữ \n
  static const _privateKey = '''-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCkayxiuKjt/jpm
Hcz6sOgf7LmGEFRQ22pGQm7oO6MrHlkpCi9GAruVnGJs+DuedDZPas51id17F0uy
PjZkShIIUUn4bu7UcT2tJX6kyxwLYpI0gRig9oPI8yMyRpAYSBbMEVj/x5cdYU6A
z6z5THGf7veHFjpsoYsIO3TyOZGkI+F4GEqv0rgidqAxTFVA/FHTRalX53UUD6vo
BkuD8PSU/6LCoRMERSQSpYeWmMGWaYsDgdqKPTlHYvb/i2H+aQOdj/oYmMHLAOMI
uhzsY6CZjQV4GRjVa03m2qEEifPifvVz1+I6kot521uKKhha6xt+j9ymXntQ8JvW
DwcIFvMbAgMBAAECggEAIN3NmxRXrG9X5CbL3Ub0t8D92vczq5AYv9+yxNh7BvkD
kKkZBxEvxzniEO9UF5oaayiqCaPb8qmW95PpEoYd8ayyMSeXtT7Hue9XUADL49i5
6iXuMurkMAyuOfQSBNCQQg2rsUGICxby9tvMs27c/b/qmgXO+v0Vyjj8aRkp7Fnv
v51JzXBoC5WVnnOl/lvzdHioyRSHc1I7yvExeC8DVlk83I2mZX3LlIWVv6ZowN9H
s38FqrK7lpi6Vm4zBFMoGKn5g03wd4754EYYb+Jw4LlP2LGy7oXW/k6/4YiVeXT2
quEiXCdMFQMWuoFxtOV18l5rYc8SuGCidC3wJKXZ0QKBgQDTAZmOUZpLLKCISUv6
qZUzdtpOlYlHjJuhX5iMmA7vqRqISmz+uf7DukJ3CFvcQSxoTsXjVYtf6wVFWOz/
HYLrpnjuB48RaoVqY8ElQSTWfh5ZkZ2d1rixGGTXZ2HMhD/UAntijRrOmebbwjNE
KNayDw9/QFEDeRD7J8h1BSwnEQKBgQDHenOR0oQZcPQOT5CRvJTCw1I/sKDIl344
S4nZCmqaMJ64tXSJeecmhrxN4ZaDiwkCBJNMEbLFjKBttm/FirBx1r91uHfWbvkm
6wdG/LmP3Hx8WzsH7ogjqt7qbYkZA6oWUTDHwnYy/t2wl+EsTOgV62zAE9Luiace
IR8jvQ6vawKBgQC2zioE3Lm56x3hNO84aPc0MQINFwxqCm1Cr5lwJMS76VttPF2V
ifooBBRVH87F0UjxzV0wCQrIvMpCPDqHA0BLfFxEjBPs2MZhV68b4YZStc0BeGB/
QGmeNC4ZWB2om+LYgJX42Zqh5z/UoDjeEit+9AFPE5+cTKTjkqHej+6ioQKBgFEj
JJj+uM6kXBDqGhK9UwD5c54GWQ/eVu/NAe/vRbcb6aOV4yX8GKJaEYPYK2GsDujs
NYGufTnPXn3hxArkw6o6QDxA4TWug9dpp9ce+tdiRpxKe3NZebSQTwWpsicjj25u
bdoC5hMOCdxHmsZrLcekr+Jc7eIqyXf+3uypfKyrAoGAXtjHRexLauuKsfIL9blH
ZPz3p1QTYhzkRCzxRkCFfahuoB4efzWSPwjAi3S3un4kibeTiw3Ux5PEFx/k9/6P
w3PlmpD3SNqOA37wx6g/Aiybv7yeS2qAOIqRkrXaS+c61lIJ3GQRdp2I96n176PC
/j9Ryn8aqnGHeGaDAkg415s=
-----END PRIVATE KEY-----'''; // ← thay
  // ────────────────────────────────────────────────────────────────────────────

  String? _cachedToken;
  DateTime? _tokenExpiry;

  /// Lấy OAuth2 Access Token (có cache 55 phút)
  Future<String?> _getAccessToken() async {
    // Dùng cache nếu còn hạn
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken;
    }

    try {
      final now = DateTime.now();
      final jwt = JWT(
        {
          'iss': _serviceAccountEmail,
          'scope': 'https://www.googleapis.com/auth/firebase.messaging',
          'aud': 'https://oauth2.googleapis.com/token',
          'iat': now.millisecondsSinceEpoch ~/ 1000,
          'exp': (now.millisecondsSinceEpoch ~/ 1000) + 3600,
        },
      );

      // Ký JWT bằng RSA private key
      final token = jwt.sign(
        RSAPrivateKey(_privateKey),
        algorithm: JWTAlgorithm.RS256,
      );

      // Đổi JWT lấy Access Token từ Google
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedToken = data['access_token'] as String;
        _tokenExpiry = now.add(const Duration(minutes: 55));
        debugPrint('✅ Got FCM access token');
        return _cachedToken;
      } else {
        debugPrint('❌ Token error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Lỗi tạo JWT: $e');
      return null;
    }
  }

  /// Gửi FCM V1 đến 1 token thiết bị
  Future<bool> sendToDevice({
    required String deviceToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': deviceToken,
            'notification': {'title': title, 'body': body},
            if (data != null) 'data': data,
            'android': {
              'priority': 'high',
              'notification': {
                'channel_id': 'admin_vip_channel',
                'sound': 'default',
              },
            },
            'apns': {
              'payload': {
                'aps': {'sound': 'default', 'badge': 1},
              },
            },
          },
        }),
      );

      debugPrint('FCM [${response.statusCode}]: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Lỗi gửi FCM: $e');
      return false;
    }
  }
  Future<void> sendToUser({
  required String userId,
  required String title,
  required String body,
  Map<String, String>? data,
}) async {
  // Lấy FCM token của user từ Firestore
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();

  final token = doc.data()?['fcm_token'] as String?;
  if (token == null || token.isEmpty) return;

  await sendToMultiple(
    deviceTokens: [token],
    title: title,
    body: body,
    data: data,
  );
}

  /// Gửi đến nhiều thiết bị cùng lúc
  Future<void> sendToMultiple({
    required List<String> deviceTokens,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    for (final token in deviceTokens) {
      await sendToDevice(
        deviceToken: token,
        title: title,
        body: body,
        data: data,
      );
    }
  }
}
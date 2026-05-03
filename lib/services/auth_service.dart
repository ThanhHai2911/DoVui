// lib/services/auth_service.dart
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth_Service {
  static final _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  );

  /// Lấy OAuth2 access token để gọi FCM V1 API
  static Future<String?> getFcmAccessToken() async {
    try {
      final account = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      if (account == null) return null;
      final client = await _googleSignIn.authenticatedClient();
      return client?.credentials.accessToken.data;
    } catch (e) {
      return null;
    }
  }
}
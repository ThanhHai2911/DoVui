import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> loginAdmin(String adminName) async {
  final existing = await _firestore
      .collection('users')
      .where('name', isEqualTo: adminName)
      .limit(1)
      .get();

  String uid;

  if (existing.docs.isNotEmpty) {
    uid = existing.docs.first.id;

    await _firestore
        .collection('users')
        .doc(uid)
        .update({'isAdmin': true});
  } else {
    final newDoc = _firestore.collection('users').doc();
    uid = newDoc.id;

    await newDoc.set({
      'name': adminName,
      'score': 0,
      'rank': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'isAdmin': true,
    });
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("userId", uid);
  await prefs.setBool("isRegistered", true);
  await prefs.setBool("isAdmin", true);
}

  /// ================= LOGIN USER =================
  Future<Map<String, dynamic>> login(String name, String password) async {
    // 🔥 1. Check admin
    final adminQuery = await _firestore
        .collection('admin')
        .where('Name', isEqualTo: name)
        .limit(1)
        .get();

    if (adminQuery.docs.isNotEmpty) {
      final storedPassword =
          adminQuery.docs.first.data()['password'] as String?;

      if (storedPassword != password) {
        throw Exception("WRONG_PASSWORD");
      }

      return {
        "type": "admin",
        "name": name,
      };
    }

    // 🔥 2. Check user
    final userQuery = await _firestore
        .collection('users')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception("USER_NOT_FOUND");
    }

    final userDoc = userQuery.docs.first;
    final email = userDoc.data()['email'];

    if (email == null) {
      throw Exception("NO_EMAIL");
    }

    // 🔥 3. FirebaseAuth login
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return {
      "type": "user",
      "userDoc": userDoc,
    };
  }
  // ================= GOOGLE SIGN IN =================
  Future<Map<String, dynamic>> loginWithGoogle() async {
    // Đăng xuất Google cũ để luôn hiện màn chọn tài khoản
    await _googleSignIn.signOut();
 
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception("GOOGLE_CANCELLED");
 
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
 
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
 
    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user!;
 
    // Kiểm tra user đã tồn tại trong Firestore chưa
    final docRef = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await docRef.get();
 
    if (!docSnapshot.exists) {
      // Tạo user mới
      final displayName = firebaseUser.displayName ?? googleUser.email.split('@')[0];
      await docRef.set({
        'name': displayName,
        'email': firebaseUser.email ?? '',
        'score': 300,
        'rank': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
        'loginType': 'google',
        'avatar': firebaseUser.photoURL ?? '',
      });
    }
    
 
    // Lưu SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", firebaseUser.uid);
    await prefs.setBool("isRegistered", true);
 
    return {
      "type": "google",
      "userId": firebaseUser.uid,
      "name": firebaseUser.displayName ?? '',
    };
  }
  // ================= FACEBOOK SIGN IN =================
  Future<Map<String, dynamic>> loginWithFacebook() async {
    // Đăng xuất Facebook cũ
    await FacebookAuth.instance.logOut();
 
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );
 
    if (result.status == LoginStatus.cancelled) {
      throw Exception("FACEBOOK_CANCELLED");
    }
 
    if (result.status != LoginStatus.success) {
      throw Exception("FACEBOOK_FAILED");
    }
 
    // Lấy thông tin user từ Facebook
    final userData = await FacebookAuth.instance.getUserData(
      fields: "name,email,picture.width(200)",
    );
 
    // Đăng nhập Firebase bằng Facebook credential
    final OAuthCredential credential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);
 
    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user!;
 
    final name = userData['name'] as String? ??
        firebaseUser.displayName ??
        'Facebook User';
    final email = userData['email'] as String? ?? firebaseUser.email ?? '';
    final avatar = userData['picture']?['data']?['url'] as String? ??
        firebaseUser.photoURL ?? '';
 
    await _saveOrUpdateUser(
      uid: firebaseUser.uid,
      name: name,
      email: email,
      avatar: avatar,
      loginType: 'facebook',
    );
 
    return {
      "type": "facebook",
      "userId": firebaseUser.uid,
      "name": name,
    };
  }
 
  // ================= LƯU / CẬP NHẬT USER =================
  Future<void> _saveOrUpdateUser({
    required String uid,
    required String name,
    required String email,
    required String avatar,
    required String loginType,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    final docSnapshot = await docRef.get();
 
    if (!docSnapshot.exists) {
      // Tạo user mới
      await docRef.set({
        'name': name,
        'email': email,
        'score': 300,
        'rank': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
        'loginType': loginType,
        'avatar': avatar,
      });
    } else {
      // Cập nhật avatar nếu đã có
      await docRef.update({
        'avatar': avatar,
        'loginType': loginType,
      });
    }
 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", uid);
    await prefs.setBool("isRegistered", true);
  }
}
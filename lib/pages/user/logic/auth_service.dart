import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dovui/data/models/user_level_model.dart';

class UserLevelRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// 🔥 Lấy username từ Firestore (users collection)
  Future<String?> _getUsername() async {
    final user = _auth.currentUser;

    if (user == null) {
      print("❌ USER NULL");
      return null;
    }

    final doc =
        await _firestore.collection('users').doc(user.uid).get();

    return doc.data()?['name'];
  }

  // =========================================================
  // ✅ SAVE LEVEL
  // =========================================================
  Future<void> saveLevel({
    required String levelId,
    required int score,
  }) async {
    final username = await _getUsername();

    if (username == null) {
      print("❌ USERNAME NULL");
      return;
    }

    final status = score >= 60 ? 'completed' : 'failed';


    try {
      await _firestore.collection('level_user').doc(username).set({
        'levels': {
          levelId: {
            'score': score,
            'status': status,
          },
        },
      }, SetOptions(merge: true));

      print("✅ SAVE OK: $username - $levelId");
    } catch (e) {
      print("❌ SAVE ERROR: $e");
    }
  }

  // =========================================================
  // ✅ LOAD 1 LẦN
  // =========================================================
  Future<Map<String, UserLevelModel>> getLevelStatuses() async {
    final username = await _getUsername();

    if (username == null) return {};

    final doc =
        await _firestore.collection('level_user').doc(username).get();

    if (!doc.exists) return {};

    final data = doc.data()?['levels'] as Map<String, dynamic>?;

    if (data == null) return {};

    return data.map(
      (key, value) => MapEntry(
        key, 
        UserLevelModel.fromMap(value),
      ),
    );
  }

  // =========================================================
  // 🚀 REALTIME (TỰ UPDATE UI)
  // =========================================================
  Stream<Map<String, UserLevelModel>> getLevelStatusesStream() async* {
    final username = await _getUsername();

    if (username == null) {
      yield {};
      return;
    }

    yield* _firestore
        .collection('level_user')
        .doc(username)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data()?['levels'] as Map<String, dynamic>?;

      if (data == null) return {};

      return data.map(
        (key, value) => MapEntry(
          key,
          UserLevelModel.fromMap(value),
        ),
      );
    });
  }
}
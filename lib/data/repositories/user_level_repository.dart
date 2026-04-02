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

    final doc = await _firestore.collection('users').doc(user.uid).get();

    return doc.data()?['name'];
  }

  // =========================================================
  // ✅ SAVE LEVEL
  // =========================================================
  Future<void> saveLevel({
    required String levelId,
    required int score,
    required String userId,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final docRef = FirebaseFirestore.instance
        .collection('level_user')
        .doc("${userId}");

    await docRef.set({
      'levels': {
        levelId: {
          'score': score,
          'status': score >= 6 ? 'completed' : 'failed',
        },
      },
    }, SetOptions(merge: true)); // 🔥 giữ lại các level khác
  }

  // =========================================================
  // ✅ LOAD 1 LẦN
  // =========================================================
  Future<Map<String, UserLevelModel>> getLevelStatuses() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final doc = await _firestore.collection('level_user').doc(user.uid).get();

    if (!doc.exists) return {};

    final data = doc.data()?['levels'] as Map<String, dynamic>?;

    if (data == null) return {};

    return data.map(
      (key, value) => MapEntry(key, UserLevelModel.fromMap(value)),
    );
  }

  // =========================================================
  // 🚀 REALTIME (TỰ UPDATE UI)
  // =========================================================
  Stream<Map<String, UserLevelModel>> getLevelStatusesStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return FirebaseFirestore.instance
        .collection('level_user')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return {};

          final levels = doc.data()!['levels'] as Map<String, dynamic>?;

          if (levels == null) return {};

          return levels.map((key, value) {
            return MapEntry(key, UserLevelModel.fromMap(value));
          });
        });
  }
}

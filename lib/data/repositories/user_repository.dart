import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _userKey = "current_user_id";

  /// ================= REGISTER USER =================
  Future<AppUser> registerUser(String name) async {
    final trimmedName = name.trim();

    final existing =
        await _firestore
            .collection("users")
            .where("name", isEqualTo: trimmedName)
            .limit(1)
            .get();

    if (existing.docs.isNotEmpty) {
      throw Exception("USERNAME_EXISTS");
    }

    final doc = _firestore.collection("users").doc();

    final user = AppUser(
      id: doc.id,
      name: trimmedName,
      score: 0,
      createdAt: DateTime.now(),
    );

    await doc.set(user.toJson());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, doc.id);

    return user;
  }

  /// ================= GET CURRENT USER (1 LẦN) =================
  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userKey);

    if (userId == null) return null;

    final doc = await _firestore.collection("users").doc(userId).get();

    if (!doc.exists) return null;

    return AppUser.fromJson({
      ...doc.data()!,
      "id": doc.id, // 🔥 QUAN TRỌNG
    });
  }

  /// ================= STREAM CURRENT USER (REALTIME) =================
  Stream<AppUser?> streamCurrentUser() async* {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userKey);

    if (userId == null) {
      yield null;
      return;
    }

    yield* _firestore.collection("users").doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;

      return AppUser.fromJson({...doc.data()!, "id": doc.id});
    });
  }

  /// ================= STREAM USER BY ID =================
  Stream<AppUser?> streamUserById(String id) {
    return _firestore.collection("users").doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;

      return AppUser.fromJson({
        ...doc.data()!,
        "id": doc.id, // 🔥 BẮT BUỘC
      });
    });
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  /// ================= UPDATE SCORE =================
  Future<void> updateScore(String id, int newScore) async {
    await _firestore.collection("users").doc(id).update({"score": newScore});

    // 🔥 Sau khi đổi điểm → tính lại rank
    await updateRanks();
  }

  /// ================= STREAM LEADERBOARD (REALTIME) =================
  Stream<List<AppUser>> streamTopUsers() {
    return _firestore
        .collection("users")
        .orderBy("score", descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AppUser.fromJson({
              ...doc.data(),
              "id": doc.id, // 🔥 BẮT BUỘC
            });
          }).toList();
        });
  }

  /// ================= LOGOUT (CHỈ XOÁ LOCAL) =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> updateRanks() async {
    final snapshot =
        await _firestore
            .collection('users')
            .orderBy('score', descending: true)
            .get();

    final batch = _firestore.batch();

    for (int i = 0; i < snapshot.docs.length; i++) {
      final doc = snapshot.docs[i];
      batch.update(doc.reference, {'rank': i + 1});
    }

    await batch.commit();
  }

  Stream<int> getTotalUsersStream() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getUserStreakDaysStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return 0;

      final data = doc.data();
      if (data == null) return 0;

      final timestamp = data['createdAt'];

      if (timestamp == null) return 0;

      final createdDate = (timestamp as Timestamp).toDate();

      final days = DateTime.now().difference(createdDate).inDays;

      return days < 0 ? 0 : days;
    });
  }

  Future<void> saveLevelResult(String uid, String levelId, int correct) async {
    final ref = _firestore.collection("users").doc(uid);

    await ref.set({
      "levelResults": {levelId: correct},
    }, SetOptions(merge: true));
  }
}

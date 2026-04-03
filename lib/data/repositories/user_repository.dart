import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _userKey = "userId";

  /// ================= REGISTER USER =================
  Future<AppUser> registerUser(
  String name,
  String password,
  String email,
) async {
  final trimmedName = name.trim();
  final trimmedEmail = email.trim();

  // check username
  final existing = await _firestore
      .collection("users")
      .where("name", isEqualTo: trimmedName)
      .limit(1)
      .get();

  if (existing.docs.isNotEmpty) {
    throw Exception("USERNAME_EXISTS");
  }

  // 🔥 Firebase Auth
  final credential = await _auth.createUserWithEmailAndPassword(
    email: trimmedEmail,
    password: password,
  );

  final uid = credential.user!.uid;

  final user = AppUser(
    id: uid,
    name: trimmedName,
    score: 300,
    createdAt: DateTime.now(),
  );

  // 🔥 Firestore (KHÔNG lưu password)
  await _firestore.collection("users").doc(uid).set({
    ...user.toJson(),
    "email": trimmedEmail,
  });

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_userKey, uid);

  return user;
}

  /// ================= STREAM USER BY ID =================
  Stream<AppUser?> streamUserById(String id) {
    return _firestore.collection("users").doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromJson({
        ...doc.data()!,
        "id": doc.id,
      });
    });
  }

  Future<String?> getCurrentUserId() async {
  final firebaseUser = _auth.currentUser;
  if (firebaseUser != null) return firebaseUser.uid;

  // Fallback SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_userKey);
}

  /// ================= UPDATE SCORE =================
  Future<void> updateScore(String id, int newScore) async {
  await _firestore.collection("users").doc(id).update({"score": newScore});
  // ❌ Bỏ await updateRanks() ở đây
}

// Gọi updateRanks riêng, ví dụ chỉ gọi khi vào màn leaderboard
Future<void> updateRanks() async {
  final snapshot = await _firestore
      .collection('users')
      .orderBy('score', descending: true)
      .get();

  final batch = _firestore.batch();
  for (int i = 0; i < snapshot.docs.length; i++) {
    batch.update(snapshot.docs[i].reference, {'rank': i + 1});
  }
  await batch.commit();
}

  /// ================= STREAM LEADERBOARD =================
  Stream<List<AppUser>> streamTopUsers() {
    return _firestore
        .collection("users")
        .orderBy("score", descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return AppUser.fromJson({...doc.data(), "id": doc.id});
            }).toList());
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove("isRegistered");
    await prefs.remove("isAdmin");
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
    await _firestore.collection("users").doc(uid).set({
      "levelResults": {levelId: correct},
    }, SetOptions(merge: true));
  }
}
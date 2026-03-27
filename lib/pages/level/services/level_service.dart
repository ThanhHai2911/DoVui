import 'package:cloud_firestore/cloud_firestore.dart';

class LevelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  

  // 🔥 LOAD 1 LẦN
  Future<Map<String, String>> loadProgress(String userId) async {
    final doc = await _firestore
        .collection("levels_progress")
        .doc(userId)
        .get();

    if (!doc.exists || doc.data() == null) return {};

    final data = doc.data() as Map<String, dynamic>;

    Map<String, String> result = {};

    data.forEach((key, value) {
      if (value is Map && value["status"] != null) {
        result[key] = value["status"].toString();
      }
    });

    return result;
  }

  // 🔥 REALTIME
  Stream<Map<String, String>> streamProgress(String userId) {
    return _firestore
        .collection("levels_progress")
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return {};

      final data = doc.data() as Map<String, dynamic>;

      Map<String, String> result = {};

      data.forEach((key, value) {
        if (value is Map && value["status"] != null) {
          result[key] = value["status"].toString();
        }
      });

      return result;
    });
  }
}
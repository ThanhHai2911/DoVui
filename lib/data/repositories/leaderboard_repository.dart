import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/models/user_model.dart';

class LeaderboardRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<AppUser>> getLeaderboard() {
    return _db
        .collection('users')
        .orderBy('score', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              // Dùng fromJson cho khớp với AppUser model thực tế
              // Inject 'id' vào map vì Firestore không tự thêm vào data()
              final data = doc.data();
              data['id'] = doc.id;
              return AppUser.fromJson(data);
            }).toList());
  }

  Future<void> updateUserRank(String userId, int rank) async {
    try {
      await _db.collection('users').doc(userId).update({'rank': rank});
    } catch (_) {}
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/models/user_model.dart';

class LeaderboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppUser>> getLeaderboard() {
    return _firestore
        .collection("users")
        .orderBy("score", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AppUser.fromJson({"id": doc.id, ...doc.data()});
          }).toList();
        });
  }
}

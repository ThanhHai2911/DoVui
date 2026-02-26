import 'package:cloud_firestore/cloud_firestore.dart';

class LevelModel {
  final String id;
  final String name;

  LevelModel({
    required this.id,
    required this.name,
  });

  factory LevelModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LevelModel(
      id: doc.id, // ✅ QUAN TRỌNG
      name: data["name"] ?? "",
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final int score;
  final int rank;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.score,
    this.rank = 0,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      score: json["score"] ?? 0,
      rank: json["rank"] ?? 0,
      createdAt:
          json["createdAt"] != null
              ? (json["createdAt"] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "score": score, "rank": rank, 'createdAt': createdAt};
  }

  AppUser copyWith({String? id, String? name, int? score, int? rank, DateTime? createdAt,}) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      rank: rank ?? this.rank,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

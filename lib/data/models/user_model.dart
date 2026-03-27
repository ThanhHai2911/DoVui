import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final int score;
  final int rank;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    this.score = 300,
    this.rank = 0,
    required this.createdAt,
  }); 

  factory AppUser.fromJson(Map<String, dynamic> json) {
  final createdAt = json['createdAt'];
  return AppUser(
    id: json["id"] ?? "",
    name: json["name"] ?? "",
    score: json["score"] ?? 300,
    rank: json["rank"] ?? 0,
    createdAt: createdAt is Timestamp
        ? createdAt.toDate()
        : createdAt is DateTime
            ? createdAt
            : DateTime.now(),  // fallback an toàn
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

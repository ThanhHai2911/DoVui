class AppUser {
  final String id;
  final String name;
  final int score;
  final int rank;

  AppUser({
    required this.id,
    required this.name,
    required this.score,
    this.rank = 0,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json["id"],
      name: json["name"],
      score: json["score"] ?? 0,
      rank: json["rank"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "score": score,
      "rank": rank,
    };
  }

  AppUser copyWith({
    String? id,
    String? name,
    int? score,
    int? rank,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      rank: rank ?? this.rank,
    );
  }
}
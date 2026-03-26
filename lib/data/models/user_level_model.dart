class UserLevelModel {
  final String levelId;
  final int score;       // phần trăm đúng
  final String status;   // "completed" | "failed" | "default"

  const UserLevelModel({
    required this.levelId,
    required this.score,
    required this.status,
  });

  factory UserLevelModel.fromMap(Map<String, dynamic> map) {
    return UserLevelModel(
      levelId: map['levelId'] ?? '',
      score: map['score'] ?? 0,
      status: map['status'] ?? 'default',
    );
  }

  Map<String, dynamic> toMap() => {
        'levelId': levelId,
        'score': score,
        'status': status,
      };
}
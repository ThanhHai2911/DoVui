class UserLevelModel {
  final int score;
  final String status;

  UserLevelModel({
    required this.score,
    required this.status,
  });

  factory UserLevelModel.fromMap(Map<String, dynamic> map) {
    return UserLevelModel(
      score: map['score'] ?? 0,
      status: map['status'] ?? 'default',
    );
  }
}
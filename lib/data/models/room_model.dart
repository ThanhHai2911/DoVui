class RoomModel {
  final String roomId;
  final String hostId;
  final String hostName;
  final String categoryId;
  final String categoryName;
  final String password;
  final String status;
  final String type;
  final int questionCount;
  final int timePerQuestion;
  final List<RoomPlayer> players;
  final DateTime createdAt;
  final int? startedAt;
  final String? currentLevelId;

  RoomModel({
    required this.roomId,
    required this.hostId,
    required this.hostName,
    required this.categoryId,
    required this.categoryName,
    required this.password,
    required this.status,
    required this.type,
    required this.questionCount,
    required this.timePerQuestion,
    required this.players,
    required this.createdAt,
    this.startedAt,
    this.currentLevelId,
  });

  Map<String, dynamic> toMap() => {
        'roomId': roomId,
        'hostId': hostId,
        'hostName': hostName,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'password': password,
        'status': status,
        'type': type,
        'questionCount': questionCount,
        'timePerQuestion': timePerQuestion,
        'players': players.map((p) => p.toMap()).toList(),
        'createdAt': createdAt.millisecondsSinceEpoch,
        if (startedAt != null) 'startedAt': startedAt,
        if (currentLevelId != null) 'currentLevelId': currentLevelId,
      };

  factory RoomModel.fromMap(Map<String, dynamic> m) => RoomModel(
        roomId: m['roomId'] ?? '',
        hostId: m['hostId'] ?? '',
        hostName: m['hostName'] ?? '',
        categoryId: m['categoryId'] ?? '',
        categoryName: m['categoryName'] ?? '',
        password: m['password'] ?? '',
        status: m['status'] ?? 'waiting',
        type: m['type'] ?? 'soman',
        questionCount: m['questionCount'] ?? 10,
        timePerQuestion: m['timePerQuestion'] ?? 20,
        players: (m['players'] as List<dynamic>? ?? [])
            .map((e) => RoomPlayer.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['createdAt'] ?? 0),
        startedAt: m['startedAt'],
        currentLevelId: m['currentLevelId'],
      );

  RoomModel copyWith({
    String? status,
    List<RoomPlayer>? players,
    int? startedAt,
    String? currentLevelId,
  }) =>
      RoomModel(
        roomId: roomId,
        hostId: hostId,
        hostName: hostName,
        categoryId: categoryId,
        categoryName: categoryName,
        password: password,
        status: status ?? this.status,
        type: type,
        questionCount: questionCount,
        timePerQuestion: timePerQuestion,
        players: players ?? this.players,
        createdAt: createdAt,
        startedAt: startedAt ?? this.startedAt,
        currentLevelId: currentLevelId ?? this.currentLevelId,
      );
}

// ─────────────────────────────────────────────────────────────
class RoomPlayer {
  final String userId;
  final String displayName;
  final int score;
  final bool isReady;
  final bool isHost;
  final bool isFinished; // ✅ trạng thái hoàn thành vòng chơi
  final DateTime joinedAt;

  RoomPlayer({
    required this.userId,
    required this.displayName,
    required this.score,
    required this.isReady,
    required this.isHost,
    this.isFinished = false,
    required this.joinedAt,
  });

  RoomPlayer copyWith({
    int? score,
    bool? isReady,
    bool? isHost,
    bool? isFinished,
  }) =>
      RoomPlayer(
        userId: userId,
        displayName: displayName,
        score: score ?? this.score,
        isReady: isReady ?? this.isReady,
        isHost: isHost ?? this.isHost,
        isFinished: isFinished ?? this.isFinished,
        joinedAt: joinedAt,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'displayName': displayName,
        'score': score,
        'isReady': isReady,
        'isHost': isHost,
        'isFinished': isFinished, // ✅
        'joinedAt': joinedAt.millisecondsSinceEpoch,
      };

  factory RoomPlayer.fromMap(Map<String, dynamic> m) => RoomPlayer(
        userId: m['userId'] ?? '',
        displayName: m['displayName'] ?? 'Ẩn danh',
        score: m['score'] ?? 0,
        isReady: m['isReady'] ?? false,
        isHost: m['isHost'] ?? false,
        isFinished: m['isFinished'] ?? false, // ✅ default false cho data cũ
        joinedAt:
            DateTime.fromMillisecondsSinceEpoch(m['joinedAt'] ?? 0),
      );
}
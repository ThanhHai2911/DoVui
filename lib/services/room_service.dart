import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/models/room_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoomService {
  static final _db = FirebaseFirestore.instance;
  static final _roomsRef = _db.collection('rooms');

  static String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  static Future<RoomModel?> createRoom({
    required String categoryId,
    required String categoryName,
    required String password,
    required int questionCount,
    required String type,
    required int timePerQuestion,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      final userDoc = await _db.collection('users').doc(userId).get();
      final name =
          userDoc.exists
              ? (userDoc.data()!['name'] ?? 'Ẩn danh').toString()
              : 'Ẩn danh';

      String roomId;
      bool exists = true;
      do {
        roomId = _generateRoomCode();
        final doc = await _roomsRef.doc(roomId).get();
        exists = doc.exists;
      } while (exists);

      final host = RoomPlayer(
        userId: userId,
        displayName: name,
        score: 0,
        isReady: true,
        isHost: true,
        isFinished: false,
        joinedAt: DateTime.now(),
      );

      final room = RoomModel(
        roomId: roomId,
        hostId: userId,
        hostName: name,
        categoryId: categoryId,
        categoryName: categoryName,
        password: password,
        status: 'waiting',
        type: type,
        questionCount: questionCount,
        timePerQuestion: timePerQuestion,
        players: [host],
        createdAt: DateTime.now(),
      );

      await _roomsRef.doc(roomId).set(room.toMap());
      return room;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> joinRoom({
    required String roomId,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      final userDoc = await _db.collection('users').doc(userId).get();
      final displayName =
          userDoc.exists
              ? (userDoc.data()!['name'] ?? 'Ẩn danh').toString()
              : 'Ẩn danh';

      final doc = await _roomsRef.doc(roomId).get();
      if (!doc.exists) return 'Không tìm thấy phòng';

      final room = RoomModel.fromMap(doc.data()!);
      if (room.password.isNotEmpty && room.password != password) {
        return 'Sai mật khẩu';
      }
      if (room.players.length >= 8) return 'Phòng đã đầy';
      if (room.players.any((p) => p.userId == userId)) return null;

      final newPlayer = RoomPlayer(
        userId: userId,
        displayName: displayName,
        score: 0,
        isReady: false,
        isHost: false,
        isFinished: false,
        joinedAt: DateTime.now(),
      );

      await _roomsRef.doc(roomId).update({
        'players': FieldValue.arrayUnion([newPlayer.toMap()]),
      });

      return null;
    } catch (e) {
      return 'Lỗi kết nối';
    }
  }

  /// Rời phòng bình thường (không xóa điểm).
  /// Nếu là host hoặc phòng trống → xóa phòng.
  static Future<void> leaveRoom(String roomId, String userId) async {
    try {
      final doc = await _roomsRef.doc(roomId).get();
      if (!doc.exists) return;

      final room = RoomModel.fromMap(doc.data()!);
      final updatedPlayers =
          room.players.where((p) => p.userId != userId).toList();

      if (updatedPlayers.isEmpty || room.hostId == userId) {
        await _roomsRef.doc(roomId).delete();
      } else {
        await _roomsRef.doc(roomId).update({
          'players': updatedPlayers.map((p) => p.toMap()).toList(),
        });
      }
    } catch (_) {}
  }

  /// Rời phòng VÀ xóa toàn bộ điểm tích lũy của player này trong phòng.
  /// - Xóa player khỏi danh sách players trong room document.
  /// - Nếu là host hoặc phòng trống sau khi rời → xóa toàn bộ room document.
  /// - Không hoàn lại stars đã cộng vào user document (stars là phần thưởng đã nhận).
  static Future<void> leaveAndWipePlayer(String roomId, String userId) async {
    try {
      final doc = await _roomsRef.doc(roomId).get();
      if (!doc.exists) return;

      final room = RoomModel.fromMap(doc.data()!);
      final updatedPlayers =
          room.players.where((p) => p.userId != userId).toList();

      if (updatedPlayers.isEmpty || room.hostId == userId) {
        // Host thoát hoặc phòng rỗng → xóa toàn bộ phòng
        await _roomsRef.doc(roomId).delete();
        debugPrint('[RoomService] leaveAndWipe: room $roomId deleted');
      } else {
        // Xóa player ra khỏi danh sách (kéo theo điểm của họ biến mất)
        await _roomsRef.doc(roomId).update({
          'players': updatedPlayers.map((p) => p.toMap()).toList(),
        });
        debugPrint(
          '[RoomService] leaveAndWipe: player $userId removed from $roomId',
        );
      }
    } catch (e) {
      debugPrint('[RoomService] leaveAndWipe error: $e');
    }
  }

  // ✅ Gộp reset isFinished + set playing thành 1 write duy nhất
  static Future<void> startGameWithReset(String roomId) async {
    final doc = await _roomsRef.doc(roomId).get();
    if (!doc.exists) return;

    final room = RoomModel.fromMap(doc.data()!);

    // Reset isFinished cho tất cả players, GIỮ điểm (điểm cộng dồn)
    final updatedPlayers =
        room.players.map((p) => p.copyWith(isFinished: false)).toList();

    String? firstLevelId;
    if (['level', 'imagequiz', 'man', 'soman'].contains(room.type)) {
      final subcollection = _subcollectionOf(room.type);
      final levelSnap =
          await _db
              .collection('categories')
              .doc(room.categoryId)
              .collection(subcollection)
              .orderBy('order')
              .limit(1)
              .get();
      if (levelSnap.docs.isNotEmpty) {
        firstLevelId = levelSnap.docs.first.id;
      }
    }

    final newStartedAt = DateTime.now().millisecondsSinceEpoch;
    debugPrint('[RoomService] startGameWithReset: newStartedAt=$newStartedAt');

    await _roomsRef.doc(roomId).update({
      'status': 'playing',
      'startedAt': newStartedAt,
      'players': updatedPlayers.map((p) => p.toMap()).toList(),
      if (firstLevelId != null) 'currentLevelId': firstLevelId,
    });
  }

  static String _subcollectionOf(String type) {
    switch (type) {
      case 'man':
        return 'mans';
      case 'imagequiz':
        return 'levels';
      case 'level':
        return 'levels';
      default:
        return 'levels';
    }
  }

  static Future<void> updateScore({
    required String roomId,
    required String userId,
    required int delta,
  }) async {
    try {
      final doc = await _roomsRef.doc(roomId).get();
      if (!doc.exists) return;

      final room = RoomModel.fromMap(doc.data()!);
      final updatedPlayers =
          room.players.map((p) {
            if (p.userId == userId) return p.copyWith(score: p.score + delta);
            return p;
          }).toList();

      await _roomsRef.doc(roomId).update({
        'players': updatedPlayers.map((p) => p.toMap()).toList(),
      });
    } catch (_) {}
  }

  static Future<void> markPlayerFinished(String roomId, String userId) async {
    try {
      debugPrint(
        '[RoomService] markPlayerFinished called - roomId=$roomId, userId=$userId',
      );
      final doc = await _roomsRef.doc(roomId).get();
      if (!doc.exists) {
        debugPrint('[RoomService] Room not found!');
        return;
      }

      final room = RoomModel.fromMap(doc.data()!);
      final updated =
          room.players.map((p) {
            if (p.userId == userId) {
              debugPrint('[RoomService] Setting player $userId as finished');
              return p.copyWith(isFinished: true);
            }
            return p;
          }).toList();

      await _roomsRef.doc(roomId).update({
        'players': updated.map((p) => p.toMap()).toList(),
      });
      debugPrint('[RoomService] markPlayerFinished completed');
    } catch (e) {
      debugPrint('[RoomService] markPlayerFinished error: $e');
    }
  }

  static Future<void> resetFinishedFlags(String roomId) async {
    try {
      final doc = await _roomsRef.doc(roomId).get();
      if (!doc.exists) return;

      final room = RoomModel.fromMap(doc.data()!);
      final updated =
          room.players.map((p) => p.copyWith(isFinished: false)).toList();

      await _roomsRef.doc(roomId).update({
        'players': updated.map((p) => p.toMap()).toList(),
      });
    } catch (_) {}
  }

  static Future<void> finishGame({
    required String roomId,
    required List<RoomPlayer> players,
  }) async {
    try {
      debugPrint('[RoomService] 🎮 finishGame called for room=$roomId');

      final batch = _db.batch();

      // Set status về waiting → quay về lobby
      batch.update(_roomsRef.doc(roomId), {'status': 'waiting'});

      // Cộng stars cho từng player dựa trên điểm ván này
      int starCount = 0;
      for (final p in players) {
        if (p.score > 0) {
          debugPrint(
            '[RoomService] ⭐ Adding ${p.score} stars to ${p.displayName}',
          );
          batch.update(_db.collection('users').doc(p.userId), {
            'stars': FieldValue.increment(p.score),
          });
          starCount += p.score;
        }
      }

      debugPrint(
        '[RoomService] 💾 Committing batch... (status + $starCount stars)',
      );
      await batch.commit();
      debugPrint(
        '[RoomService] ✅ finishGame completed - status updated to waiting',
      );
    } catch (e) {
      debugPrint('[RoomService] ❌ finishGame error: $e');
      rethrow;
    }
  }

  /// Reset phòng về waiting, GIỮ điểm tích lũy, reset isFinished
  static Future<void> resetRoom(String roomId) async {
    final doc = await _roomsRef.doc(roomId).get();
    if (!doc.exists) return;

    final room = RoomModel.fromMap(doc.data()!);
    final updatedPlayers =
        room.players.map((p) => p.copyWith(isFinished: false)).toList();

    await _roomsRef.doc(roomId).update({
      'status': 'waiting',
      'startedAt': FieldValue.delete(),
      'currentLevelId': FieldValue.delete(),
      'players': updatedPlayers.map((e) => e.toMap()).toList(),
    });
  }

  static Stream<RoomModel?> roomStream(String roomId) {
    return _roomsRef.doc(roomId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return RoomModel.fromMap(snap.data()!);
    });
  }

  static Stream<Map<String, int>> presenceStream(String roomId) {
    return _roomsRef.doc(roomId).collection('presence').snapshots().map((snap) {
      final map = <String, int>{};
      for (final doc in snap.docs) {
        map[doc.id] = doc.data()['lastSeen'] ?? 0;
      }
      return map;
    });
  }

  // Trong room_service.dart
  static Future<void> setPlayerReady(
  String roomId,
  String userId,
  bool isReady,
) async {
  try {
    final roomRef = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId);

    final snapshot = await roomRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final players = (data['players'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final index = players.indexWhere((p) => p['userId'] == userId);
    if (index == -1) return;

    players[index]['isReady'] = isReady;

    await roomRef.update({'players': players});
  } catch (e) {
    debugPrint('setPlayerReady error: $e');
  }
}
static Future<void> resetAllPlayersReady(String roomId) async {
  try {
    final roomRef = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId);

    final snapshot = await roomRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final players = (data['players'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    for (final p in players) {
      // Host giữ nguyên, non-host reset về false
      if (p['isHost'] != true) {
        p['isReady'] = false;
      }
    }

    await roomRef.update({'players': players});
  } catch (e) {
    debugPrint('resetAllPlayersReady error: $e');
  }
}
}

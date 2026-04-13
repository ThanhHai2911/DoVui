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
      final name = userDoc.exists
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
      final displayName = userDoc.exists
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

  // ✅ Gộp reset isFinished + set playing thành 1 write duy nhất
  // Tránh race condition giữa 2 write riêng biệt
  static Future<void> startGameWithReset(String roomId) async {
    final doc = await _roomsRef.doc(roomId).get();
    if (!doc.exists) return;

    final room = RoomModel.fromMap(doc.data()!);

    // Reset isFinished cho tất cả players
    final updatedPlayers = room.players
        .map((p) => p.copyWith(isFinished: false))
        .toList();

    // Tìm level đầu tiên nếu cần
    String? firstLevelId;
    if (['level', 'imagequiz', 'man', 'soman'].contains(room.type)) {
      final subcollection = _subcollectionOf(room.type);
      final levelSnap = await _db
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

    // ✅ 1 write duy nhất: reset isFinished + set playing + startedAt mới
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
      final updatedPlayers = room.players.map((p) {
        if (p.userId == userId) return p.copyWith(score: p.score + delta);
        return p;
      }).toList();

      await _roomsRef.doc(roomId).update({
        'players': updatedPlayers.map((p) => p.toMap()).toList(),
      });
    } catch (_) {}
  }

  static Future<void> markPlayerFinished(
    String roomId,
    String userId,
  ) async {
    try {
      print('[RoomService] markPlayerFinished called - roomId=$roomId, userId=$userId');
      final doc = await _roomsRef.doc(roomId).get();
      if (!doc.exists) {
        print('[RoomService] Room not found!');
        return;
      }

      final room = RoomModel.fromMap(doc.data()!);
      final updated = room.players.map((p) {
        if (p.userId == userId) {
          print('[RoomService] Setting player $userId as finished');
          return p.copyWith(isFinished: true);
        }
        return p;
      }).toList();

      await _roomsRef.doc(roomId).update({
        'players': updated.map((p) => p.toMap()).toList(),
      });
      print('[RoomService] markPlayerFinished completed');
    } catch (e) {
      print('[RoomService] markPlayerFinished error: $e');
    }
  }

  // Giữ lại để dùng nếu cần, nhưng startGameWithReset đã gộp logic này
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
      print('[RoomService] 🎮 finishGame called for room=$roomId');
      
      final batch = _db.batch();

      // ✅ Set status to 'waiting' ngay khi tất cả finish, quay về lobby
      print('[RoomService] 📝 Updating room status to "waiting"');
      batch.update(_roomsRef.doc(roomId), {'status': 'waiting'});

      // Update stars for each player
      int starCount = 0;
      for (final p in players) {
        if (p.score > 0) {
          print('[RoomService] ⭐ Adding ${p.score} stars to ${p.displayName}');
          batch.update(_db.collection('users').doc(p.userId), {
            'stars': FieldValue.increment(p.score),
          });
          starCount += p.score;
        }
      }

      print('[RoomService] 💾 Committing batch... (status + $starCount stars)');
      await batch.commit();
      print('[RoomService] ✅ finishGame completed - status updated to waiting');
    } catch (e) {
      print('[RoomService] ❌ finishGame error: $e');
      rethrow; // Make error visible
    }
  }

  // ✅ Reset phòng về waiting, GIỮ điểm, reset isFinished
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

  static Future<void> updatePresence(String roomId, String userId) async {
    try {
      await _roomsRef.doc(roomId).collection('presence').doc(userId).set({
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  static Stream<Map<String, int>> presenceStream(String roomId) {
    return _roomsRef
        .doc(roomId)
        .collection('presence')
        .snapshots()
        .map((snap) {
      final map = <String, int>{};
      for (final doc in snap.docs) {
        map[doc.id] = doc.data()['lastSeen'] ?? 0;
      }
      return map;
    });
  }

  static Future<void> removePresence(String roomId, String userId) async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('presence')
        .doc(userId)
        .delete();
  }
}
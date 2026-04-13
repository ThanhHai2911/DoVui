import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/models/room_model.dart';
import 'package:dovui/services/room_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'room_event.dart';
import 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  StreamSubscription? _roomSub;
  String _currentUserId = '';
  bool _finishGameCalled = false;

  RoomBloc() : super(const RoomState()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateRoom>(_onCreateRoom);
    on<JoinRoom>(_onJoinRoom);
    on<LeaveRoom>(_onLeaveRoom);
    on<StartGame>(_onStartGame);
    on<RoomUpdated>(_onRoomUpdated);
    on<SelectCategory>(_onSelectCategory);
    on<UpdateSettings>(_onUpdateSettings);
    on<ResetRoom>(_onResetRoom);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId') ?? '';
    if (_currentUserId.isNotEmpty) {
      debugPrint('[RoomBloc] Loaded userId: $_currentUserId');
    } else {
      debugPrint('[RoomBloc] WARNING: userId not found in prefs');
    }
  }

  Future<void> _onResetRoom(ResetRoom event, Emitter<RoomState> emit) async {
    _finishGameCalled = false;
    if (state.room == null) return;
    await RoomService.resetRoom(state.room!.roomId);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<RoomState> emit,
  ) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('categories')
          .where('type', isEqualTo: 'direct')
          .orderBy('order')
          .get();

      final cats = snap.docs.map((doc) {
        final data = doc.data();
        return CategoryItem(
          id: doc.id,
          name: data['name'] ?? doc.id,
          icon: data['icon'] ?? '📚',
          type: data['type'] ?? 'direct',
        );
      }).toList();

      final first = cats.isNotEmpty ? cats.first : null;

      emit(state.copyWith(
        categories: cats,
        selectedCategoryId: first?.id ?? '',
        selectedCategoryName: first?.name ?? '',
        selectedCategoryType: first?.type ?? 'direct',
      ));
    } catch (e) {
      debugPrint('[RoomBloc] loadCategories error: $e');
    }
  }

  void _onSelectCategory(SelectCategory event, Emitter<RoomState> emit) {
    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      selectedCategoryName: event.categoryName,
      selectedCategoryType: event.categoryType,
    ));
  }

  void _onUpdateSettings(UpdateSettings event, Emitter<RoomState> emit) {
    emit(state.copyWith(
      questionCount: event.questionCount,
      timePerQuestion: event.timePerQuestion,
    ));
  }

  Future<void> _onCreateRoom(CreateRoom event, Emitter<RoomState> emit) async {
    emit(state.copyWith(status: RoomStatus.loading));

    final room = await RoomService.createRoom(
      categoryId: event.categoryId,
      categoryName: event.categoryName,
      password: event.password,
      type: event.type,
      questionCount: event.questionCount,
      timePerQuestion: event.timePerQuestion,
    );

    if (room == null) {
      emit(state.copyWith(
        status: RoomStatus.error,
        errorMessage: 'Tạo phòng thất bại. Thử lại!',
      ));
      return;
    }

    _listenToRoom(room.roomId);
    emit(state.copyWith(
      status: RoomStatus.waiting,
      room: room,
      isHost: true,
      clearError: true,
    ));
  }

  Future<void> _onJoinRoom(JoinRoom event, Emitter<RoomState> emit) async {
    emit(state.copyWith(status: RoomStatus.loading));

    final error = await RoomService.joinRoom(
      roomId: event.roomId.toUpperCase(),
      password: event.password,
    );

    if (error != null) {
      emit(state.copyWith(status: RoomStatus.error, errorMessage: error));
      return;
    }

    final roomDoc = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(event.roomId.toUpperCase())
        .get();

    final room = roomDoc.exists ? RoomModel.fromMap(roomDoc.data()!) : null;

    _listenToRoom(event.roomId.toUpperCase());

    emit(state.copyWith(
      status: RoomStatus.waiting,
      room: room,
      isHost: false,
      clearError: true,
    ));
  }

  void _listenToRoom(String roomId) {
    _roomSub?.cancel();
    _roomSub = RoomService.roomStream(roomId).listen((room) {
      add(RoomUpdated(room));
    });
  }

  void _onRoomUpdated(RoomUpdated event, Emitter<RoomState> emit) {
    final room = event.room as RoomModel?;
    if (room == null) {
      emit(state.copyWith(status: RoomStatus.initial, clearRoom: true));
      return;
    }

    final prevStatus = state.status;

    RoomStatus newStatus = state.status;
    if (room.status == 'waiting') newStatus = RoomStatus.waiting;
    if (room.status == 'playing') newStatus = RoomStatus.playing;
    if (room.status == 'finished') newStatus = RoomStatus.finished;

    emit(state.copyWith(status: newStatus, room: room));

    // Reset flag khi rời playing
    if (prevStatus == RoomStatus.playing && newStatus != RoomStatus.playing) {
      debugPrint('[RoomBloc] Reset finishGameCalled flag');
      _finishGameCalled = false;
    }

    // ── FIX: Check allFinished trong bloc để finishGame khi cần ────────────
    // Chỉ xử lý khi đang playing và chưa gọi finishGame
    if (newStatus == RoomStatus.playing && !_finishGameCalled) {
      final allFinished =
          room.players.isNotEmpty && room.players.every((p) => p.isFinished);
      if (allFinished) {
        _finishGameCalled = true;
        debugPrint('[RoomBloc] ✅ All finished detected → calling finishGame');
        // Gọi async không await để không block emit
        RoomService.finishGame(
          roomId: room.roomId,
          players: room.players,
        ).then((_) {
          debugPrint('[RoomBloc] finishGame completed → status will update to waiting');
        }).catchError((e) {
          debugPrint('[RoomBloc] finishGame error: $e');
          _finishGameCalled = false; // Cho phép retry nếu lỗi
        });
      }
    }
  }

  Future<void> _onStartGame(StartGame event, Emitter<RoomState> emit) async {
    if (state.room == null) return;
    final roomId = state.room!.roomId;
    _finishGameCalled = false; // Reset trước khi bắt đầu game mới
    debugPrint('[RoomBloc] StartGame → roomId=$roomId');
    await RoomService.startGameWithReset(roomId);
  }

  Future<void> _onLeaveRoom(LeaveRoom event, Emitter<RoomState> emit) async {
    _roomSub?.cancel();
    if (state.room != null) {
      await RoomService.leaveRoom(state.room!.roomId, _currentUserId);
    }
    emit(const RoomState());
  }

  @override
  Future<void> close() {
    _roomSub?.cancel();
    return super.close();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:dovui/data/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dovui/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  StreamSubscription<AppUser?>? _userSubscription;
  StreamSubscription<List<AppUser>>? _leaderboardSubscription;

  UserBloc(this.repository) : super(UserInitial()) {
    on<CheckUserEvent>(_onCheckUser);
    on<RegisterUserEvent>(_onRegisterUser);
    on<UpdateScoreEvent>(_onUpdateScore);
    on<StartLeaderboardEvent>(_onStartLeaderboard);
    on<_UserUpdatedEvent>(_onUserUpdated);
    on<_LeaderboardUpdatedEvent>(_onLeaderboardUpdated);
    on<LogoutUserEvent>(_onLogoutUser);

    on<AddScoreEvent>((event, emit) async {
      if (state is UserRegistered) {
        final currentUser = (state as UserRegistered).user;
        final newScore = currentUser.score + event.amount;
        await repository.updateScore(currentUser.id, newScore);
        emit(UserRegistered(currentUser.copyWith(score: newScore)));
      }
    });
  }

  /// ================= CHECK USER =================
  Future<void> _onCheckUser(
  CheckUserEvent event,
  Emitter<UserState> emit,
) async {
  // Bỏ dòng: if (state is UserRegistered) return;
  
  emit(UserLoading());

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString("userId");

  if (userId == null) {
    emit(UserNotRegistered());
    return;
  }

  await _userSubscription?.cancel();
  _userSubscription = null;

  _userSubscription = repository.streamUserById(userId).listen(
    (user) {
      if (!isClosed) add(_UserUpdatedEvent(user));
    },
    onError: (_) {
      if (!isClosed) add(_UserUpdatedEvent(null));
    },
  );
}

  /// ================= REGISTER (UPDATED) =================
  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    try {
      // ✅ GỌI THÊM EMAIL
      final user = await repository.registerUser(
        event.name,
        event.password,
        event.email,
      );

      // ✅ THÊM DÒNG NÀY
      emit(UserRegistered(user));
    } catch (e) {
      final error = e.toString();

      if (error.contains("USERNAME_EXISTS")) {
        emit(UserError("Tên này đã tồn tại"));
      } else if (error.contains("email-already-in-use")) {
        emit(UserError("Email đã được sử dụng"));
      } else if (error.contains("invalid-email")) {
        emit(UserError("Email không hợp lệ"));
      } else if (error.contains("weak-password")) {
        emit(UserError("Mật khẩu quá yếu"));
      } else {
        emit(UserError("Đã xảy ra lỗi, vui lòng thử lại"));
      }
    }
  }

  /// ================= UPDATE SCORE =================
  Future<void> _onUpdateScore(
    UpdateScoreEvent event,
    Emitter<UserState> emit,
  ) async {
    if (state is UserRegistered) {
      final currentUser = (state as UserRegistered).user;
      final newScore = currentUser.score + event.score;
      await repository.updateScore(currentUser.id, newScore);
    }
  }

  /// ================= START LEADERBOARD =================
  Future<void> _onStartLeaderboard(
    StartLeaderboardEvent event,
    Emitter<UserState> emit,
  ) async {
    _leaderboardSubscription?.cancel();

    _leaderboardSubscription = repository.streamTopUsers().listen((users) {
      if (!isClosed) add(_LeaderboardUpdatedEvent(users));
    }, onError: (_) {});
  }

  /// ================= USER UPDATED =================
  void _onUserUpdated(_UserUpdatedEvent event, Emitter<UserState> emit) {
    if (event.user == null) {
      emit(UserNotRegistered());
    } else {
      emit(UserRegistered(event.user!));
    }
  }

  /// ================= LEADERBOARD UPDATED =================
  void _onLeaderboardUpdated(
    _LeaderboardUpdatedEvent event,
    Emitter<UserState> emit,
  ) {
    if (state is UserRegistered) {
      emit(UserRegistered((state as UserRegistered).user));
    }
  }

  /// ================= LOGOUT =================
  Future<void> _onLogoutUser(
  LogoutUserEvent event,
  Emitter<UserState> emit,
) async {
  // 1. Cancel stream TRƯỚC TIÊN để không nhận data mới
  await _userSubscription?.cancel();
  _userSubscription = null; // ✅ thêm dòng này
  await _leaderboardSubscription?.cancel();
  _leaderboardSubscription = null; // ✅ thêm dòng này

  await FirebaseAuth.instance.signOut();

  final prefs = await SharedPreferences.getInstance();
  final isAdmin = prefs.getBool("isAdmin") ?? false;
  final userId = prefs.getString("userId");

  if (isAdmin && userId != null) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isAdmin': false});
    } catch (e) {
      debugPrint("Logout admin update error: $e");
    }
  }

  await prefs.clear();

  emit(UserNotRegistered());
}

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _leaderboardSubscription?.cancel();
    return super.close();
  }
}

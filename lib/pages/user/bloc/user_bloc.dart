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

        // Cập nhật Firestore
        await repository.updateScore(currentUser.id, newScore);

        // Emit state mới để UI tự cập nhật
        emit(UserRegistered(currentUser.copyWith(score: newScore)));
      }
    });
  }

  /// ================= CHECK USER =================
  Future<void> _onCheckUser(
    CheckUserEvent event,
    Emitter<UserState> emit,
  ) async {
    // Nếu đã có user rồi thì không load lại
    if (state is UserRegistered) return;

    emit(UserLoading());

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) {
      emit(UserNotRegistered());
      return;
    }

    _userSubscription?.cancel();

    _userSubscription = repository.streamUserById(userId).listen((user) {
      add(_UserUpdatedEvent(user));
    });
  }

  /// ================= REGISTER =================
  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    try {
      final user = await repository.registerUser(event.name);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", user.id);

      add(CheckUserEvent());
    } catch (e) {
      final error = e.toString();

      if (error.contains("USERNAME_EXISTS")) {
        emit(UserError("Tên này đã tồn tại"));
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
      add(_LeaderboardUpdatedEvent(users));
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("userId");

    _userSubscription?.cancel();

    emit(UserNotRegistered());
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _leaderboardSubscription?.cancel();
    return super.close();
  }
}
  
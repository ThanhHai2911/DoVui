import 'dart:async';
import 'package:dovui/data/models/user_model.dart';
import 'package:dovui/data/repositories/user_repository.dart';
import 'package:dovui/pages/home/bloc/home_event.dart';
import 'package:dovui/pages/home/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository _userRepo = UserRepository();

  StreamSubscription<AppUser?>? _sub;
  Timer? _midnightTimer;
  AppUser? _cachedUser;
  String? _cachedUserId; // ✅ cache userId

  HomeBloc() : super(HomeLoading()) {
    on<LoadHome>(_onLoadHome);
    on<UpdateHome>(_onUpdateHome);
    on<RefreshExpDays>(_onRefreshExpDays);
  }

  Future<void> _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    final userId = await _userRepo.getCurrentUserId();

    if (userId == null) {
      emit(HomeError());
      return;
    }

    _cachedUserId = userId; // ✅ lưu lại

    await _sub?.cancel();

    _sub = _userRepo.streamUserById(userId).listen((user) {
      if (user != null && !isClosed) {
        add(UpdateHome(user));
      }
    });

    _scheduleMidnightRefresh();
  }

  void _onUpdateHome(UpdateHome event, Emitter<HomeState> emit) {
    _cachedUser = event.user;
    _emitLoaded(emit, event.user);
  }

  void _emitLoaded(Emitter<HomeState> emit, AppUser user) {
    final days = DateTime.now().difference(user.createdAt).inDays;

    emit(HomeLoaded(
      days: days,
      name: user.name,
      score: user.score,
      isVip: user.isVip,
      userId: _cachedUserId ?? '', // ✅ thêm userId
    ));
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = nextMidnight.difference(now);

    _midnightTimer = Timer(durationUntilMidnight, () {
      if (!isClosed) {
        add(RefreshExpDays());
      }
    });
  }

  void _onRefreshExpDays(RefreshExpDays event, Emitter<HomeState> emit) {
    if (_cachedUser != null) {
      _emitLoaded(emit, _cachedUser!);
    }
    _scheduleMidnightRefresh();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _midnightTimer?.cancel();
    return super.close();
  }
}
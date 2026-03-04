import 'dart:async';
import 'package:dovui/data/repositories/leaderboard_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository repository;
  StreamSubscription? _subscription;

  bool _hasLoadedOnce = false;

  LeaderboardBloc(this.repository) : super(LeaderboardLoading()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<LeaderboardUpdated>(_onUpdated);
  }

  void _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) {
    // Nếu đã load rồi thì không loading lại
    if (!_hasLoadedOnce) {
      emit(LeaderboardLoading());
      _hasLoadedOnce = true;
    }

    _subscription?.cancel();

    _subscription = repository.getLeaderboard().listen((users) {
      add(LeaderboardUpdated(users));
    });
  }

  void _onUpdated(
    LeaderboardUpdated event,
    Emitter<LeaderboardState> emit,
  ) {
    emit(LeaderboardLoaded(event.users));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

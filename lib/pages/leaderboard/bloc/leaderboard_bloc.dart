import 'dart:async';
import 'package:dovui/data/repositories/leaderboard_repository.dart';
import 'package:dovui/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
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
    if (!_hasLoadedOnce) {
      emit(LeaderboardLoading());
      _hasLoadedOnce = true;
    }

    _subscription?.cancel();

    _subscription = repository.getLeaderboard().listen((users) {
      add(LeaderboardUpdated(users));
    });
  }

  Future<void> _onUpdated(
    LeaderboardUpdated event,
    Emitter<LeaderboardState> emit,
  ) async {
    // 1. Sort theo score giảm dần
    final sorted = [...event.users]
      ..sort((a, b) => b.score.compareTo(a.score));

    // 2. Gán rank + batch update Firestore cho tất cả user có rank sai
    final List<AppUser> ranked = [];
    final List<Future<void>> updates = [];

    for (int i = 0; i < sorted.length; i++) {
      final newRank = i + 1;
      ranked.add(sorted[i].copyWith(rank: newRank));

      // Cập nhật nếu rank sai (bao gồm cả rank = 0 lúc mới tạo)
      if (sorted[i].rank != newRank) {
        updates.add(repository.updateUserRank(sorted[i].id, newRank));
      }
    }

    // Chạy tất cả update song song, không block UI
    if (updates.isNotEmpty) {
      unawaited(Future.wait(updates));
    }

    emit(LeaderboardLoaded(ranked));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  static bool _hasLoadedOnce = false;

  LeaderboardBloc() : super(LeaderboardLoading()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    if (!_hasLoadedOnce) {
      emit(LeaderboardLoading());
      await Future.delayed(const Duration(milliseconds: 1200));
      _hasLoadedOnce = true;
    }

    emit(LeaderboardLoaded());
  }
}
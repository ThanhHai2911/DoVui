import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_complete_event.dart';
import 'game_complete_state.dart';

class GameCompleteBloc
    extends Bloc<GameCompleteEvent, GameCompleteState> {
  GameCompleteBloc() : super(GameCompleteLoading()) {
    on<LoadGameResult>(_onLoadGameResult);
  }

  Future<void> _onLoadGameResult(
    LoadGameResult event,
    Emitter<GameCompleteState> emit,
  ) async {
    emit(GameCompleteLoading());

    await Future.delayed(const Duration(seconds: 2));
    // giả lập loading

    emit(GameCompleteLoaded(
      score: event.score,
      totalQuestions: event.totalQuestions,
      isWin: event.isWin,
    ));
  }
}
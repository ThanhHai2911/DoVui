import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:dovui/data/models/man_model.dart';
import 'level_event.dart';
import 'level_state.dart';

class LevelBloc extends Bloc<LevelEvent, LevelState> {

  LevelBloc() : super(LevelLoading()) {
    on<LoadLevels>(_onLoadLevels);
  }

  Future<void> _onLoadLevels(
    LoadLevels event,
    Emitter<LevelState> emit,
  ) async {

    emit(LevelLoading());

    await emit.forEach<List<LevelModel>>(
      QuizService.getLevels(event.categoryId),
      onData: (levels) {
        if (levels.isEmpty) {
          return LevelLoading();
        }
        return LevelLoaded(levels);
      },
      onError: (error, stackTrace) {
        return LevelError(error.toString());
      },
    );
  }
}
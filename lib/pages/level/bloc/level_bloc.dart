import 'package:rxdart/rxdart.dart';
import 'package:dovui/data/models/man_model.dart';
import 'package:dovui/data/models/user_level_model.dart';
import 'package:dovui/data/repositories/user_level_repository.dart';
import 'package:dovui/pages/level/bloc/level_event.dart';
import 'package:dovui/pages/level/bloc/level_state.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LevelBloc extends Bloc<LevelEvent, LevelState> {
  final _repo = UserLevelRepository();

  LevelBloc() : super(LevelLoading()) {
    on<LoadLevels>(_onLoadLevels);
  }

  Future<void> _onLoadLevels(
  LoadLevels event,
  Emitter<LevelState> emit,
) async {
  emit(LevelLoading());

  try {
    final levelsStream = QuizService.getLevels(event.categoryId);
    final statusStream = _repo.getLevelStatusesStream();

    await emit.forEach(
      Rx.combineLatest2(
        levelsStream,
        statusStream,
        (List<LevelModel> levels,
            Map<String, UserLevelModel> statuses) {
          return LevelLoaded(
            levels,
            levelStatuses: statuses,
          );
        },
      ),
      onData: (state) => state,
      onError: (error, stackTrace) {
        return LevelError(error.toString());
      },
    );
  } catch (e) {
    emit(LevelError(e.toString()));
  }
}
}
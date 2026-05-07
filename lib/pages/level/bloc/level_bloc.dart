import 'package:firebase_auth/firebase_auth.dart';
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
  final QuizService quizService;

  LevelBloc({required this.quizService}) : super(LevelLoading()) {
    on<LoadLevels>(_onLoadLevels);
    on<ResetLevelsFrom>(_onResetLevelsFrom);
  }

  Future<void> _onLoadLevels(LoadLevels event, Emitter<LevelState> emit) async {
    emit(LevelLoading());

    try {
      final levelsStream = quizService.getLevels(event.categoryId);
      final statusStream = _repo.getLevelStatusesStream();

      await emit.forEach(
        Rx.combineLatest2(levelsStream, statusStream, (
          List<LevelModel> levels,
          Map<String, UserLevelModel> statuses,
        ) {
          return LevelLoaded(levels, levelStatuses: statuses);
        }),
        onData: (state) => state,
        onError: (error, stackTrace) {
          return LevelError(error.toString());
        },
      );
    } catch (e) {
      emit(LevelError(e.toString()));
    }
  }

  Future<void> _onResetLevelsFrom(
    ResetLevelsFrom event,
    Emitter<LevelState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LevelLoaded) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final levels = currentState.levels;
    final levelIds = levels.map((l) => l.id as String).toList();

    if (event.resetOnlyOne) {
      // Chỉ reset đúng màn được chọn
      await _repo.resetLevelsFrom(
        allLevelIds: [levelIds[event.fromIndex]],
        startIndex: 0,
        userId: uid,
      );
    } else {
      await _repo.resetLevelsFrom(
        allLevelIds: levelIds,
        startIndex: event.fromIndex,
        userId: uid,
      );
    }
  }
}

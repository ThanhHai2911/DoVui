import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static bool _hasLoadedOnce = false;

  HomeBloc() : super(HomeLoading()) {
    on<LoadHome>(_onLoadHome);
  }

  Future<void> _onLoadHome(
    LoadHome event,
    Emitter<HomeState> emit,
  ) async {
    if (!_hasLoadedOnce) {
      emit(HomeLoading());

      await Future.delayed(const Duration(milliseconds: 1200));

      _hasLoadedOnce = true;
    }

    emit(HomeLoaded());
  }
}
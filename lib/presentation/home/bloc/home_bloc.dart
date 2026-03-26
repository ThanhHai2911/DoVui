import 'dart:async';
import 'package:dovui/core/utils/app_date_utils.dart';
import 'package:dovui/data/models/user_model.dart';
import 'package:dovui/data/repositories/user_repository.dart';
import 'package:dovui/presentation/home/bloc/home_event.dart';
import 'package:dovui/presentation/home/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository _userRepo = UserRepository();

  StreamSubscription<AppUser?>? _sub;

  HomeBloc() : super(HomeLoading()) {
    on<LoadHome>(_onLoadHome);
    on<UpdateHome>(_onUpdateHome);
  }

  Future<void> _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    final userId = await _userRepo.getCurrentUserId();

    if (userId == null) {
      emit(HomeError());
      return;
    }

    await _sub?.cancel();

    _sub = _userRepo.streamUserById(userId).listen((user) {

      if (user != null) {
        add(UpdateHome(user));
      }
    });
  }

  void _onUpdateHome(UpdateHome event, Emitter<HomeState> emit) {
    final user = event.user;

    final days = calculateExperienceDays(user.createdAt);

    emit(HomeLoaded(expDays: days, name: user.name, score: user.score));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

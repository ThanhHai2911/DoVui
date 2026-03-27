import 'package:dovui/data/models/user_model.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHome extends HomeEvent {}
class UpdateHome extends HomeEvent {
  final AppUser user;

  UpdateHome(this.user);
}
class RefreshExpDays extends HomeEvent {}

class AddCoinEvent extends UserEvent {
  final int amount;

  AddCoinEvent(this.amount);
}

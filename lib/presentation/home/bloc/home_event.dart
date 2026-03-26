import 'package:dovui/data/models/user_model.dart';
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

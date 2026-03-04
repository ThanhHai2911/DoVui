part of 'user_bloc.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserNotRegistered extends UserState {}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}

class UserRegistered extends UserState {
  final AppUser user;
  UserRegistered(this.user);
}

class LeaderboardLoaded extends UserState {
  final List<AppUser> users;
  LeaderboardLoaded(this.users);
}
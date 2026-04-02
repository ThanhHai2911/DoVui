part of 'user_bloc.dart';

abstract class UserEvent {}

class CheckUserEvent extends UserEvent {}

class RegisterUserEvent extends UserEvent {
  final String name;
  final String password; // ← thêm mật khẩu
  final String email;
  RegisterUserEvent(this.name, this.password, this.email);
}

class UpdateScoreEvent extends UserEvent {
  final int score;
  UpdateScoreEvent(this.score);
}

class StartLeaderboardEvent extends UserEvent {}

class LogoutUserEvent extends UserEvent {}

/// Internal
class _UserUpdatedEvent extends UserEvent {
  final AppUser? user;
  _UserUpdatedEvent(this.user);
}

class _LeaderboardUpdatedEvent extends UserEvent {
  final List<AppUser> users;
  _LeaderboardUpdatedEvent(this.users);
}

class AddScoreEvent extends UserEvent {
  final int amount;
  AddScoreEvent(this.amount);
}
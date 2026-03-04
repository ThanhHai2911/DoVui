import 'package:dovui/data/models/user_model.dart';

abstract class LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<AppUser> users;

  LeaderboardLoaded(this.users);
}
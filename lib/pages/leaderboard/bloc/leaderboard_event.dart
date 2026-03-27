import 'package:dovui/data/models/user_model.dart';

abstract class LeaderboardEvent {}

class LoadLeaderboard extends LeaderboardEvent {}


class LeaderboardUpdated extends LeaderboardEvent {
  final List<AppUser> users;

  LeaderboardUpdated(this.users);
}

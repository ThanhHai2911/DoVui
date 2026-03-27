import 'package:dovui/data/models/user_level_model.dart';

abstract class LevelState {}

class LevelInitial extends LevelState {}
class LevelLoading extends LevelState {}
class LevelError extends LevelState {
  final String message;
  LevelError(this.message);
}

class LevelLoaded extends LevelState {
  final List levels;
  final Map<String, UserLevelModel> levelStatuses; // ✅ thêm

  LevelLoaded(this.levels, {this.levelStatuses = const {}});
}
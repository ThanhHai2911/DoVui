import 'package:equatable/equatable.dart';

abstract class LevelEvent extends Equatable {
  const LevelEvent();

  @override
  List<Object?> get props => [];
}

class LoadLevels extends LevelEvent {
  final String categoryId;

  const LoadLevels(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
class ResetLevelsFrom extends LevelEvent {
  final String categoryId;
  final int fromIndex; // index của màn được chọn chơi lại

  const ResetLevelsFrom({
    required this.categoryId,
    required this.fromIndex,
  });
}
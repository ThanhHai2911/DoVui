import 'package:equatable/equatable.dart';

abstract class GameCompleteState extends Equatable {
  const GameCompleteState();

  @override
  List<Object?> get props => [];
}

class GameCompleteLoading extends GameCompleteState {}

class GameCompleteLoaded extends GameCompleteState {
  final int score;
  final int totalQuestions;
  final bool isWin;

  const GameCompleteLoaded({
    required this.score,
    required this.totalQuestions,
    required this.isWin,
  });

  @override
  List<Object?> get props => [score, totalQuestions, isWin];
}
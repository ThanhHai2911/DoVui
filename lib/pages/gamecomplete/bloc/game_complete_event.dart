import 'package:equatable/equatable.dart';

abstract class GameCompleteEvent extends Equatable {
  const GameCompleteEvent();

  @override
  List<Object?> get props => [];
}

class LoadGameResult extends GameCompleteEvent {
  final int score;
  final int totalQuestions;
  final bool isWin;

  const LoadGameResult({
    required this.score,
    required this.totalQuestions,
    required this.isWin,
  });

  @override
  List<Object?> get props => [score, totalQuestions, isWin];
}
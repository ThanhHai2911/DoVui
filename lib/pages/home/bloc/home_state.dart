import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {}
class HomeError extends HomeState {}

class HomeLoaded extends HomeState {
  final int days;   
  final String name;
  final int score;  

  HomeLoaded({
    required this.days, required this.name, required this.score,
  });
  @override
  List<Object?> get props => [days, name, score];
}
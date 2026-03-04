import 'package:equatable/equatable.dart';

abstract class TopicEvent extends Equatable {
  const TopicEvent();

  @override
  List<Object?> get props => [];
}

class LoadTopics extends TopicEvent {
  final String categoryId;

  const LoadTopics(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

import 'package:equatable/equatable.dart';
import 'package:dovui/data/models/topic_model.dart';

abstract class TopicState extends Equatable {
  const TopicState();

  @override
  List<Object?> get props => [];
}

class TopicLoading extends TopicState {}

class TopicLoaded extends TopicState {
  final List<TopicModel> topics;

  const TopicLoaded(this.topics);

  @override
  List<Object?> get props => [topics];
}

class TopicError extends TopicState {
  final String message;

  const TopicError(this.message);

  @override
  List<Object?> get props => [message];
}
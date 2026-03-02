import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:dovui/models/topic_model.dart';
import 'topic_event.dart';
import 'topic_state.dart';

class TopicBloc extends Bloc<TopicEvent, TopicState> {

  TopicBloc() : super(TopicLoading()) {
    on<LoadTopics>(_onLoadTopics);
  }

  Future<void> _onLoadTopics(
    LoadTopics event,
    Emitter<TopicState> emit,
  ) async {

    emit(TopicLoading());

    await emit.forEach<List<TopicModel>>(
      QuizService.getTopics(event.categoryId),
      onData: (topics) {
        if (topics.isEmpty) {
          return TopicLoading();
        }
        return TopicLoaded(topics);
      },
      onError: (error, stackTrace) {
        return TopicError(error.toString());
      },
    );
  }
}
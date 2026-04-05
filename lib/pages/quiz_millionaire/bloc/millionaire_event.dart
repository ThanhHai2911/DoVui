part of 'millionaire_bloc.dart';

abstract class MillionaireEvent {}

class LoadMillionaire extends MillionaireEvent {
  final String categoryId;
  final String? levelId;
  final String type;
  LoadMillionaire({required this.categoryId, required this.type, this.levelId});
}

class MillionaireSelectAnswer extends MillionaireEvent {
  final int index;
  MillionaireSelectAnswer(this.index);
}

class UseLifeline5050  extends MillionaireEvent {}
class UseLifelineHint  extends MillionaireEvent {}

// Người dùng chọn tiếp tục chơi (từ askContinue)
class ContinuePlaying  extends MillionaireEvent {}

// Người dùng chọn dừng lại (từ askContinue)
class StopAndTakePrize extends MillionaireEvent {}

// Prize ladder tự động đóng xong → chuyển câu tiếp
class PrizeLadderDismissed extends MillionaireEvent {}

class UseLifelineAudience extends MillionaireEvent {}
class MillionaireTimeTick extends MillionaireEvent {}
class MillionaireTimeUp extends MillionaireEvent {}
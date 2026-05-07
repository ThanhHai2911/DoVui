import 'package:equatable/equatable.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();
  @override
  List<Object?> get props => [];
}

class LoadCategories extends RoomEvent {}

class CreateRoom extends RoomEvent {
  final String categoryId;
  final String categoryName;
  final String password;
  final String type;
  final int questionCount;
  final int timePerQuestion;
  final String categoryImage;

  const CreateRoom({
    required this.categoryId,
    required this.categoryName,
    required this.password,
    required this.questionCount,
    required this.timePerQuestion, 
    required this.type,
    this.categoryImage = '',
  });

  @override
  List<Object?> get props =>
      [categoryId, categoryName, password, questionCount, timePerQuestion];
}

class JoinRoom extends RoomEvent {
  final String roomId;
  final String password;
  const JoinRoom({required this.roomId, required this.password});
  @override
  List<Object?> get props => [roomId, password];
}

class LeaveRoom extends RoomEvent {}

class StartGame extends RoomEvent {}

class RoomUpdated extends RoomEvent {
  final dynamic room; // RoomModel?
  const RoomUpdated(this.room);
  @override
  List<Object?> get props => [room];
}

class SelectCategory extends RoomEvent {
  final String categoryId;
  final String categoryName;
  final String categoryType; 
  final String categoryImage;
  const SelectCategory({required this.categoryId, required this.categoryName, required this.categoryType, this.categoryImage = ''});
  @override
  List<Object?> get props => [categoryId, categoryName];
}

class UpdateSettings extends RoomEvent {
  final int? questionCount;
  final int? timePerQuestion;
  const UpdateSettings({this.questionCount, this.timePerQuestion});
  @override
  List<Object?> get props => [questionCount, timePerQuestion];
}
class ResetRoom extends RoomEvent {}
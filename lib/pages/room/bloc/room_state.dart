import 'package:dovui/data/models/room_model.dart';
import 'package:equatable/equatable.dart';

enum RoomStatus { initial, loading, creating, waiting, playing, finished, error }

class CategoryItem {
  final String id;
  final String name;
  final String icon;
  final String type;
  const CategoryItem({required this.id, required this.name, required this.icon,required this.type,});
}

class RoomState extends Equatable {
  final RoomStatus status;
  final RoomModel? room;
  final List<CategoryItem> categories;
  final String selectedCategoryId;
  final String selectedCategoryName;
  final int questionCount;
  final int timePerQuestion;
  final String? errorMessage;
  final bool isHost;
  final String selectedCategoryType;

  const RoomState({
    this.status = RoomStatus.initial,
    this.room,
    this.categories = const [],
    this.selectedCategoryId = '',
    this.selectedCategoryName = '',
    this.selectedCategoryType = 'soman',
    this.questionCount = 10,
    this.timePerQuestion = 15,
    this.errorMessage,
    this.isHost = false,
  });

  RoomState copyWith({
    RoomStatus? status,
    RoomModel? room,
    List<CategoryItem>? categories,
    String? selectedCategoryId,
    String? selectedCategoryName,
    String? selectedCategoryType, 
    int? questionCount,
    int? timePerQuestion,
    String? errorMessage,
    bool? isHost,
    bool clearRoom = false,
    bool clearError = false,
  }) =>
      RoomState(
        status: status ?? this.status,
        room: clearRoom ? null : (room ?? this.room),
        categories: categories ?? this.categories,
        selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
        selectedCategoryName: selectedCategoryName ?? this.selectedCategoryName,
        selectedCategoryType: selectedCategoryType ?? this.selectedCategoryType,
        questionCount: questionCount ?? this.questionCount,
        timePerQuestion: timePerQuestion ?? this.timePerQuestion,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        isHost: isHost ?? this.isHost,
      );

  @override
  List<Object?> get props => [
        status,
        room,
        categories,
        selectedCategoryId,
        questionCount,
        timePerQuestion,
        errorMessage,
        isHost,
      ];
}
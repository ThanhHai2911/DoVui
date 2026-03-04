import 'package:dovui/presentation/category/bloc/categori_even.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_state.dart';
import 'package:dovui/services/quiz_service.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    await emit.forEach(
      QuizService.getCategories(),
      onData: (categories) {
        if (categories.isEmpty) {
          return CategoryEmpty();
        }
        return CategoryLoaded(categories);
      },
      onError: (_, __) => CategoryError("Lỗi tải dữ liệu"),
    );
  }
}
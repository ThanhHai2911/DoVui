class QuestionModel {
  final String question;
  final List<String> answers;
  final int correctIndex;
  final int order;

  QuestionModel({
    required this.question,
    required this.answers,
    required this.correctIndex,
    required this.order,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> data) {
    return QuestionModel(
      question: data['question'] ?? '',
      answers: List<String>.from(data['answers'] ?? []),
      correctIndex: data['correctIndex'] ?? 0,
      order: data['order'] ?? 0,
    );
  }
}
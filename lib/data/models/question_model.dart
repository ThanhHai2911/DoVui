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
  factory QuestionModel.fromQuizApi(Map<String, dynamic> json) {
    List<String> answers = [];
    int correctIndex = 0;

    final answerMap = json['answers'] as Map<String, dynamic>;
    final correctMap = json['correct_answers'] as Map<String, dynamic>;

    answerMap.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        answers.add(value);

        if (correctMap["${key}_correct"] == "true") {
          correctIndex = answers.length - 1;
        }
      }
    });

    return QuestionModel(
      question: json['question'] ?? "",
      answers: answers,
      correctIndex: correctIndex,
      order: 0,
    );
  }
}

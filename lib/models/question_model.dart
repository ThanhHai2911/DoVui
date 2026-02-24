class QuestionModel {
  final String question;
  final List<dynamic> answers;
  final int correctIndex;

  QuestionModel({
    required this.question,
    required this.answers,
    required this.correctIndex,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      question: map['question'],
      answers: List.from(map['answers']),
      correctIndex: map['correctIndex'],
    );
  }
}
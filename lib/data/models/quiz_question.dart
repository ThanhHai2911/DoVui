class QuizQuestion {
  final String question;
  final List<String> answers;
  final int correctIndex;
  final String? hint;

  const QuizQuestion({
    required this.question,
    required this.answers,
    required this.correctIndex,
    this.hint,
  });

  /// Từ Firestore / Map
  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question:     map['question'] as String,
      answers:      List<String>.from(map['answers'] as List),
      correctIndex: map['correctIndex'] as int,
      hint:         map['hint'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'question':     question,
        'answers':      answers,
        'correctIndex': correctIndex,
        if (hint != null) 'hint': hint,
      };
}
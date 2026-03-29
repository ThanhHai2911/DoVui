class ImageQuestion {
  final String image;
  final List<String> answers;
  final int correctIndex;

  ImageQuestion({
    required this.image,
    required this.answers,
    required this.correctIndex,
  });

  factory ImageQuestion.fromMap(Map<String, dynamic> map) {
    return ImageQuestion(
      image: map["image"] ?? "",
      answers: List<String>.from(map["answers"] ?? []),
      correctIndex: map["correctIndex"] ?? 0,
    );
  }
  
  String get correctAnswer =>
      answers.isNotEmpty ? answers[correctIndex] : "";
}
class ImageQuestion {
  final String image;
  final String answer;

  ImageQuestion({
    required this.image,
    required this.answer,
  });

  factory ImageQuestion.fromMap(Map<String, dynamic> map) {
    return ImageQuestion(
      image: map["image"],
      answer: map["answer"],
    );
  }
}
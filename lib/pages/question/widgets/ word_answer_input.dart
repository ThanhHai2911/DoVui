import 'package:flutter/material.dart';

class WordAnswerInput extends StatelessWidget {
  final List<String> userInput;
  final Function(int) onRemove;

  const WordAnswerInput({
    super.key,
    required this.userInput,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(userInput.length, (index) {
        return GestureDetector(
          onTap: () => onRemove(index),
          child: Container(
            width: 50,
            height: 55,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xff2D8CFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              userInput[index],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }
}
import 'package:flutter/material.dart';

class LetterPoolWidget extends StatelessWidget {
  final List<String> letters;
  final Function(int) onSelect;

  const LetterPoolWidget({
    super.key,
    required this.letters,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(letters.length, (index) {
        if (letters[index].isEmpty) {
          return const SizedBox(width: 45, height: 45);
        }

        return GestureDetector(
          onTap: () => onSelect(index),
          child: Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              letters[index],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }
}
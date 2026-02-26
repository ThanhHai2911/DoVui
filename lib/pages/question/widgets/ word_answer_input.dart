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
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;

        const double spacing = 8;

        // Tablet hiển thị tối đa 10 ô / hàng
        int maxPerRow = maxWidth > 600 ? 10 : 7;

        // Nếu chữ ít hơn thì lấy theo số chữ
        int itemPerRow =
            userInput.length < maxPerRow ? userInput.length : maxPerRow;

        double itemSize =
            (maxWidth - (spacing * (itemPerRow - 1))) / itemPerRow;

        // Giới hạn size nhỏ hơn để không bị to quá
        itemSize = itemSize.clamp(25.0, 35.0);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: List.generate(userInput.length, (index) {
            return GestureDetector(
              onTap: () => onRemove(index),
              child: Container(
                width: itemSize,
                height: itemSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xff2D8CFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  userInput[index],
                  style: TextStyle(
                    fontSize: itemSize * 0.45,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
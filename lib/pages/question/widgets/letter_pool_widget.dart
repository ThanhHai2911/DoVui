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
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        const double spacing = 8;

        // Tablet hiển thị nhiều hơn
        int maxPerRow = maxWidth > 600 ? 10 : 7;

        // Tính số ô mỗi hàng dựa vào tổng chữ
        int itemPerRow =
            letters.length < maxPerRow ? letters.length : maxPerRow;

        double itemSize =
            (maxWidth - (spacing * (itemPerRow - 1))) / itemPerRow;

        // Giới hạn kích thước để không quá to
        itemSize = itemSize.clamp(25.0, 35.0);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: List.generate(letters.length, (index) {
            if (letters[index].isEmpty) {
              return SizedBox(
                width: itemSize,
                height: itemSize,
              );
            }

            return GestureDetector(
              onTap: () => onSelect(index),
              child: Container(
                width: itemSize,
                height: itemSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  letters[index],
                  style: TextStyle(
                    fontSize: itemSize * 0.45,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
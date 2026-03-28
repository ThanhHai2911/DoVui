import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/pages/it_topic/topic_screen.dart';
import 'package:dovui/pages/level/level_screen.dart';
import 'package:dovui/pages/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';

class CategoriesItem extends StatelessWidget {
  final String title;
  final String image;
  final String categoryId;
  final String type;

  const CategoriesItem({
    super.key,
    required this.title,
    required this.image,
    required this.categoryId,
    required this.type,
  });

  // Màu gradient theo index hoặc type
  List<Color> _getGradient() {
    final gradients = [
      [const Color(0xFF6C63FF), const Color(0xFF9B8FFF)],
      [const Color(0xFFFF6584), const Color(0xFFFF99AA)],
      [const Color(0xFF43C6AC), const Color(0xFF77E8D2)],
      [const Color(0xFFFFB347), const Color(0xFFFFD08A)],
    ];
    final index = categoryId.codeUnitAt(0) % gradients.length;
    return gradients[index];
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradient();

    return GestureDetector(
      onTap: () {
        if (type == "kythuat") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ITTopicScreen(categoryId: categoryId),
            ),
          );
        } else if (type == "level") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  Levelscreen(categoryId: categoryId, type: type),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  QuizScreen(categoryId: categoryId, type: type),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== PHẦN ẢNH =====
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradient[0].withOpacity(0.15),
                        gradient[1].withOpacity(0.25),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Vòng tròn trang trí góc
                      Positioned(
                        top: -15,
                        right: -15,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: gradient[0].withOpacity(0.1),
                          ),
                        ),
                      ),
                      // Ảnh
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.network(
                            image,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: gradient[0],
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported_rounded,
                                color: gradient[0].withOpacity(0.5),
                                size: 40,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ===== PHẦN TITLE =====
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1B4B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Pill type tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: gradient[0].withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          type == "kythuat"
                              ? "Kỹ thuật"
                              : type == "level"
                                  ? "Theo cấp độ"
                                  : "Câu hỏi",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: gradient[0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
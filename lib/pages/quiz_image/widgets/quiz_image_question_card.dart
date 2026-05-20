import 'package:dovui/resources/color_manager.dart';
import 'package:flutter/material.dart';

/// Card showing the image to guess with a title label.
class QuizImageQuestionCard extends StatelessWidget {
  final String imageUrl;

  const QuizImageQuestionCard({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final titleFont = (w * 0.045).clamp(14.0, 22.0);

        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: w * 0.02),
          padding: EdgeInsets.symmetric(horizontal: w * 0.08, vertical: w * 0.05),
          decoration: BoxDecoration(
            color: ColorManager.cardColor,
            borderRadius: BorderRadius.circular(w * 0.06),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: w * 0.04, offset: Offset(0, w * 0.02)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '👀 Nhìn Là Biết? ✨',
                style: TextStyle(fontSize: titleFont, color: ColorManager.text, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: w * 0.05),
              _ImageFrame(imageUrl: imageUrl),
            ],
          ),
        );
      },
    );
  }
}

class _ImageFrame extends StatelessWidget {
  final String imageUrl;
  const _ImageFrame({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imageUrl,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox(
            height: 150,
            child: Center(child: Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey)),
          ),
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      ),
    );
  }
}
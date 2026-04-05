import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'millionaire_colors.dart';

class HintDialog extends StatefulWidget {
  final String question;
  final List<String> answers;

  const HintDialog({
    super.key,
    required this.question,
    required this.answers,
  });

  @override
  State<HintDialog> createState() => _HintDialogState();
}

class _HintDialogState extends State<HintDialog> {
  String? _hint;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generateHint();
  }

  Future<void> _generateHint() async {
    try {
      final answersText = widget.answers
          .asMap()
          .entries
          .map((e) => '${String.fromCharCode(65 + e.key)}. ${e.value}')
          .join('\n');

      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': dotenv.env['API_KEY']!, // ← thay bằng key thật
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-haiku-4-5-20251001',
          'max_tokens': 150,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Đây là câu hỏi trong trò chơi "Ai là triệu phú":\n\n'
                  'Câu hỏi: ${widget.question}\n'
                  'Các đáp án:\n$answersText\n\n'
                  'Hãy đưa ra một gợi ý ngắn gọn (1-2 câu) giúp người chơi suy nghĩ đúng hướng '
                  'mà KHÔNG tiết lộ đáp án trực tiếp. Chỉ trả lời gợi ý, không thêm gì khác.',
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['content'][0]['text'] as String;
        if (mounted) setState(() { _hint = text.trim(); _loading = false; });
      } else {
        if (mounted) setState(() { _hint = 'Không thể tạo gợi ý lúc này.'; _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() { _hint = 'Không thể tạo gợi ý lúc này.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0A5E), Color(0xFF0D1B6E)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                const Text(
                  'GỢI Ý',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              height: 1,
              color: const Color(0xFFFFD700).withOpacity(0.3),
            ),
            const SizedBox(height: 20),

            // Content
            _loading
                ? Column(
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(
                            const Color(0xFFFFD700).withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Đang phân tích câu hỏi...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : Text(
                    _hint!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

            const SizedBox(height: 20),

            // Close button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: const Color(0xFFFFD700), width: 1),
                ),
                child: const Text(
                  'Đã hiểu',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
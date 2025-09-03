import 'package:dovui/app/utils/const.dart';
import 'package:flutter/material.dart';

class Hometile extends StatelessWidget {
  const Hometile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
                    'Hamster Quiz Land',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: getHeight(context) * 0.02),
                  const Text('Bộ câu hỏi vui giúp mọi người giải trí'),
                  SizedBox(height: getHeight(context) * 0.08),
      ],
    );
  }
}
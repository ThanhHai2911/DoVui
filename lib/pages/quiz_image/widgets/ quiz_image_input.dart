// import 'package:flutter/material.dart';
// import '../logic/word_answer_controller.dart';

// class WordAnswerInput extends StatelessWidget {
//   final List<String> userInput;
//   final Function(int) onRemove;
//   final WordAnswerController controller; // ← thêm

//   const WordAnswerInput({
//     super.key,
//     required this.userInput,
//     required this.onRemove,
//     required this.controller, // ← thêm
//   });

//   @override
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<int>(
//       valueListenable: controller.rebuildNotifier, // ← lắng nghe thay đổi
//       builder: (context, _, __) {
//         return LayoutBuilder(
//           builder: (context, constraints) {
//             double maxWidth = constraints.maxWidth;
//             const double spacing = 8;
//             int maxPerRow = maxWidth > 600 ? 10 : 7;
//             int itemPerRow =
//                 userInput.length < maxPerRow ? userInput.length : maxPerRow;
//             double itemSize =
//                 (maxWidth - (spacing * (itemPerRow - 1))) / itemPerRow;
//             itemSize = itemSize.clamp(25.0, 35.0);

//             return Wrap(
//               spacing: spacing,
//               runSpacing: spacing,
//               alignment: WrapAlignment.center,
//               children: List.generate(userInput.length, (index) {
//                 final filled = userInput[index];
//                 final hint = controller.getHintLetter(index);
//                 final isHint = hint != null && filled.isEmpty;

//                 return GestureDetector(
//                   onTap: () => onRemove(index),
//                   child: Container(
//                     width: itemSize,
//                     height: itemSize,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       color:
//                           isHint
//                               ? Colors.amber.withOpacity(0.2)
//                               : const Color(0xff2D8CFF),
//                       border:
//                           isHint
//                               ? Border.all(color: Colors.amber, width: 1.5)
//                               : null,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       filled.isNotEmpty ? filled : hint ?? '',
//                       style: TextStyle(
//                         fontSize: itemSize * 0.45,
//                         fontWeight: FontWeight.bold,
//                         color:
//                             filled.isNotEmpty
//                                 ? Colors.white
//                                 : Colors.amber.withOpacity(0.8),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             );
//           },
//         );
//       },
//     );
//   }
// }

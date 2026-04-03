import 'package:flutter/material.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';

/// Kiểm tra điểm trước khi dùng hint.
/// Nếu đủ điểm → gọi [onConfirm] để show dialog xác nhận bình thường.
/// Nếu không đủ → show dialog thông báo hết điểm.
void checkScoreAndShowHint({
  required BuildContext context,
  required int currentScore,
  required int cost,
  required String hintIcon,
  required String hintTitle,
  required String hintDescription,
  required Color hintColor,
  required String confirmText,
  required VoidCallback onConfirm,
}) {
  if (currentScore < cost) {
    // Không đủ điểm → show dialog cảnh báo
    showGameDialog(
      context: context,
      icon: "😢",
      iconColor: Colors.red,
      title: "Không đủ sao!",
      description: "Bạn cần $cost ⭐ để dùng gợi ý này.\nHiện tại bạn chỉ có $currentScore ⭐.",
      costIcon: "⭐",
      costText: "Cần $cost sao",
      confirmText: "Đã hiểu",
      confirmColor: Colors.red,
      showCancel: false,
      onConfirm: () {},
    );
    return;
  }

  // Đủ điểm → show dialog xác nhận dùng hint
  showGameDialog(
    context: context,
    icon: hintIcon,
    iconColor: hintColor,
    title: hintTitle,
    description: hintDescription,
    costIcon: "⭐",
    costText: "Tốn $cost sao",
    confirmText: confirmText,
    confirmColor: hintColor,
    onConfirm: onConfirm,
  );
}
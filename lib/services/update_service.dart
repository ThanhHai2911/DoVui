import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class UpdateService {
  static Future<void> checkForUpdate(BuildContext context) async {
    final upgrader = Upgrader(
      debugLogging: false, // Bật true khi debug
      durationUntilAlertAgain: const Duration(days: 1), // Nhắc lại sau 1 ngày
    );

    await upgrader.initialize();

    if (!upgrader.shouldDisplayUpgrade()) return;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => UpgradeAlert(
          upgrader: upgrader,
          barrierDismissible: false,
          child: const SizedBox.shrink(),
        ),
      );
    }
  }
}
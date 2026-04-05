import 'package:flutter/material.dart';

abstract class MillionaireColors {
  // Nền sáng
  static const Color bgPage     = Color(0xFFF5F6FF);
  static const Color bgCard     = Color(0xFFFFFFFF);
  static const Color bgAnswer   = Color(0xFFF8F9FF);

  // Accent chính
  static const Color primary    = Color(0xFF5B4FE9);
  static const Color primaryLight = Color(0xFFEDEBFF);
  static const Color gold       = Color(0xFFFFB800);
  static const Color goldLight  = Color(0xFFFFF8E1);

  // Kết quả
  static const Color correct    = Color(0xFF00C48C);
  static const Color correctBg  = Color(0xFFE6FAF4);
  static const Color wrong      = Color(0xFFFF4D6A);
  static const Color wrongBg    = Color(0xFFFFECEF);

  // Text
  static const Color textDark   = Color(0xFF1A1240);
  static const Color textMid    = Color(0xFF6B6B8A);
  static const Color textLight  = Color(0xFFAAABC8);

  // Border
  static const Color border     = Color(0xFFE8E8F5);

  // Lifeline
  static const Color hintBlue   = Color(0xFF4FACFE);

  // Compat (dùng ở chỗ cũ dùng bgDeep/bgMid)
  static const Color bgDeep     = bgPage;
  static const Color bgMid      = bgCard;
}
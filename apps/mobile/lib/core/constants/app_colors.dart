import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors (matching apps/web/src/app/globals.css)
  static const Color navy = Color(0xFF0F172A);
  static const Color navyLight = Color(0xFF1E293B);
  static const Color navyDark = Color(0xFF0A0F1D);

  static const Color gold = Color(0xFFC5A55A);
  static const Color goldLight = Color(0xFFD4B96A);
  static const Color goldMuted = Color(0xFFE8D5A0);
  static const Color goldDark = Color(0xFF9E813A);

  static const Color beige = Color(0xFFF5F0EB);
  static const Color beigeDark = Color(0xFFE8DDD4);
  static const Color cream = Color(0xFFFAF8F5);

  static const Color warmGray = Color(0xFF6B6560);
  static const Color warmGrayLight = Color(0xFF9A9590);
  static const Color warmGrayExtraLight = Color(0xFFD5D0CB);

  static const Color border = Color(0xFFE5E0DB);
  static const Color borderLight = Color(0xFFF0ECE8);

  static const Color success = Color(0xFF2D6A4F);
  static const Color successLight = Color(0xFFE8F5EE);
  static const Color error = Color(0xFFC53030);
  static const Color errorLight = Color(0xFFFDF2F2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6560);

  // Gradient definitions
  static const LinearGradient luxuryNavy = LinearGradient(
    colors: [navy, navyLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryGold = LinearGradient(
    colors: [gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

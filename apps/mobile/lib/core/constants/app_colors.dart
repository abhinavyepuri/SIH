import 'package:flutter/material.dart';

class AppColors {
  // Primary Heritage Terracotta (matches reference UI exactly)
  static const Color terracotta = Color(0xFF9E3A33);
  static const Color terracottaDark = Color(0xFF8B2F29);
  static const Color terracottaLight = Color(0xFFB84E46);
  static const Color roseLight = Color(0xFFFDF2F0);
  static const Color roseTint = Color(0xFFFBEAE8);

  // Core Brand Colors (backward compatible)
  static const Color navy = Color(0xFF9E3A33); // Main theme primary
  static const Color navyLight = Color(0xFFB84E46);
  static const Color navyDark = Color(0xFF7A2520);

  // GI Tag & Heritage Gold
  static const Color gold = Color(0xFFB45309);
  static const Color goldLight = Color(0xFFD97706);
  static const Color goldMuted = Color(0xFFFEF3C7);
  static const Color goldDark = Color(0xFF92400E);

  // Background & Surfaces
  static const Color beige = Color(0xFFFAF7F5);
  static const Color beigeDark = Color(0xFFF0EAE6);
  static const Color cream = Color(0xFFFAF7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAF7F5);

  // Grays & Borders
  static const Color warmGray = Color(0xFF78716C);
  static const Color warmGrayLight = Color(0xFFA8A29E);
  static const Color warmGrayExtraLight = Color(0xFFE7E5E4);
  static const Color border = Color(0xFFEBE6E2);
  static const Color borderLight = Color(0xFFF5F0EC);

  // Status & Badges (Matching reference screens)
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFC53030);
  static const Color errorLight = Color(0xFFFDF2F2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color shippedBg = Color(0xFFE0F2FE);
  static const Color shippedText = Color(0xFF0284C7);
  static const Color inProdBg = Color(0xFFEDE9FE);
  static const Color inProdText = Color(0xFF6366F1);
  static const Color placedBg = Color(0xFFF1F5F9);
  static const Color placedText = Color(0xFF64748B);

  // Text
  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF78716C);

  // Gradients
  static const LinearGradient luxuryNavy = LinearGradient(
    colors: [Color(0xFF8B2F29), Color(0xFF9E3A33), Color(0xFFB84E46)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryGold = LinearGradient(
    colors: [Color(0xFFB45309), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroDarkGradient = LinearGradient(
    colors: [Color(0xFF3B1E19), Color(0xFF201614)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

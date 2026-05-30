import 'package:flutter/material.dart';

/// Visual tokens matching the reference TriPeaks mockups.
class GameTheme {
  // Background gradient (lighter top → deeper teal bottom).
  static const bgTop = Color(0xFF3BB5B5);
  static const bgBottom = Color(0xFF1A7A7A);

  // Panels & card backs.
  static const panelFill = Color(0x4DFFFFFF);
  static const cardBack = Color(0xFF1E6B6B);
  static const cardBackDark = Color(0xFF165858);
  static const ghostSlot = Color(0xFF2A8A8A);

  // Accents from reference.
  static const accentGold = Color(0xFFFFD54F);
  static const accentGoldDim = Color(0xFFE6B84D);
  static const timerGreen = Color(0xFF4DFF91);
  static const timerTrack = Color(0xFF0F4A4A);
  static const stockBadge = Color(0xFFFF9800);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );

  static BoxDecoration get screenDecoration => const BoxDecoration(
        gradient: backgroundGradient,
      );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static TextStyle labelStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.9),
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
  );
}

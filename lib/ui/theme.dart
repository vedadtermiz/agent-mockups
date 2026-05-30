import 'package:flutter/material.dart';

/// Visual tokens matching the reference TriPeaks mockups.
class GameTheme {
  // Background gradient — light cyan/blue, brighter at the top, matching the
  // reference screenshots (a soft turquoise that reads as "light blue").
  static const bgTop = Color(0xFF5FC8DC);
  static const bgBottom = Color(0xFF2FA3BE);

  // Panels & card backs. The card backs use a deeper teal so they stand out
  // clearly against the light background.
  static const panelFill = Color(0x33FFFFFF);
  static const cardBack = Color(0xFF2C8C8C);
  static const cardBackDark = Color(0xFF1E7373);
  static const ghostSlot = Color(0x33125F66);

  // Accents from reference.
  static const accentGold = Color(0xFFFFD54F);
  static const accentGoldDim = Color(0xFFEFC65A);
  static const timerGreen = Color(0xFF4DE08A);
  static const timerTrack = Color(0x33125F66);
  static const stockBadge = Color(0xFFFF9800);

  // Soft radial wash makes the centre of the board a touch brighter, like the
  // reference, while the linear gradient keeps the top→bottom shift.
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

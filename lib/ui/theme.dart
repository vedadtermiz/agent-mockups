import 'package:flutter/material.dart';

/// Teal gradient and card styling shared across screens.
class GameTheme {
  static const tealDark = Color(0xFF0D6E6E);
  static const tealMid = Color(0xFF1A9A9A);
  static const tealLight = Color(0xFF2EC4C4);
  static const cardBack = Color(0xFF157878);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [tealMid, tealDark],
  );

  static BoxDecoration get screenDecoration => const BoxDecoration(
        gradient: backgroundGradient,
      );
}

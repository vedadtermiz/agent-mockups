import 'package:flutter/material.dart';

import '../../models/card_model.dart';
import 'playing_card.dart';

/// Full-screen flying card between two global rectangles.
class CardFlyOverlay extends StatelessWidget {
  const CardFlyOverlay({
    super.key,
    required this.card,
    required this.from,
    required this.to,
    required this.progress,
  });

  final CardModel card;
  final Rect from;
  final Rect to;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
    final rect = Rect.lerp(from, to, t)!;
    // Slight arc: lift mid-flight.
    final arcY = -18 * (1 - (2 * t - 1) * (2 * t - 1));

    return Positioned(
      left: rect.left,
      top: rect.top + arcY,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: Material(
          type: MaterialType.transparency,
          child: PlayingCard(
            card: card,
            faceUp: true,
            width: rect.width,
            height: rect.height,
          ),
        ),
      ),
    );
  }
}

/// Reads a widget's bounds in global coordinates.
Rect? globalBoundsForKey(GlobalKey key) {
  final context = key.currentContext;
  if (context == null) return null;
  final box = context.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return null;
  final topLeft = box.localToGlobal(Offset.zero);
  return topLeft & box.size;
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game_controller.dart';
import '../../models/level_def.dart';
import '../../models/slot_def.dart';
import 'playing_card.dart';

/// Renders all peak slots from logical grid coordinates with overlap.
class PeakLayout extends StatelessWidget {
  const PeakLayout({
    super.key,
    required this.level,
    this.cardWidth = 52,
    this.cardHeight = 74,
    this.verticalOverlap = 0.58,
  });

  final LevelDef level;
  final double cardWidth;
  final double cardHeight;
  final double verticalOverlap;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, game, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final slots = level.slots;
            if (slots.isEmpty) return const SizedBox.shrink();

            final maxX = slots.map((s) => s.x).reduce((a, b) => a > b ? a : b);
            final minX = slots.map((s) => s.x).reduce((a, b) => a < b ? a : b);
            final maxY = slots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
            final minY = slots.map((s) => s.y).reduce((a, b) => a < b ? a : b);

            final gridW = (maxX - minX + 1).clamp(1.0, double.infinity);
            final gridH = (maxY - minY + 1).clamp(1.0, double.infinity);

            final hStep = cardWidth * 0.85;
            final vStep = cardHeight * verticalOverlap;

            final layoutW = gridW * hStep + cardWidth;
            final layoutH = gridH * vStep + cardHeight;

            final scale = (constraints.maxWidth / layoutW)
                .clamp(0.0, 1.0)
                .clamp(0.4, 1.0);
            final scaledW = layoutW * scale;
            final scaledH = layoutH * scale;

            final sorted = [...slots]..sort((a, b) => a.y.compareTo(b.y));

            return Center(
              child: SizedBox(
                width: scaledW,
                height: scaledH,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final slot in sorted)
                      _slotCard(
                        game: game,
                        slot: slot,
                        minX: minX,
                        minY: minY,
                        hStep: hStep * scale,
                        vStep: vStep * scale,
                        cardW: cardWidth * scale,
                        cardH: cardHeight * scale,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _slotCard({
    required GameController game,
    required SlotDef slot,
    required double minX,
    required double minY,
    required double hStep,
    required double vStep,
    required double cardW,
    required double cardH,
  }) {
    final card = game.board[slot.id];
    if (card == null) return const SizedBox.shrink();

    final faceUp = game.isFaceUp(slot.id);
    final playable = game.isPlayable(slot.id);
    final shake = game.shakeSlotId == slot.id;

    return Positioned(
      left: (slot.x - minX) * hStep,
      top: (slot.y - minY) * vStep,
      child: PlayingCard(
        card: card,
        faceUp: faceUp,
        width: cardW,
        height: cardH,
        shake: shake,
        dimmed: faceUp && !playable,
        onTap: () => game.tryPlayCard(slot.id),
      ),
    );
  }
}

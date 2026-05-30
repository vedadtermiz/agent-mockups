import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game_controller.dart';
import '../../models/level_def.dart';
import '../../models/slot_def.dart';
import 'playing_card.dart';

/// Renders peak slots with overlap matching the reference twin-pyramid layout.
class PeakLayout extends StatelessWidget {
  const PeakLayout({
    super.key,
    required this.level,
    required this.slotKeys,
    this.hiddenSlotId,
    this.onSlotTap,
    this.inputEnabled = true,
    this.cardWidth = 62,
    this.cardHeight = 88,
    this.verticalOverlap = 0.30,
  });

  final LevelDef level;
  final Map<String, GlobalKey> slotKeys;
  final String? hiddenSlotId;
  final void Function(String slotId)? onSlotTap;
  final bool inputEnabled;
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

            // Span of card *origins* in grid units (the +1 of a card is added
            // once below as `cardWidth`/`cardHeight`). Using the raw span keeps
            // the bounding box flush with the cards so `Center` truly centers it.
            final spanX = (maxX - minX).clamp(0.0, double.infinity);
            final spanY = (maxY - minY).clamp(0.0, double.infinity);

            // Horizontal step per grid unit. Level data spaces neighbouring
            // cards in a row 2 grid units apart, so 0.52 makes those cards sit
            // edge-to-edge while a parent card overlaps each child by ~half —
            // the classic TriPeaks "peeking" look.
            final hStep = cardWidth * 0.52;
            final vStep = cardHeight * verticalOverlap;

            // Tight bounding box: left origins occupy [0, spanX * hStep], and the
            // rightmost card extends a further `cardWidth` (same idea vertically).
            final layoutW = spanX * hStep + cardWidth;
            final layoutH = spanY * vStep + cardHeight;

            // Scale to fit both axes so the peaks are never clipped and stay
            // centered on screens of any size.
            final scaleW = constraints.maxWidth / layoutW;
            final scaleH = constraints.maxHeight.isFinite && constraints.maxHeight > 0
                ? constraints.maxHeight / layoutH
                : scaleW;
            // Allow the board to grow (up to 1.9x) so cards fill the available
            // space on tall screens instead of staying tiny and clumped.
            final scale = (scaleW < scaleH ? scaleW : scaleH).clamp(0.45, 1.9);
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
    if (card == null || hiddenSlotId == slot.id) {
      return const SizedBox.shrink();
    }

    final faceUp = game.isFaceUp(slot.id);
    final playable = game.isPlayable(slot.id);
    final shake = game.shakeSlotId == slot.id;
    final key = slotKeys[slot.id];

    return Positioned(
      left: (slot.x - minX) * hStep,
      top: (slot.y - minY) * vStep,
      child: KeyedSubtree(
        key: key,
        child: PlayingCard(
          card: card,
          faceUp: faceUp,
          width: cardW,
          height: cardH,
          shake: shake,
          dimmed: faceUp && !playable,
          onTap: inputEnabled
              ? () {
                  if (onSlotTap != null) {
                    onSlotTap!(slot.id);
                  } else {
                    game.tryPlayCard(slot.id);
                  }
                }
              : null,
        ),
      ),
    );
  }
}

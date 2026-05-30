import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game_controller.dart';
import '../theme.dart';
import 'playing_card.dart';

/// Waste (large, left) and stock pile (right) with orange count badge.
class StockWaste extends StatelessWidget {
  const StockWaste({
    super.key,
    required this.wasteKey,
    this.hideWaste = false,
    this.inputEnabled = true,
  });

  final GlobalKey wasteKey;
  final bool hideWaste;
  final bool inputEnabled;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, game, _) {
        final canDraw = inputEnabled && game.stockRemaining > 0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  KeyedSubtree(
                    key: wasteKey,
                    child: Opacity(
                      opacity: hideWaste ? 0.0 : 1.0,
                      child: PlayingCard(
                        card: game.waste,
                        faceUp: game.waste != null,
                        width: 76,
                        height: 108,
                      ),
                    ),
                  ),
                  if (game.showStreakFlash && game.streak > 1)
                    Positioned(
                      right: -6,
                      top: -14,
                      child: _StreakBadge(streak: game.streak),
                    ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: canDraw ? game.drawFromStock : null,
                child: _StockPile(
                  count: game.stockRemaining,
                  pulsing: canDraw && game.status == GameStatus.playing,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StockPile extends StatefulWidget {
  const _StockPile({required this.count, required this.pulsing});
  final int count;
  final bool pulsing;

  @override
  State<_StockPile> createState() => _StockPileState();
}

class _StockPileState extends State<_StockPile> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final scale = widget.pulsing ? 1.0 + 0.04 * _pulse.value : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.pulsing)
            Positioned.fill(
              child: CustomPaint(
                painter: _RingPainter(progress: _pulse.value),
              ),
            ),
          const PlayingCard(
            faceUp: false,
            isStockPile: true,
            width: 68,
            height: 96,
          ),
          if (widget.count > 0)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: GameTheme.stockBadge,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: GameTheme.cardShadow,
                ),
                child: Text(
                  '${widget.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withValues(alpha: 0.15);
    for (var i = 0; i < 2; i++) {
      final r = size.width * (0.55 + i * 0.12 + progress * 0.08);
      paint.strokeWidth = 2 - i * 0.5;
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: GameTheme.accentGold,
        borderRadius: BorderRadius.circular(10),
        boxShadow: GameTheme.cardShadow,
      ),
      child: Text(
        'x$streak',
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1A5C5C)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game_controller.dart';
import 'playing_card.dart';

/// Bottom stock pile and waste card with count badge and streak flash.
class StockWaste extends StatelessWidget {
  const StockWaste({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, game, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PlayingCard(
                    card: game.waste,
                    faceUp: game.waste != null,
                    width: 64,
                    height: 90,
                  ),
                  if (game.showStreakFlash && game.streak > 1)
                    Positioned(
                      right: -8,
                      top: -12,
                      child: _StreakBadge(streak: game.streak),
                    ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: game.drawFromStock,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const PlayingCard(faceUp: false, width: 64, height: 90),
                    if (game.stockRemaining > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${game.stockRemaining}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
          ],
        ),
        child: Text(
          'x$streak',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}

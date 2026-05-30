import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/levels.dart';
import '../../game/game_controller.dart';
import '../theme.dart';

/// Win / lose modal with retry, next level, and home actions.
class ResultOverlay extends StatelessWidget {
  const ResultOverlay({
    super.key,
    required this.onHome,
    required this.onRetry,
    required this.onNext,
  });

  final VoidCallback onHome;
  final VoidCallback onRetry;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, game, _) {
        final won = game.status == GameStatus.won;
        final lost = game.status == GameStatus.lost;
        if (!won && !lost) return const SizedBox.shrink();

        final hasNext = won && game.levelIndex < allLevels.length - 1;

        return Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(28),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GameTheme.bgTop, GameTheme.bgBottom],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    won ? 'You Win!' : 'Game Over',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: won ? GameTheme.timerGreen : Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Score: ${game.score}',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (hasNext)
                    _ActionButton(label: 'Next Level', onPressed: onNext),
                  _ActionButton(label: 'Retry', onPressed: onRetry),
                  TextButton(
                    onPressed: onHome,
                    child: const Text('Home', style: TextStyle(color: GameTheme.accentGold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: GameTheme.timerGreen,
            foregroundColor: GameTheme.bgBottom,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

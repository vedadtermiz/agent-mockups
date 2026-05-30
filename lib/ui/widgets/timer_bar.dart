import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game_controller.dart';

/// Thin progress bar and m:ss countdown for timed levels.
class TimerBar extends StatelessWidget {
  const TimerBar({super.key});

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, game, _) {
        final limit = game.level?.timeLimitSeconds ?? 0;
        if (limit <= 0) {
          return const SizedBox(height: 8);
        }
        final progress = limit > 0 ? game.secondsLeft / limit : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.black26,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      game.secondsLeft < 20 ? Colors.orangeAccent : Colors.white70,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _formatTime(game.secondsLeft),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game_controller.dart';
import '../theme.dart';

/// Bright green timer track + m:ss with gold underline (reference style).
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
          return const SizedBox(height: 12);
        }
        final progress = (game.secondsLeft / limit).clamp(0.0, 1.0);
        final urgent = game.secondsLeft < 20;

        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: GameTheme.timerTrack,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: urgent ? Colors.orangeAccent : GameTheme.timerGreen,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: GameTheme.timerGreen.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(
                    _formatTime(game.secondsLeft),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -2,
                    child: Container(height: 2, color: GameTheme.accentGold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

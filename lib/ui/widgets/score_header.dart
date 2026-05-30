import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game_controller.dart';
import '../theme.dart';

/// Full-width score panel + pause, matching reference header.
class ScoreHeader extends StatelessWidget {
  const ScoreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, game, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              color: GameTheme.panelFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SCORE', style: GameTheme.labelStyle),
                      const SizedBox(height: 2),
                      Text(
                        '${game.displayScore}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'BEST ${game.bestScore}',
                        style: const TextStyle(
                          color: GameTheme.accentGoldDim,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: game.togglePause,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Icon(Icons.pause, color: GameTheme.bgBottom, size: 26),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

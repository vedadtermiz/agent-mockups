import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/levels.dart';
import '../game/game_controller.dart';
import 'theme.dart';

/// Level picker styled like the in-game reference UI.
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key, required this.onPlay});

  final void Function(int levelIndex) onPlay;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, game, _) {
        return Container(
          decoration: GameTheme.screenDecoration,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: GameTheme.panelFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TriPeaks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Solitaire',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'BEST ${game.bestScore}',
                          style: const TextStyle(
                            color: GameTheme.accentGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: allLevels.length,
                    itemBuilder: (context, index) {
                      final level = allLevels[index];
                      final unlocked = index <= game.unlockedLevel;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: unlocked
                              ? Colors.white.withValues(alpha: 0.18)
                              : Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            enabled: unlocked,
                            leading: CircleAvatar(
                              backgroundColor:
                                  unlocked ? GameTheme.timerGreen : Colors.white24,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: unlocked ? GameTheme.bgBottom : Colors.white54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              level.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              unlocked
                                  ? '${level.slotCount} cards · ${level.timeLimitSeconds}s'
                                  : 'Locked',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                            trailing: Icon(
                              unlocked ? Icons.play_circle_fill : Icons.lock,
                              color: unlocked ? GameTheme.accentGold : Colors.white38,
                              size: 32,
                            ),
                            onTap: unlocked ? () => onPlay(index) : null,
                          ),
                        ),
                      );
                    },
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

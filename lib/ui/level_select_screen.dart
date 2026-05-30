import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/levels.dart';
import '../game/game_controller.dart';
import 'theme.dart';

/// Level picker with unlock progression from [GameController].
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
                const SizedBox(height: 24),
                const Text(
                  'TriPeaks Solitaire',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Best: ${game.bestScore}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: allLevels.length,
                    itemBuilder: (context, index) {
                      final level = allLevels[index];
                      final unlocked = index <= game.unlockedLevel;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          enabled: unlocked,
                          leading: CircleAvatar(
                            backgroundColor: unlocked ? Colors.teal : Colors.grey,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(level.name),
                          subtitle: Text(
                            unlocked
                                ? '${level.slotCount} cards · ${level.timeLimitSeconds}s'
                                : 'Locked',
                          ),
                          trailing: unlocked
                              ? const Icon(Icons.play_arrow, color: Colors.teal)
                              : const Icon(Icons.lock, color: Colors.grey),
                          onTap: unlocked ? () => onPlay(index) : null,
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

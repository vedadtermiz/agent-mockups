import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_controller.dart';
import 'overlays/result_overlay.dart';
import 'theme.dart';
import 'widgets/peak_layout.dart';
import 'widgets/score_header.dart';
import 'widgets/stock_waste.dart';
import 'widgets/timer_bar.dart';

/// Main play screen: peaks, stock/waste, timer, pause, and result overlay.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.levelIndex,
    required this.onHome,
  });

  final int levelIndex;
  final VoidCallback onHome;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _scoreTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = context.read<GameController>();
      game.loadLevelByIndex(widget.levelIndex);
      _startScoreTicker();
    });
  }

  void _startScoreTicker() {
    _scoreTicker?.cancel();
    _scoreTicker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      context.read<GameController>().tickDisplayScore(25);
    });
  }

  @override
  void dispose() {
    _scoreTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, game, _) {
        final level = game.level;
        if (level == null) {
          return Container(
            decoration: GameTheme.screenDecoration,
            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        return Container(
          decoration: GameTheme.screenDecoration,
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const ScoreHeader(),
                    const TimerBar(),
                    const SizedBox(height: 8),
                    Expanded(child: PeakLayout(level: level)),
                    const StockWaste(),
                  ],
                ),
                if (game.status == GameStatus.paused) _PauseOverlay(game: game),
                if (game.status == GameStatus.won || game.status == GameStatus.lost)
                  ResultOverlay(
                    onHome: widget.onHome,
                    onRetry: () => game.restart(),
                    onNext: () {
                      game.advanceToNextLevel();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paused', style: TextStyle(color: Colors.white, fontSize: 28)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: game.togglePause,
              child: const Text('Resume'),
            ),
          ],
        ),
      ),
    );
  }
}

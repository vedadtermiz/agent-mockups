import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_controller.dart';
import '../models/card_model.dart';
import '../models/level_def.dart';
import 'overlays/result_overlay.dart';
import 'theme.dart';
import 'widgets/card_fly_overlay.dart';
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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  Timer? _scoreTicker;
  final GlobalKey _wasteKey = GlobalKey();
  Map<String, GlobalKey> _slotKeys = {};

  AnimationController? _flyController;
  CardModel? _flyCard;
  Rect? _flyFrom;
  Rect? _flyTo;
  String? _flyingSlotId;
  bool _inputLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = context.read<GameController>();
      game.loadLevelByIndex(widget.levelIndex);
      _syncSlotKeys(game.level);
      _startScoreTicker();
    });
  }

  void _syncSlotKeys(LevelDef? level) {
    if (level == null) return;
    _slotKeys = {for (final s in level.slots) s.id: GlobalKey()};
  }

  void _startScoreTicker() {
    _scoreTicker?.cancel();
    _scoreTicker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      context.read<GameController>().tickDisplayScore(25);
    });
  }

  Future<void> _playWithFly(String slotId) async {
    if (_inputLocked) return;
    final game = context.read<GameController>();
    final card = game.board[slotId];
    if (card == null) {
      game.tryPlayCard(slotId);
      return;
    }
    if (!game.isPlayable(slotId) || !game.canStack(card)) {
      game.tryPlayCard(slotId);
      return;
    }

    // Wait one frame so layout keys are ready.
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    final from = globalBoundsForKey(_slotKeys[slotId]!);
    final to = globalBoundsForKey(_wasteKey);
    if (from == null || to == null) {
      game.tryPlayCard(slotId);
      return;
    }

    setState(() {
      _inputLocked = true;
      _flyingSlotId = slotId;
      _flyCard = card;
      _flyFrom = from;
      _flyTo = to;
    });

    _flyController?.dispose();
    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    await _flyController!.forward();
    if (!mounted) return;

    game.tryPlayCard(slotId);

    setState(() {
      _inputLocked = false;
      _flyingSlotId = null;
      _flyCard = null;
      _flyFrom = null;
      _flyTo = null;
    });
    _flyController?.dispose();
    _flyController = null;
  }

  @override
  void dispose() {
    _scoreTicker?.cancel();
    _flyController?.dispose();
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
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (_slotKeys.length != level.slots.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _syncSlotKeys(level));
            }
          });
        }

        return Container(
          decoration: GameTheme.screenDecoration,
          child: SafeArea(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    const ScoreHeader(),
                    const TimerBar(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: PeakLayout(
                        level: level,
                        slotKeys: _slotKeys,
                        hiddenSlotId: _flyingSlotId,
                        onSlotTap: _playWithFly,
                        inputEnabled: !_inputLocked,
                      ),
                    ),
                    StockWaste(
                      wasteKey: _wasteKey,
                      hideWaste: _flyingSlotId != null,
                      inputEnabled: !_inputLocked,
                    ),
                  ],
                ),
                if (_flyCard != null &&
                    _flyFrom != null &&
                    _flyTo != null &&
                    _flyController != null)
                  AnimatedBuilder(
                    animation: _flyController!,
                    builder: (context, _) => CardFlyOverlay(
                      card: _flyCard!,
                      from: _flyFrom!,
                      to: _flyTo!,
                      progress: _flyController!.value,
                    ),
                  ),
                if (game.status == GameStatus.paused) _PauseOverlay(game: game),
                if (game.status == GameStatus.won || game.status == GameStatus.lost)
                  ResultOverlay(
                    onHome: widget.onHome,
                    onRetry: () => game.restart(),
                    onNext: game.advanceToNextLevel,
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
            const Text(
              'Paused',
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game/game_controller.dart';
import 'ui/game_screen.dart';
import 'ui/level_select_screen.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TriPeaksApp());
}

class TriPeaksApp extends StatelessWidget {
  const TriPeaksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(),
      child: MaterialApp(
        title: 'TriPeaks Solitaire',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: GameTheme.tealMid),
          useMaterial3: true,
        ),
        home: const _RootNavigator(),
      ),
    );
  }
}

class _RootNavigator extends StatefulWidget {
  const _RootNavigator();

  @override
  State<_RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<_RootNavigator> {
  int? _playingLevelIndex;

  void _goHome() => setState(() => _playingLevelIndex = null);

  void _startLevel(int index) => setState(() => _playingLevelIndex = index);

  @override
  Widget build(BuildContext context) {
    if (_playingLevelIndex != null) {
      return GameScreen(
        levelIndex: _playingLevelIndex!,
        onHome: _goHome,
      );
    }
    return LevelSelectScreen(onPlay: _startLevel);
  }
}

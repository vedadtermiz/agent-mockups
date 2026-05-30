import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/levels.dart';
import '../models/card_model.dart';
import '../models/level_def.dart';
import 'scoring.dart';

enum GameStatus { playing, won, lost, paused }

/// Central game state and rules for TriPeaks Solitaire.
class GameController extends ChangeNotifier {
  GameController() {
    _loadPersistence();
  }

  static const _bestScoreKey = 'best_score';
  static const _unlockedLevelKey = 'unlocked_level';

  LevelDef? _level;
  final Map<String, CardModel?> _board = {};
  final Set<String> _faceUp = {};
  final Set<String> _cleared = {};

  CardModel? _waste;
  List<CardModel> _stock = [];

  int _score = 0;
  int _displayScore = 0;
  int _streak = 0;
  int _bestScore = 0;
  int _secondsLeft = 0;
  int _unlockedLevel = 0;
  int _levelIndex = 0;

  GameStatus _status = GameStatus.playing;
  Timer? _timer;

  /// Slot that should play shake animation after illegal tap.
  String? shakeSlotId;

  /// Streak multiplier flash near waste pile.
  bool showStreakFlash = false;

  /// Last played slot for fly-to-waste animation.
  String? lastPlayedSlotId;

  LevelDef? get level => _level;
  Map<String, CardModel?> get board => Map.unmodifiable(_board);
  Set<String> get faceUpSlots => Set.unmodifiable(_faceUp);
  CardModel? get waste => _waste;
  List<CardModel> get stock => List.unmodifiable(_stock);
  int get score => _score;
  int get displayScore => _displayScore;
  int get streak => _streak;
  int get bestScore => _bestScore;
  int get secondsLeft => _secondsLeft;
  int get unlockedLevel => _unlockedLevel;
  int get levelIndex => _levelIndex;
  GameStatus get status => _status;

  int get stockRemaining => _stock.length;

  Future<void> _loadPersistence() async {
    final prefs = await SharedPreferences.getInstance();
    _bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    _unlockedLevel = prefs.getInt(_unlockedLevelKey) ?? 0;
    notifyListeners();
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, _bestScore);
  }

  Future<void> _saveUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unlockedLevelKey, _unlockedLevel);
  }

  void loadLevelByIndex(int index) {
    _levelIndex = index.clamp(0, allLevels.length - 1);
    loadLevel(allLevels[_levelIndex]);
  }

  void loadLevel(LevelDef level) {
    _level = level;
    _board.clear();
    _faceUp.clear();
    _cleared.clear();
    _stock = [];
    _waste = null;
    _score = 0;
    _displayScore = 0;
    _streak = 0;
    _status = GameStatus.playing;
    shakeSlotId = null;
    showStreakFlash = false;
    lastPlayedSlotId = null;

    final deck = _buildShuffledDeck();
    var i = 0;
    for (final slot in level.slots) {
      _board[slot.id] = deck[i++];
      if (slot.startsFaceUp) {
        _faceUp.add(slot.id);
      }
    }
    _stock = deck.sublist(i, i + level.stockCount);
    if (_stock.isEmpty) {
      throw StateError('Level ${level.name} has invalid stockCount');
    }
    _waste = _stock.removeLast();

    _secondsLeft = level.timeLimitSeconds;
    _stopTimer();
    if (level.timeLimitSeconds > 0) {
      _startTimer();
    }
    notifyListeners();
  }

  List<CardModel> _buildShuffledDeck() {
    final deck = <CardModel>[];
    for (final suit in Suit.values) {
      for (var rank = 1; rank <= 13; rank++) {
        deck.add(CardModel(rank, suit));
      }
    }
    deck.shuffle(Random());
    return deck;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status != GameStatus.playing) return;
      if (_level == null || _level!.timeLimitSeconds == 0) return;
      _secondsLeft--;
      if (_secondsLeft <= 0) {
        _secondsLeft = 0;
        _status = GameStatus.lost;
        _stopTimer();
      }
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  bool isCleared(String slotId) => _cleared.contains(slotId) || _board[slotId] == null;

  bool isFaceUp(String slotId) => _faceUp.contains(slotId);

  bool isPlayable(String slotId) {
    if (_status != GameStatus.playing) return false;
    if (!_board.containsKey(slotId) || _board[slotId] == null) return false;
    if (!_faceUp.contains(slotId)) return false;
    final slot = _level!.slots.firstWhere((s) => s.id == slotId);
    for (final coverId in slot.coveredBy) {
      if (!isCleared(coverId)) return false;
    }
    return true;
  }

  bool canStack(CardModel card) {
    if (_waste == null) return false;
    return ranksCanStack(
      cardRank: card.rank,
      wasteRank: _waste!.rank,
      aceWraps: _level?.aceWraps ?? true,
    );
  }

  bool hasAnyLegalMove() {
    for (final entry in _board.entries) {
      if (entry.value == null) continue;
      if (!isPlayable(entry.key)) continue;
      if (canStack(entry.value!)) return true;
    }
    return false;
  }

  void tryPlayCard(String slotId) {
    if (_status != GameStatus.playing) return;
    final card = _board[slotId];
    if (card == null) return;

    if (!isPlayable(slotId)) {
      shakeSlotId = slotId;
      notifyListeners();
      _scheduleShakeClear();
      return;
    }

    if (!canStack(card)) {
      shakeSlotId = slotId;
      notifyListeners();
      _scheduleShakeClear();
      return;
    }

    shakeSlotId = null;
    lastPlayedSlotId = slotId;
    _board[slotId] = null;
    _cleared.add(slotId);
    _waste = card;
    _score += pointsForClear(_streak);
    _streak++;
    showStreakFlash = true;
    _scheduleStreakFlashClear();
    _animateDisplayScore();

    _revealUncoveredSlots();
    _checkWin();
    if (_status == GameStatus.playing) {
      _checkLoseAfterMove();
    }
    notifyListeners();
  }

  void clearStreakFlash() {
    showStreakFlash = false;
    notifyListeners();
  }

  void _scheduleShakeClear() {
    Future.delayed(const Duration(milliseconds: 450), () {
      if (shakeSlotId != null) {
        shakeSlotId = null;
        notifyListeners();
      }
    });
  }

  void _scheduleStreakFlashClear() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (showStreakFlash) {
        showStreakFlash = false;
        notifyListeners();
      }
    });
  }

  void clearShake() {
    shakeSlotId = null;
    notifyListeners();
  }

  void clearLastPlayed() {
    lastPlayedSlotId = null;
    notifyListeners();
  }

  void _revealUncoveredSlots() {
    for (final slot in _level!.slots) {
      if (_board[slot.id] == null) continue;
      if (_faceUp.contains(slot.id)) continue;
      var covered = false;
      for (final coverId in slot.coveredBy) {
        if (!isCleared(coverId)) {
          covered = true;
          break;
        }
      }
      if (!covered) {
        _faceUp.add(slot.id);
      }
    }
  }

  void drawFromStock() {
    if (_status != GameStatus.playing) return;
    if (_stock.isEmpty) {
      _checkLoseAfterMove();
      notifyListeners();
      return;
    }
    _streak = 0;
    _waste = _stock.removeLast();
    showStreakFlash = false;
    if (_stock.isEmpty && !hasAnyLegalMove()) {
      _status = GameStatus.lost;
      _stopTimer();
    }
    notifyListeners();
  }

  void _checkWin() {
    final allCleared = _level!.slots.every((s) => _board[s.id] == null);
    if (!allCleared) return;
    _status = GameStatus.won;
    _stopTimer();
    if (_level!.timeLimitSeconds > 0) {
      _score += timeBonus(_secondsLeft);
    }
    _animateDisplayScore();
    if (_score > _bestScore) {
      _bestScore = _score;
      _saveBestScore();
    }
    if (_levelIndex >= _unlockedLevel && _levelIndex < allLevels.length - 1) {
      _unlockedLevel = _levelIndex + 1;
      _saveUnlockedLevel();
    }
  }

  void _checkLoseAfterMove() {
    if (_status != GameStatus.playing) return;
    if (hasAnyLegalMove()) return;
    if (_stock.isNotEmpty) return;
    _status = GameStatus.lost;
    _stopTimer();
  }

  void restart() {
    if (_level != null) {
      loadLevel(_level!);
    }
  }

  void togglePause() {
    if (_status == GameStatus.playing) {
      _status = GameStatus.paused;
      _stopTimer();
    } else if (_status == GameStatus.paused) {
      _status = GameStatus.playing;
      if (_level != null && _level!.timeLimitSeconds > 0) {
        _startTimer();
      }
    }
    notifyListeners();
  }

  void advanceToNextLevel() {
    if (_levelIndex < allLevels.length - 1) {
      loadLevelByIndex(_levelIndex + 1);
    }
  }

  void _animateDisplayScore() {
    // Snap display score toward target in UI via listener ticks.
    _displayScore = _score;
  }

  /// Smooth score tick used by [ScoreHeader].
  void tickDisplayScore(int delta) {
    if (_displayScore < _score) {
      _displayScore = (_displayScore + delta).clamp(0, _score);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

import 'slot_def.dart';

/// Level configuration: slot layout, stock size, timer, and ace-wrap rule.
class LevelDef {
  final String name;
  final List<SlotDef> slots;
  /// Cards remaining in the stock pile (waste flip comes from stock).
  final int stockCount;
  final int timeLimitSeconds;
  final bool aceWraps;

  const LevelDef({
    required this.name,
    required this.slots,
    required this.stockCount,
    this.timeLimitSeconds = 120,
    this.aceWraps = true,
  });

  int get slotCount => slots.length;

  /// Deck must account for every slot plus the stock pile.
  bool get isDeckBalanced => slotCount + stockCount == 52;
}

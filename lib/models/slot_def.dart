/// One board position where a peak card may sit.
class SlotDef {
  final String id;
  /// Logical X in grid units; scaled at render time.
  final double x;
  /// Logical Y; smaller values sit higher on screen.
  final double y;
  /// Slot ids that overlap / cover this card from the front.
  final List<String> coveredBy;
  /// Bottom-row cards are usually dealt face-up.
  final bool startsFaceUp;

  const SlotDef({
    required this.id,
    required this.x,
    required this.y,
    this.coveredBy = const [],
    this.startsFaceUp = false,
  });
}

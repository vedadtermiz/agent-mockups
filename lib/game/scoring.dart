/// Points for clearing one peak card; grows with streak.
int pointsForClear(int streakBeforeClear) => 100 + streakBeforeClear * 50;

/// Bonus added on win from remaining seconds.
int timeBonus(int secondsLeft) => secondsLeft * 25;

/// Whether [cardRank] can stack on [wasteRank] (±1, optional ace wrap).
bool ranksCanStack({
  required int cardRank,
  required int wasteRank,
  required bool aceWraps,
}) {
  final diff = (cardRank - wasteRank).abs();
  if (diff == 1) return true;
  if (!aceWraps) return false;
  // Ace (1) wraps to King (13) and Two (2).
  if (cardRank == 1 && (wasteRank == 13 || wasteRank == 2)) return true;
  if (wasteRank == 1 && (cardRank == 13 || cardRank == 2)) return true;
  return false;
}

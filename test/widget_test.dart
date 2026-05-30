import 'package:flutter_test/flutter_test.dart';
import 'package:tripeaks_solitaire/game/scoring.dart';
import 'package:tripeaks_solitaire/models/card_model.dart';

void main() {
  test('ace wraps to king and two', () {
    expect(
      ranksCanStack(cardRank: 1, wasteRank: 13, aceWraps: true),
      isTrue,
    );
    expect(
      ranksCanStack(cardRank: 2, wasteRank: 1, aceWraps: true),
      isTrue,
    );
    expect(
      ranksCanStack(cardRank: 5, wasteRank: 7, aceWraps: true),
      isFalse,
    );
  });

  test('streak scoring grows', () {
    expect(pointsForClear(0), 100);
    expect(pointsForClear(3), 250);
  });

  test('card model rank labels', () {
    const ace = CardModel(1, Suit.hearts);
    expect(ace.rankLabel, 'A');
    expect(ace.isRed, isTrue);
  });
}

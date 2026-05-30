/// Playing card rank and suit for TriPeaks Solitaire.
enum Suit { spades, hearts, diamonds, clubs }

/// One card in the deck; rank 1 = Ace through 13 = King.
class CardModel {
  final int rank;
  final Suit suit;

  const CardModel(this.rank, this.suit);

  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;

  String get rankLabel {
    switch (rank) {
      case 1:
        return 'A';
      case 11:
        return 'J';
      case 12:
        return 'Q';
      case 13:
        return 'K';
      default:
        return '$rank';
    }
  }

  String get suitSymbol {
    switch (suit) {
      case Suit.spades:
        return '♠';
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel && rank == other.rank && suit == other.suit;

  @override
  int get hashCode => Object.hash(rank, suit);
}

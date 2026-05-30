import 'package:flutter/material.dart';

import '../../models/card_model.dart';
import '../theme.dart';

/// Rounded playing card — face-up with rank pips or teal patterned back.
class PlayingCard extends StatelessWidget {
  const PlayingCard({
    super.key,
    this.card,
    this.faceUp = true,
    this.width = 56,
    this.height = 80,
    this.onTap,
    this.shake = false,
    this.dimmed = false,
  });

  final CardModel? card;
  final bool faceUp;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool shake;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    Widget child = faceUp && card != null ? _FaceUp(card!) : const _CardBack();

    if (dimmed) {
      child = ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: 0.35),
          BlendMode.darken,
        ),
        child: child,
      );
    }

    child = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
    );

    if (shake) {
      child = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        builder: (context, t, c) {
          final offset = (t < 0.25)
              ? -4.0 * (t / 0.25)
              : (t < 0.5)
                  ? 4.0 * ((t - 0.25) / 0.25) - 4
                  : (t < 0.75)
                      ? -4.0 * ((t - 0.5) / 0.25) + 4
                      : 4.0 * ((t - 0.75) / 0.25) - 4;
          return Transform.translate(offset: Offset(offset, 0), child: c);
        },
        child: child,
      );
    }

    if (onTap != null) {
      child = GestureDetector(onTap: onTap, child: child);
    }

    return child;
  }
}

class _FaceUp extends StatelessWidget {
  const _FaceUp(this.card);
  final CardModel card;

  @override
  Widget build(BuildContext context) {
    final color = card.isRed ? Colors.red.shade700 : Colors.black87;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          Positioned(
            top: 2,
            left: 4,
            child: _Corner(rank: card.rankLabel, suit: card.suitSymbol, color: color),
          ),
          Positioned(
            bottom: 2,
            right: 4,
            child: Transform.rotate(
              angle: 3.14159,
              child: _Corner(rank: card.rankLabel, suit: card.suitSymbol, color: color),
            ),
          ),
          Center(child: _PipCluster(suit: card.suit, color: color)),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.rank, required this.suit, required this.color});
  final String rank;
  final String suit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rank, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        Text(suit, style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }
}

class _PipCluster extends StatelessWidget {
  const _PipCluster({required this.suit, required this.color});
  final Suit suit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      _suitLarge(suit),
      style: TextStyle(fontSize: 28, color: color),
    );
  }

  String _suitLarge(Suit s) {
    switch (s) {
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
}

class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DiamondPatternPainter(),
      child: Container(color: GameTheme.cardBack),
    );
  }
}

class _DiamondPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 12.0;
    for (var x = -step; x < size.width + step; x += step) {
      for (var y = -step; y < size.height + step; y += step) {
        final path = Path()
          ..moveTo(x, y + step / 2)
          ..lineTo(x + step / 2, y)
          ..lineTo(x + step, y + step / 2)
          ..lineTo(x + step / 2, y + step)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

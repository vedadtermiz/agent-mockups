import 'package:flutter/material.dart';

import '../../models/card_model.dart';
import '../theme.dart';

/// Rounded playing card matching reference: white face, teal lattice back.
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
    this.isStockPile = false,
    this.showGhostSlot = false,
  });

  final CardModel? card;
  final bool faceUp;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool shake;
  final bool dimmed;
  /// Stock pile top card — gold circle + flag on back.
  final bool isStockPile;
  /// Face-down slot that blends into the board (no pattern).
  final bool showGhostSlot;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (!faceUp || card == null) {
      child = showGhostSlot
          ? const _GhostSlot()
          : _CardBack(isStockPile: isStockPile);
    } else {
      child = _FaceUp(card: card!, width: width, height: height);
    }

    if (dimmed) {
      child = ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: 0.28),
          BlendMode.darken,
        ),
        child: child,
      );
    }

    final radius = BorderRadius.circular(width * 0.16);

    child = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: showGhostSlot ? null : GameTheme.cardShadow,
      ),
      child: ClipRRect(borderRadius: radius, child: child),
    );

    if (shake) {
      child = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        builder: (context, t, c) {
          final offset = (t < 0.25)
              ? -5.0 * (t / 0.25)
              : (t < 0.5)
                  ? 5.0 * ((t - 0.25) / 0.25) - 5
                  : (t < 0.75)
                      ? -5.0 * ((t - 0.5) / 0.25) + 5
                      : 5.0 * ((t - 0.75) / 0.25) - 5;
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

/// Empty face-down placeholder merged with the board color.
class _GhostSlot extends StatelessWidget {
  const _GhostSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GameTheme.ghostSlot,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
    );
  }
}

class _FaceUp extends StatelessWidget {
  const _FaceUp({required this.card, required this.width, required this.height});
  final CardModel card;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = card.isRed ? const Color(0xFFD32F2F) : const Color(0xFF263238);
    final cornerSize = width * 0.22;

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: height * 0.06,
            left: width * 0.08,
            child: _CornerBadge(
              rank: card.rankLabel,
              suit: card.suitSymbol,
              color: color,
              size: cornerSize,
            ),
          ),
          Positioned(
            bottom: height * 0.06,
            right: width * 0.08,
            child: Transform.rotate(
              angle: 3.14159,
              child: _CornerBadge(
                rank: card.rankLabel,
                suit: card.suitSymbol,
                color: color,
                size: cornerSize,
              ),
            ),
          ),
          Center(child: _CenterArt(card: card, color: color, size: width * 0.55)),
        ],
      ),
    );
  }
}

class _CornerBadge extends StatelessWidget {
  const _CornerBadge({
    required this.rank,
    required this.suit,
    required this.color,
    required this.size,
  });

  final String rank;
  final String suit;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rank,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w800,
            height: 1,
            color: color,
          ),
        ),
        Text(
          suit,
          style: TextStyle(fontSize: size * 0.85, height: 1, color: color),
        ),
      ],
    );
  }
}

class _CenterArt extends StatelessWidget {
  const _CenterArt({required this.card, required this.color, required this.size});
  final CardModel card;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (card.rank >= 11 || card.rank == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            card.rankLabel,
            style: TextStyle(
              fontSize: size * 0.95,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          Text(
            card.suitSymbol,
            style: TextStyle(fontSize: size * 0.9, color: color, height: 1),
          ),
        ],
      );
    }
    return _PipLayout(rank: card.rank, suit: card.suitSymbol, color: color, size: size);
  }
}

/// Classic pip arrangement for 2–10.
class _PipLayout extends StatelessWidget {
  const _PipLayout({
    required this.rank,
    required this.suit,
    required this.color,
    required this.size,
  });

  final int rank;
  final String suit;
  final Color color;
  final double size;

  static const _layouts = <int, List<Offset>>{
    2: [Offset(0.5, 0.2), Offset(0.5, 0.8)],
    3: [Offset(0.5, 0.15), Offset(0.5, 0.5), Offset(0.5, 0.85)],
    4: [
      Offset(0.28, 0.22),
      Offset(0.72, 0.22),
      Offset(0.28, 0.78),
      Offset(0.72, 0.78),
    ],
    5: [
      Offset(0.28, 0.18),
      Offset(0.72, 0.18),
      Offset(0.5, 0.5),
      Offset(0.28, 0.82),
      Offset(0.72, 0.82),
    ],
    6: [
      Offset(0.28, 0.18),
      Offset(0.72, 0.18),
      Offset(0.28, 0.5),
      Offset(0.72, 0.5),
      Offset(0.28, 0.82),
      Offset(0.72, 0.82),
    ],
    7: [
      Offset(0.28, 0.15),
      Offset(0.72, 0.15),
      Offset(0.5, 0.32),
      Offset(0.28, 0.5),
      Offset(0.72, 0.5),
      Offset(0.28, 0.85),
      Offset(0.72, 0.85),
    ],
    8: [
      Offset(0.28, 0.14),
      Offset(0.72, 0.14),
      Offset(0.28, 0.36),
      Offset(0.72, 0.36),
      Offset(0.28, 0.64),
      Offset(0.72, 0.64),
      Offset(0.28, 0.86),
      Offset(0.72, 0.86),
    ],
    9: [
      Offset(0.28, 0.12),
      Offset(0.72, 0.12),
      Offset(0.28, 0.35),
      Offset(0.5, 0.5),
      Offset(0.72, 0.35),
      Offset(0.28, 0.65),
      Offset(0.72, 0.65),
      Offset(0.28, 0.88),
      Offset(0.72, 0.88),
    ],
    10: [
      Offset(0.28, 0.1),
      Offset(0.72, 0.1),
      Offset(0.5, 0.22),
      Offset(0.28, 0.38),
      Offset(0.72, 0.38),
      Offset(0.28, 0.62),
      Offset(0.72, 0.62),
      Offset(0.5, 0.78),
      Offset(0.28, 0.9),
      Offset(0.72, 0.9),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final points = _layouts[rank] ?? [const Offset(0.5, 0.5)];
    return SizedBox(
      width: size,
      height: size * 1.25,
      child: Stack(
        children: [
          for (final p in points)
            Positioned(
              left: p.dx * size - size * 0.18,
              top: p.dy * size * 1.25 - size * 0.18,
              child: Text(
                suit,
                style: TextStyle(fontSize: size * 0.36, color: color, height: 1),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({this.isStockPile = false});
  final bool isStockPile;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LatticePainter(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [GameTheme.cardBack, GameTheme.cardBackDark],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
        ),
        child: isStockPile
            ? Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: GameTheme.accentGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flag, color: Color(0xFF1A5C5C), size: 20),
                ),
              )
            : null,
      ),
    );
  }
}

class _LatticePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const step = 11.0;
    for (var x = -step; x < size.width + step; x += step) {
      for (var y = -step; y < size.height + step; y += step) {
        final cx = x + step / 2;
        final cy = y + step / 2;
        final path = Path()
          ..moveTo(cx, y)
          ..lineTo(x + step, cy)
          ..lineTo(cx, y + step)
          ..lineTo(x, cy)
          ..close();
        canvas.drawPath(path, stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

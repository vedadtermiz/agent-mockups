import '../models/level_def.dart';
import '../models/slot_def.dart';

/// Builds a triangular peak: row 0 has 1 slot, each row adds one more.
/// Wires [coveredBy] so each card is blocked by the two below-front of it.
List<SlotDef> buildPyramid({
  required String prefix,
  required int rows,
  required double originX,
  required double originY,
  double colSpacing = 2.0,
  double rowSpacing = 1.4,
}) {
  final slots = <SlotDef>[];
  final ids = <List<String>>[];

  for (var r = 0; r < rows; r++) {
    ids.add(List.generate(r + 1, (c) => '$prefix-$r-$c'));
  }

  for (var r = 0; r < rows; r++) {
    final rowWidth = r + 1;
    final xOffset = (rows - rowWidth) * colSpacing / 2;
    for (var c = 0; c < rowWidth; c++) {
      final coveredBy = <String>[];
      if (r < rows - 1) {
        coveredBy.add(ids[r + 1][c]);
        coveredBy.add(ids[r + 1][c + 1]);
      }
      slots.add(
        SlotDef(
          id: ids[r][c],
          x: originX + xOffset + c * colSpacing,
          y: originY + r * rowSpacing,
          coveredBy: coveredBy,
          startsFaceUp: r == rows - 1,
        ),
      );
    }
  }
  return slots;
}

/// Diamond-shaped layout (17 slots).
List<SlotDef> _buildDiamondSlots() {
  const rows = [
    ['d-0-0'],
    ['d-1-0', 'd-1-1'],
    ['d-2-0', 'd-2-1', 'd-2-2'],
    ['d-3-0', 'd-3-1', 'd-3-2', 'd-3-3'],
    ['d-4-0', 'd-4-1', 'd-4-2'],
    ['d-5-0', 'd-5-1'],
    ['d-6-0'],
  ];
  final positions = <String, (double, double)>{
    'd-0-0': (6, 0),
    'd-1-0': (5, 1.4), 'd-1-1': (7, 1.4),
    'd-2-0': (4, 2.8), 'd-2-1': (6, 2.8), 'd-2-2': (8, 2.8),
    'd-3-0': (3, 4.2), 'd-3-1': (5, 4.2), 'd-3-2': (7, 4.2), 'd-3-3': (9, 4.2),
    'd-4-0': (4, 5.6), 'd-4-1': (6, 5.6), 'd-4-2': (8, 5.6),
    'd-5-0': (5, 7), 'd-5-1': (7, 7),
    'd-6-0': (6, 8.4),
  };
  final coverMap = <String, List<String>>{
    'd-0-0': ['d-1-0', 'd-1-1'],
    'd-1-0': ['d-2-0', 'd-2-1'],
    'd-1-1': ['d-2-1', 'd-2-2'],
    'd-2-0': ['d-3-0', 'd-3-1'],
    'd-2-1': ['d-3-1', 'd-3-2'],
    'd-2-2': ['d-3-2', 'd-3-3'],
    'd-3-0': ['d-4-0', 'd-4-1'],
    'd-3-1': ['d-4-0', 'd-4-1'],
    'd-3-2': ['d-4-1', 'd-4-2'],
    'd-3-3': ['d-4-1', 'd-4-2'],
    'd-4-0': ['d-5-0', 'd-5-1'],
    'd-4-1': ['d-5-0', 'd-5-1'],
    'd-4-2': ['d-5-0', 'd-5-1'],
    'd-5-0': ['d-6-0'],
    'd-5-1': ['d-6-0'],
    'd-6-0': [],
  };
  final bottom = {'d-3-0', 'd-3-1', 'd-3-2', 'd-3-3', 'd-4-0', 'd-4-1', 'd-4-2'};
  return [
    for (final row in rows)
      for (final id in row)
        SlotDef(
          id: id,
          x: positions[id]!.$1,
          y: positions[id]!.$2,
          coveredBy: coverMap[id] ?? [],
          startsFaceUp: bottom.contains(id),
        ),
  ];
}

/// Heart-shaped layout (18 slots).
List<SlotDef> _buildHeartSlots() {
  final defs = <({String id, double x, double y, List<String> cover, bool face})>[
    (id: 'h-0', x: 6, y: 0, cover: ['h-1', 'h-2'], face: false),
    (id: 'h-1', x: 4.5, y: 1.3, cover: ['h-3', 'h-4'], face: false),
    (id: 'h-2', x: 7.5, y: 1.3, cover: ['h-4', 'h-5'], face: false),
    (id: 'h-3', x: 3, y: 2.6, cover: ['h-6'], face: false),
    (id: 'h-4', x: 6, y: 2.6, cover: ['h-6', 'h-7'], face: false),
    (id: 'h-5', x: 9, y: 2.6, cover: ['h-7'], face: false),
    (id: 'h-6', x: 4, y: 4, cover: ['h-8', 'h-9'], face: true),
    (id: 'h-7', x: 8, y: 4, cover: ['h-9', 'h-10'], face: true),
    (id: 'h-8', x: 2.5, y: 5.4, cover: ['h-11'], face: true),
    (id: 'h-9', x: 6, y: 5.4, cover: ['h-11', 'h-12'], face: true),
    (id: 'h-10', x: 9.5, y: 5.4, cover: ['h-12'], face: true),
    (id: 'h-11', x: 4, y: 6.8, cover: ['h-13'], face: true),
    (id: 'h-12', x: 8, y: 6.8, cover: ['h-13'], face: true),
    (id: 'h-13', x: 6, y: 8.2, cover: [], face: true),
  ];
  return defs
      .map(
        (d) => SlotDef(
          id: d.id,
          x: d.x,
          y: d.y,
          coveredBy: d.cover,
          startsFaceUp: d.face,
        ),
      )
      .toList();
}

/// Wide flat peak (24 slots, 5 rows).
List<SlotDef> _buildWideSlots() {
  return buildPyramid(
    prefix: 'w',
    rows: 5,
    originX: 0,
    originY: 0,
    colSpacing: 1.6,
    rowSpacing: 1.2,
  );
}

/// Three small peaks side by side (classic TriPeaks feel).
final LevelDef classicThreePeaks = LevelDef(
  name: 'Three Peaks',
  slots: [
    ...buildPyramid(prefix: 'l', rows: 4, originX: 0, originY: 0),
    ...buildPyramid(prefix: 'm', rows: 4, originX: 5.5, originY: 0),
    ...buildPyramid(prefix: 'r', rows: 4, originX: 11, originY: 0),
  ],
  stockCount: 22,
  timeLimitSeconds: 150,
);

final LevelDef twinPeaks = LevelDef(
  name: 'Twin Peaks',
  slots: [
    ...buildPyramid(prefix: 'top', rows: 4, originX: 0, originY: 0),
    ...buildPyramid(prefix: 'bot', rows: 4, originX: 0, originY: 6),
  ],
  stockCount: 32,
  timeLimitSeconds: 120,
);

final LevelDef singlePyramid = LevelDef(
  name: 'Great Pyramid',
  slots: buildPyramid(prefix: 'p', rows: 7, originX: 0, originY: 0),
  stockCount: 24,
  timeLimitSeconds: 180,
);

final LevelDef diamondLevel = LevelDef(
  name: 'Diamond',
  slots: _buildDiamondSlots(),
  stockCount: 35,
  timeLimitSeconds: 140,
);

final LevelDef heartLevel = LevelDef(
  name: 'Heart',
  slots: _buildHeartSlots(),
  stockCount: 39,
  timeLimitSeconds: 130,
);

final LevelDef wideLevel = LevelDef(
  name: 'Wide Mesa',
  slots: _buildWideSlots(),
  stockCount: 37,
  timeLimitSeconds: 160,
);

/// All playable levels in unlock order.
final List<LevelDef> allLevels = [
  twinPeaks,
  classicThreePeaks,
  singlePyramid,
  diamondLevel,
  heartLevel,
  wideLevel,
];

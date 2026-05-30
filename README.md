# TriPeaks Solitaire (Flutter)

Data-driven TriPeaks-style solitaire: level shapes are defined as `SlotDef` layouts with `coveredBy` wiring, not hard-coded geometry.

## Run

```bash
flutter pub get
flutter run
```

## Structure

- `lib/models/` — `CardModel`, `SlotDef`, `LevelDef`
- `lib/data/levels.dart` — `buildPyramid` helper and six starter levels
- `lib/game/` — `GameController`, scoring rules
- `lib/ui/` — screens and widgets

## Levels

1. Three Peaks — three side-by-side pyramids  
2. Twin Peaks — reference double-pyramid layout  
3. Great Pyramid — single tall peak  
4. Diamond  
5. Heart  
6. Wide Mesa  

Clear a level to unlock the next. Best score and progress persist via `shared_preferences`.

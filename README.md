# TriPeaks Solitaire (Flutter)

Data-driven TriPeaks-style solitaire: level shapes are defined as `SlotDef` layouts with `coveredBy` wiring, not hard-coded geometry.

## Install on Android (APK)

Download the release APK and open it on your phone (enable “Install unknown apps” if prompted):

**[Download tripeaks-solitaire.apk](apk/tripeaks-solitaire.apk)**

On GitHub mobile: open the file above → ⋮ menu → **Download**.

## Run from source

```bash
flutter pub get
flutter run
```

Build APK locally:

```bash
flutter build apk --release
```

## Structure

- `lib/models/` — `CardModel`, `SlotDef`, `LevelDef`
- `lib/data/levels.dart` — `buildPyramid` helper and six starter levels
- `lib/game/` — `GameController`, scoring rules
- `lib/ui/` — screens, card fly animation, widgets

## Levels

1. Three Peaks — three side-by-side pyramids  
2. Twin Peaks — reference double-pyramid layout  
3. Great Pyramid — single tall peak  
4. Diamond  
5. Heart  
6. Wide Mesa  

Clear a level to unlock the next. Best score and progress persist via `shared_preferences`.

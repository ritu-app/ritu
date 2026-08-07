# Cycle Studio

A Flutter web app for interactively exploring Ritu screen states driven by fake
cycle data. It complements [Widgetbook](../widgetbook/README.md): Widgetbook
catalogs frozen component snapshots; Cycle Studio is a live data playground for
the cycle engine, hero card, and insights gating.

See [docs/cycle-studio-spec.md](../docs/cycle-studio-spec.md) for the full
product and technical spec.

## Run locally

```bash
cd studio
flutter pub get
flutter run -d chrome
```

## What it uses from the main package

- `lib/core/cycle/` — classification, phase ranges, `CycleSnapshot`
- `lib/data/repositories/memory/` — mutable in-memory repos
- `lib/providers/` — same Riverpod graph as production, with
  `simulatedTodayProvider` overridden

## Current features

- Split-pane shell with control panel, iPhone 13 preview frame, and debug readout
- Full app preview (`HomeScreen` with in-app navigation)
- Simulated today date picker
- All spec presets (partial, threshold, regular, variable, unpredictable, tier B/C, phase matrix)
- Cycle-length history editor with add / remove / reorder and Apply
- Daily log controls (logged days count + logged today toggle)

## Image assets

Ritu screens reference `assets/images/…` in the **host app's** asset bundle. Cycle
Studio depends on `ritu` as a package, so those PNGs are symlinked from
`../assets/images/` into `studio/assets/images/` and declared in `pubspec.yaml`.
After cloning on a new machine, confirm the symlinks under `studio/assets/images/`
resolve (re-run `flutter pub get` if images fail to load).

# Cycle Studio — Product & Technical Spec

A separate Flutter web app for interactively exploring Ritu screen states driven
by fake cycle data. It complements Widgetbook: Widgetbook catalogs frozen
component/screen snapshots; Cycle Studio is a live data playground for the
cycle engine, hero card, and insights gating.

**Not in scope:** replacing Widgetbook, running on device, or touching real
SQLite data.

---

## 1. Goals

1. Preview any screen that consumes cycle state (hero card, insights, journal
  context line, etc.) without rebuilding the app or adding static use-cases.
2. Compose arbitrary period histories and see classification, phase ranges, and
  UI update in real time.
3. Validate partial vs full insights (< 3 vs ≥ 3 completed cycles) visually.
4. Exercise the full phase × classification × tier matrix during design and QA.
5. Share a deployable URL for design review (optional, same pattern as
  Widgetbook → Vercel).

---



## 2. Non-goals

- Component-level catalog (chips, buttons) — stay in Widgetbook.
- Automated visual regression / screenshot diffing.
- Editing Drift schema or production providers.
- Native (iOS/Android) targets — web only is sufficient for v1.

---



## 3. Repository layout

Independent Flutter project, sibling to `widgetbook/`:

```
studio/
  pubspec.yaml          path: .. dependency on ritu
  assets/images/        symlinks to ../assets/images/ (host-bundle PNGs)
  lib/
    main.dart                 split-pane shell
    models/
      cycle_history_draft.dart
    scope/
      studio_scope.dart       mutable MemoryRituStore + ProviderScope
      ritu_repos.dart           RituRepos + onboarding seed helper
    panels/
      control_panel.dart        inputs + presets
      preview_panel.dart        iPhone 13 frame + HomeScreen
      debug_panel.dart          CycleSnapshot readout
      cycle_history_editor.dart period history + daily log controls UI
    presets/
      cycle_presets.dart        one-click fixture loaders
      daily_log_controls.dart   seed logged-day count / logged today
  README.md
  test/widget_test.dart         StudioScope smoke test
```

Main package additions used by Studio (do not duplicate in `studio/`):

- `lib/providers/simulated_today_provider.dart` — overridable “today”
- `lib/providers/cycle_snapshot_provider.dart` — reactive debug readout

Shared code lives in the main package (do not duplicate):

- `lib/core/cycle/` — all calculation logic
- `lib/data/repositories/memory/` — in-memory repo fakes
- `lib/providers/` — same Riverpod providers as the app
- `lib/features/` — real screens

---



## 4. UI layout

Split-pane web app (responsive: stack vertically below ~900px width).

```
┌──────────────────────────────┬─────────────────────────────┐
│  Controls                    │  Preview                    │
│                              │  ┌─────────────────────┐    │
│  Simulated today [date]      │  │  iPhone 13 frame    │    │
│                              │  │                     │    │
│  ── Period history ──        │  │  HomeScreen (full   │    │
│  [preset buttons]            │  │  app navigation)    │    │
│  Cycle list editor           │  └─────────────────────┘    │
│  Period duration P           │                             │
│  [+ Add cycle]               │  ── Debug readout ──        │
│  [Apply history]             │  Classification: Regular    │
│                              │  MAD: 0.6                   │
│  ── Daily logs ──            │  Cycle day: 14              │
│  Logged days count           │  Phase: Follicular          │
│  Logged today [toggle]       │  Tier: A                    │
│                              │  Effective C: 28            │
└──────────────────────────────┴─────────────────────────────┘
```



### 4.1 Preview (v1)

Preview mounts full `HomeScreen` inside the device frame. Users navigate to
Insights, Journal, Settings → Period history, etc. via the real app UI — no
screen dropdown in the control panel.

Screens of interest:

| Screen                    | Notes                        |
| ------------------------- | ---------------------------- |
| Home (status card)        | Hero / phase card when built |
| Insights                  | Partial vs full gating       |
| Journal                   | Context line with cycle day  |
| Settings → Period history | Period list                  |

### 4.2 Simulated today

Date picker defaulting to real today. All cycle math and "logged today" checks
must read this value, not `DateTime.now()` directly.

Implementation: `simulatedTodayProvider` in `lib/providers/simulated_today_provider.dart`,
overridden in `StudioScope`. Wired into period, daily-log, and journal-entry
providers; `cycleSnapshotProvider` reads it for the debug panel.

### 4.3 Period history builder

Authoring model: **cycle lengths**, not raw calendar math in the UI.

Each row:

- Cycle length (days from previous period start to this one) — editable
- Period duration P for that episode — editable
- Computed start date (derived backward from simulated today + latest period)

Alternatively: latest period start date + list of prior cycle lengths.

Actions:

- Add/remove cycle rows
- Reorder (oldest → newest)
- "Apply" writes to `MemoryPeriodRepository` via repo methods

Minimum viable: **preset buttons** + simple "number of completed cycles" slider
before full editor.

### 4.4 Presets (required for v1)

One-click loads that call shared seed helpers:


| Preset               | Completed cycles | Classification   | Notes                                  |
| -------------------- | ---------------- | ---------------- | -------------------------------------- |
| Partial — 1 cycle    | 1                | Unclassified     | Partial insights                       |
| Partial — 2 cycles   | 2                | Unclassified     | Partial insights                       |
| Threshold — 3 cycles | 3                | (computed)       | First classifiable                     |
| Regular              | 6                | Regular          | Spec example: 28,27,29,28,27,28        |
| Variable             | 6                | Variable         | Spec example: 21,35,23,33,25,31        |
| Unpredictable        | 6                | Unpredictable    | Spec example: 21,46,24,43,22,40        |
| Tier B short cycle   | 1 (current)      | Regular/Variable | P=5, C=21                              |
| Tier C irregular     | 1 (current)      | any              | P=5, C=14 or C≤P                       |
| Phase day matrix     | 6                | Regular          | C=28 P=5, simulated today = each phase |


Presets live in `studio/lib/presets/` but call `lib/core/cycle/` for debug
readout values.

---



## 5. Architecture



### 5.1 Data flow

```
Control panel
    → mutates MemoryRituStore (via repo methods)
    → Drift-equivalent streams emit
    → Riverpod providers rebuild
    → Preview screen re-renders
    → Debug panel reads CycleSnapshot from core/cycle
```

Studio must use the **same provider graph** as production. No parallel mock
state in the UI layer.

### 5.2 StudioScope vs Widgetbook SeededAppScope

Widgetbook's `SeededAppScope` seeds once at init. Studio needs **mutable**
state:

```dart
class StudioScope extends StatefulWidget {
  // Holds MemoryRituStore for app lifetime
  // Exposes RituRepos to control panel
  // ProviderScope overrides for all repository providers
  // + simulatedTodayProvider override
}
```

Control panel receives `RituRepos repos` and calls `upsertPeriod`, etc.
Memory repos already notify stream listeners on mutation.

### 5.3 Insights gating

From product rule + classification spec:


| Completed cycles | Insights mode | Phase display                  |
| ---------------- | ------------- | ------------------------------ |
| 0–2              | Partial       | No classification-based phases |
| ≥ 3              | Full          | Classification + phases apply  |


Expose via `CycleSnapshot.insightsMode` (or equivalent) from
`lib/core/cycle/`. Studio debug panel shows this prominently.

**Note:** Daily-log-based unlock (14-day pattern teaser on Insights) is
orthogonal — studio controls both axes independently.

### 4.5 Journal editor (not yet implemented)

Control-panel controls to seed journal state for the Journal tab:

- Today’s entry body (empty vs saved)
- Optional past entries (count / sample text) for the list below the hero

Writes via `MemoryJournalEntryRepository` so the context line and entry list
update reactively. Navigate to Journal in the preview to verify.

---



## 6. Dependencies

```yaml
# studio/pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  ritu:
    path: ..
  device_frame: ^1.2.0   # optional, match widgetbook
  google_fonts: ^6.2.1     # if control panel uses DM Sans
```

Do **not** add Widgetbook as a dependency.

---



## 7. Running & deploying

```bash
cd studio
flutter pub get
flutter run -d chrome
```

Deploy (optional v2): mirror `.github/workflows/widgetbook-vercel.yml` with
`studio/build/web` and a subdomain such as `studio.ritu.care`.

---



## 8. Testing strategy


| Layer              | Tool                                                                  |
| ------------------ | --------------------------------------------------------------------- |
| Cycle math         | `flutter test` on `test/cycle/` in root package (already spec-backed) |
| Studio wiring      | Manual QA via presets                                                 |
| Screen regressions | Widgetbook frozen use-cases (not studio)                              |


Studio does not need its own test suite in v1 beyond a smoke test that
`StudioScope` mounts — **done** (`studio/test/widget_test.dart`).

---



## 9. Implementation phases



### Phase 1 — Shell (MVP)

- [x] `studio/` project scaffold
- [x] `StudioScope` with mutable memory repos
- [x] `simulatedTodayProvider` (+ `cycleSnapshotProvider`) in main package
- [x] Split layout: control panel + iPhone frame (stacks below ~900px)
- [x] Full `HomeScreen` preview (in-app navigation; no screen dropdown)
- [x] Debug readout (`cycleSnapshotProvider` / `CycleSnapshot`)
- [x] Presets: Partial (2 cycles), Regular, Unpredictable *(expanded in Phase 2)*
- [x] Smoke test (`studio/test/widget_test.dart`)
- [x] Image assets bundled via `studio/assets/images/` symlinks

### Phase 2 — History editor

- [x] Cycle-length list editor (add / remove / reorder, per-row P, Apply)
- [x] All classification presets + Tier B/C + phase-day matrix preset
- [x] Daily log controls (logged days count slider, logged today toggle)
- [x] Navigate to Journal, Insights, Settings → Period history via app UI
- [ ] **Journal editor** — seed/edit journal entries (today + past) for context-line and list states

### Phase 3 — Polish

- [ ] URL query params for shareable state (`?preset=regular&day=14`)
- [x] Deploy to Vercel — `.github/workflows/studio-vercel.yml` → `studio.ritu.care` *(needs `VERCEL_STUDIO_PROJECT_ID` secret + DNS)*
- [ ] Phase-day scrubber (slider 1…C)
- [ ] Optional: load real `ritu.sqlite` in browser (Drift WASM import)

---



## 10. References

- [cycle-classification-spec.html](./cycle-classification-spec.html)
- [cycle-phase-range-spec.html](./cycle-phase-range-spec.html)
- [DATA.md](./DATA.md) — persistence model
- `widgetbook/lib/support/seeded_app_scope.dart` — pattern reference (do not
merge into widgetbook)
- `lib/core/cycle/` — pure calculation module


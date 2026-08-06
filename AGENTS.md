# Ritu — context for coding agents

Ritu is a Flutter mobile app: "a private journal for your cycle" (menstrual
cycle / period tracker). All user data is stored **on-device only** — there
is no backend, no network sync, no auth. Package name: `ritu`, bundle ID
`care.ritu.ritu`.

Two independent Flutter projects live in this repo:

- **`/`** (root) — the actual app.
- **`widgetbook/`** — a separate Flutter app (own `pubspec.yaml`) that depends
  on the root package via a `path: ..` dependency. It's a component/screen
  gallery (Storybook equivalent), deployed to
  [components.ritu.care](https://components.ritu.care/) via GitHub Actions →
  Vercel on push to `main` (workflow:
  `.github/workflows/widgetbook-vercel.yml`). See `widgetbook/README.md`
  before touching it.

Read `README.md` (run/build/codegen commands) and `docs/DATA.md` (full data
model + schema + provider table) before making non-trivial changes — both are
kept up to date and are more authoritative than this file for those topics.

## Stack

- Flutter, Dart SDK `^3.11.1`.
- State management: **Riverpod** (`flutter_riverpod: ^2.6.1`), hand-written
  `Provider` / `StreamProvider` declarations in `lib/providers/` — **not**
  `@riverpod` codegen. That's deferred because `riverpod_generator` currently
  conflicts with `drift_dev` on the shared `build_runner`/`analyzer` version.
  Don't introduce `@riverpod` annotations without resolving that first.
- Persistence: **Drift** (SQLite ORM) — `drift: ^2.34.2`, `drift_flutter`.
  DB file `ritu.sqlite` in the app support directory. Current schema version
  is **6** (`AppDatabase.schemaVersion` in `lib/data/local/app_database.dart`). Tests/Widgetbook use `AppDatabase.memory()` / in-memory fake
  repos instead of the real file. `lib/data/local/memory_executor*.dart` is a
  conditional-import shim (`_io`/`_web` variants) so `AppDatabase` still
  compiles for web even though `.memory()` (native FFI) throws
  `UnsupportedError` there.
- Navigation: **no router package** — plain imperative
  `Navigator.of(context).push(MaterialPageRoute(...))`, with screens taking
  `onContinue`/`onSkip` callbacks (see `lib/app/ritu_app.dart`). `HomeScreen`
  itself is a bottom-nav shell that swaps tab bodies with a switch expression
  (no `IndexedStack`/named routes); Settings and other full-page flows are
  pushed on top of it.
- Theming: Material 3, `google_fonts` (DM Sans), semantic color tokens in
  `lib/theme/ritu_colors.dart` consumed by `buildRituTheme()` in
  `lib/theme/ritu_theme.dart`.
- Icons: `lucide_icons_flutter`. Animation: `flutter_animate`.
- Lints: stock `flutter_lints: ^6.0.0` via `analysis_options.yaml`, no custom
  rule overrides.

## App boot flow (`lib/app/ritu_app.dart`)

`createRituApp({AppDatabase? database})` wraps `RituApp` in a
`ProviderScope` (used by both `main.dart` and tests/Widgetbook, optionally
overriding `databaseProvider`). `RituApp` watches `profileProvider`:

- loading → spinner
- `profile == null` or `!profile.hasCompletedOnboarding` → `_OnboardingFlow`
  (Splash → Name → Confirmation → LastPeriod → PastDates → Notification →
  marks onboarding complete → bumps `appRestartProvider` to force a full
  `MaterialApp` remount, since navigation has already replaced the bootstrap
  widget with `HomeScreen` by that point)
- otherwise → `HomeScreen`

## Layer layout

```
lib/
  main.dart                 entry point
  app/ritu_app.dart         boot + onboarding flow wiring
  core/                     pure helpers, no Flutter/Drift imports
    cycle_context.dart      journal date/cycle-day formatting
    date_format.dart        display date formatting, dateOnly()/isSameCalendarDay()
  theme/                    ritu_colors.dart (tokens), ritu_theme.dart (ThemeData)
  data/
    models/                 plain Dart classes, no Drift imports (Profile, PeriodLog,
                             CustomSymptom, DailyLogEntry, JournalEntry)
    local/
      app_database.dart     @DriftDatabase, schemaVersion, MigrationStrategy
      app_database.g.dart   generated (committed — see codegen below)
      tables/                one file per table
    repositories/            abstract interfaces (UI depends on these, not Drift)
      drift/                 real SQLite implementations — used by the app and by
                              test/*.dart (via AppDatabase.memory())
      memory/                in-memory fakes (MemoryRituStore + per-entity repos,
                              StreamController.broadcast() per table) — used
                              exclusively by Widgetbook's SeededAppScope so screen
                              previews work on web without SQLite/FFI
  providers/                 hand-written Riverpod providers, one file per domain
  features/                  one folder per screen area, screens/widgets directly
                              inside (no per-feature domain/data split — that lives
                              centrally under lib/data/)
    home/  insights/  journal/  log/  onboarding/  summary/  settings/  setup/  splash/
widgetbook/                  separate Flutter app, see widgetbook/README.md
```

Dependency direction is strict: `Widget → abstract Repository → Drift/Memory
impl → AppDatabase`. Screens never write SQL directly.

## Data model (see `docs/DATA.md` for full detail)

Tables: `profiles` (singleton row, `id = 1`), `period_logs` (one row per
period **episode**, not per bleed day — bleed days are derived via
`PeriodLog.bleedDays`), `custom_symptoms`, `daily_logs` (one row per calendar
day, every field optional, single `upsert()` write on final wizard step),
`journal_entries` (one row per calendar day, free text). A `settings` table
(reminders/notifications) is planned but not implemented. Daily logs don't
yet feed back into `period_logs`.

Repositories expose both one-shot `Future` methods and reactive `Stream`
watchers (`watchX()`, backed by Drift `.watch()` or the memory store's own
stream controllers). Screens read via `ref.watch` on `StreamProvider`s in
`lib/providers/`; writes go through `ref.read` on the repository providers in
`lib/providers/repository_providers.dart`.

## Codegen

After changing Drift tables or the `@DriftDatabase` annotation:

```bash
dart run build_runner build
```

This regenerates `lib/data/local/app_database.g.dart`, which **is committed**
— don't add it to `.gitignore` or expect CI to generate it.

Widgetbook has its own codegen: after adding/renaming/moving a use-case under
`widgetbook/lib/use_cases/`, run `dart run build_runner build -d` inside
`widgetbook/` to regenerate `widgetbook/lib/main.directories.g.dart` (also
committed).

## Testing

```bash
flutter test               # all tests
flutter test test/widget_test.dart   # single file
```

- `test/cycle_context_test.dart` — pure function tests for `lib/core/`.
- `test/daily_log_repository_test.dart`, `test/journal_entry_repository_test.dart`
  — repository behavior against `AppDatabase.memory()` (streaks, upsert
  semantics, ordering).
- `test/widget_test.dart` — mounts the real app via `createRituApp()`. Uses
  the local `rituTestWidgets()` helper instead of `testWidgets()` — it
  unmounts the widget tree in `finally` so Drift stream subscriptions cancel
  cleanly before the test ends. **Use `rituTestWidgets` for any new test that
  mounts `createRituApp`/`RituApp`.**
- No mocking framework in use — tests exercise real Drift-in-memory or the
  in-memory repositories directly, not mocks.

## Widgetbook specifics

`widgetbook/lib/support/seeded_app_scope.dart` defines `SeededAppScope`,
which wraps a screen use-case in a `ProviderScope` backed by
`lib/data/repositories/memory/*` fakes (`MemoryRituStore` + per-entity
repos, living in the **main** `ritu` package, not just Widgetbook) instead of
Drift, so screen previews work on web without SQLite. Use it whenever a
use-case's widget reads Riverpod repository providers (directly or
transitively). Component-only use-cases (buttons, chips, sliders, progress
dots, calendar) don't need it.

When adding a use-case: import the real widget from `package:ritu/...`
(never copy/reimplement it in Widgetbook), annotate with
`@widgetbook.UseCase(name: ..., type: ..., path: '[Category]/Folder')`, then
regenerate `main.directories.g.dart` as above.

## Conventions worth following

- Domain models under `lib/data/models/` must stay free of Drift imports —
  row↔model mapping belongs only in `lib/data/repositories/drift/`.
- New tables: add `lib/data/local/tables/<name>.dart`, register on
  `@DriftDatabase(tables: [...])`, bump `schemaVersion`, add a
  `MigrationStrategy` step, add an abstract + Drift repository, and update
  `docs/DATA.md`.
- New domain state: add a provider file under `lib/providers/` following the
  existing pattern (a `StreamProvider` wrapping a repository's `watchX()`,
  plus derived `Provider`s using `.whenData(...)` for pure transforms) —
  don't reach for `@riverpod` codegen (see Stack note above).
- Keep screens free of SQL/Drift types; they should only ever see repository
  interfaces and domain models via providers.
- **Two implementations per repository**: any new/changed repository method
  needs both a `drift/` and a `memory/` implementation, or Widgetbook's web
  previews silently drift out of sync with the real app.
- `InsightsScreen` and `SummaryScreen` are currently unbuilt — marketing-style
  teasers, not real features yet. Insights switches from an empty hero +
  "Log today" CTA to a "Learning your rhythm" progress card once
  `totalLoggedDays > 0`. Summary switches from an empty hero to a purple
  progress card (`N of 14 days – summary unlock at 14`) on the same trigger.

## CI

`.github/workflows/widgetbook-vercel.yml` is the **only** CI workflow — it
builds and deploys Widgetbook's web bundle to Vercel (components.ritu.care)
on push to `main` when `widgetbook/**`, `lib/**`, or the root `pubspec.yaml`/
`.lock` change (or via manual `workflow_dispatch`). **There is no CI that
runs `flutter test` or `flutter analyze`** for the main app — run those
locally before considering a change done.

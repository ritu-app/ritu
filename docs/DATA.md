# Local data storage

Ritu stores all user data **on-device only** (SQLite via [Drift](https://drift.simonbinder.eu/)). Nothing is uploaded to a backend today.

## Principles

- **UI → repository → database.** Screens do not run SQL. They call repositories (e.g. `ProfileRepository`, `PeriodRepository`).
- **Single local user.** The app is phone-scoped; the profile table is a singleton row (`id = 1`).
- **Migrations over ad-hoc edits.** Schema changes bump `AppDatabase.schemaVersion` and use Drift’s `MigrationStrategy`.
- **Extensible tables.** New domains (journal entries, moods) get their own tables and repositories.

## Stack

| Piece | Package / path |
|--------|----------------|
| ORM / SQL | `drift` |
| Flutter open helper | `drift_flutter` |
| DB file location | app support directory (`path_provider`) |
| Database class | `lib/data/local/app_database.dart` |
| Table definitions | `lib/data/local/tables/` |
| Repositories | `lib/data/repositories/` |
| DI into UI | Riverpod (`lib/providers/`) |

Database file name: **`ritu.sqlite`** (opened as `driftDatabase(name: 'ritu')`).

Current **schema version:** `6`.

### Regenerating code

After changing tables or the `@DriftDatabase` annotation:

```bash
dart run build_runner build
```

Generated output: `lib/data/local/app_database.g.dart` (committed with the repo).

Tests use `AppDatabase.memory()` so they do not touch the device file.

## Layer layout

```
lib/data/
  models/
    profile.dart
    period_log.dart
    custom_symptom.dart
    daily_log_entry.dart
    journal_entry.dart
  local/
    app_database.dart
    app_database.g.dart
    tables/
      profiles.dart
      period_logs.dart
      custom_symptoms.dart
      daily_logs.dart
      journal_entries.dart
  repositories/
    profile_repository.dart      # abstract interface
    period_repository.dart
    symptom_repository.dart
    daily_log_repository.dart
    journal_entry_repository.dart
    drift/
      drift_profile_repository.dart   # Drift/SQLite implementation
      drift_period_repository.dart
      drift_symptom_repository.dart
      drift_daily_log_repository.dart
      drift_journal_entry_repository.dart
```

```
Widget / flow
    │
    ▼
ProfileRepository (abstract)
    │
    ▼
DriftProfileRepository
    │
    ▼
AppDatabase (Drift / SQLite)
```

Domain models in `lib/data/models/` have no Drift imports. Row mapping lives in the `drift/` repository implementations. Abstract repositories expose both one-shot `Future` methods and reactive `Stream` watchers (Drift `.watch()` under the hood).

## Riverpod providers (`lib/providers/`)

Screens read data via `ref.watch` on StreamProviders; writes use `ref.read` on the repository providers below.

| Provider | Source |
|----------|--------|
| `profileProvider` | `watchProfile()` |
| `latestPeriodProvider` | `watchLatest()` |
| `allPeriodsProvider` | `watchAll()` |
| `bleedDaysProvider` | derived from `allPeriodsProvider` |
| `daysSinceLastPeriodProvider` | derived from `latestPeriodProvider` |
| `pastPeriodStartsProvider` | derived from `allPeriodsProvider` |
| `customSymptomsProvider` | `watchAll()` |
| `todayLogProvider` | `watchByDate(today)` |
| `dailyLogByDateProvider(date)` | `watchByDate(date)` |
| `totalLoggedDaysProvider` | `watchTotalLoggedDays()` |
| `currentStreakProvider` | `watchCurrentStreak()` |
| `todayJournalEntryProvider` | `watchByDate(today)` |
| `journalEntryByDateProvider(date)` | `watchByDate(date)` |
| `pastJournalEntriesProvider` | `watchPastEntries(before: today)` |

Providers are hand-written today. `@riverpod` codegen is deferred until `riverpod_generator` can coexist with `drift_dev` on the same `build_runner` toolchain.

## Schema

### `profiles`

Single-row table for the person using this install.

| Column | Type | Notes |
|--------|------|--------|
| `id` | `INTEGER` PK | Always `1` |
| `display_name` | `TEXT` (1–80) | First name from onboarding / Settings |
| `created_at` | `DATETIME` | Set on first insert |
| `onboarding_completed_at` | `DATETIME` nullable | Set when the user reaches Home after setup |
| `typical_period_days` | `INTEGER` nullable | 3 / 5 / 7 from onboarding chips; null = “Varies” |

**Lifecycle**

1. Name screen Continue → `upsertDisplayName`
2. Last period Continue → `setTypicalPeriodDays` + `recordLastPeriod`
3. Past dates Continue → `recordPastStarts` (optional)
4. Setup finished → `markOnboardingCompleted`
5. Cold start → if `onboarding_completed_at` is set → Home; else Splash / onboarding
6. Settings → **Period Started** → `updateLatestStartedOn` (moves latest episode; `source = settings`)
7. Settings → **Period History** → `addPastStart` / `deleteByStartedOn` as dates are added or removed (latest unchanged)
8. Settings → **Delete Data** → `clearAllData()` then remount at Splash

### `period_logs`

One row per **period episode** (not one row per bleed day).

| Column | Type | Notes |
|--------|------|--------|
| `id` | `INTEGER` PK auto | |
| `started_on` | `DATETIME` (date-only) | Unique |
| `ended_on` | `DATETIME` nullable | Inclusive last bleed day; null if unknown |
| `source` | `TEXT` | `onboarding_last`, `onboarding_past`, `calendar`, `settings` |
| `created_at` | `DATETIME` | |
| `updated_at` | `DATETIME` | |

**Derived in `PeriodRepository` (not stored):**

- Bleed days for the calendar = inclusive `started_on…ended_on` (or start-only if end is null)
- Days since last period = today − latest `started_on`
- When only a start + typical length is known, `ended_on = started_on + (typical_period_days - 1)`

### `custom_symptoms`

User-defined body signals shown alongside the (not-yet-built) daily log. Managed via `SymptomRepository`.

| Column | Type | Notes |
|--------|------|--------|
| `id` | `INTEGER` PK auto | |
| `name` | `TEXT` (1–40) | Unique (case-insensitive check in `SymptomRepository.addSymptom`) |
| `created_at` | `DATETIME` | Insertion order = display order |

**Lifecycle**

1. Settings → **Custom Symptoms** → `addSymptom` / `deleteSymptom` as signals are added or removed (no separate Save)
2. Also offered inline from the daily log's "Any body signals?" step (`+ Add your own`) — same repository call, so new signals immediately show up in both places

### `daily_logs`

One row per **calendar day**, filled in by the Home "Log today" flow (`DailyLogFlow`, 4 steps: flow, mood, body signals, notes). Managed via `DailyLogRepository`. Every field is optional — a step left untouched (or explicitly "Skip"ped) just stores `null`. Free-text notes from the final step are **not** stored here — they go to `journal_entries` (see below). Schema v6 migrated any legacy `daily_logs.notes` into `journal_entries` and dropped that column.

| Column | Type | Notes |
|--------|------|--------|
| `id` | `INTEGER` PK auto | |
| `logged_on` | `DATETIME` (date-only) | Unique |
| `flow_intensity` | `TEXT` nullable | One of `None` / `Spotting` / `Light` / `Medium` / `Heavy` |
| `cramp_intensity` | `INTEGER` nullable | 0–10 slider |
| `moods` | `TEXT` nullable | JSON list of selected mood labels (multi-select) |
| `energy_level` | `TEXT` nullable | One of `Drained` / `Low` / `Moderate` / `High` / `Vibrant` |
| `sleep_quality` | `TEXT` nullable | One of `Poor` / `Restless` / `Okay` / `Good` / `Great` |
| `wellbeing` | `INTEGER` nullable | 0–10 slider |
| `symptoms` | `TEXT` nullable | JSON list of selected body signal labels (presets + `custom_symptoms`) |
| `created_at` | `DATETIME` | Set on first save for that day |
| `updated_at` | `DATETIME` | Bumped on every save |

**Lifecycle**

1. Home → **Log today** → `DailyLogFlow` pre-fills structured fields from `getByDate(today)` and notes from `JournalEntryRepository.getByDate(today)` if either already exists (so re-opening edits in place)
2. Each step's "Next"/"Skip" just advances the wizard locally — nothing is written until the final "Save log" step
3. Final step → if any structured answer was given, `DailyLogRepository.upsert(...)`; if notes are non-empty, also `JournalEntryRepository.upsert(...)` for that day. Skipping every step (no answers, empty notes) writes nothing and does not count as a logged day. Empty notes leave any existing journal entry untouched.
4. Home re-reads `watchByDate(today)` via Riverpod: `null` → check-in card, non-null → "Logged today" summary card (moods/energy/sleep/symptoms rendered as read-only pills, "Edit" re-opens the flow pre-filled)

**Derived in `DailyLogRepository` (not stored):**

- `getCurrentStreak()` — consecutive days with an entry, counted backwards from today; if today isn't logged yet it counts back from yesterday instead (so the streak isn't considered broken until the day is over). Drives the flame counter in the Home header.
- `getTotalLoggedDays()` — total count of calendar days with a saved entry (not necessarily consecutive). Drives the "Your patterns will appear here" progress bar on Home (`N of 14 days`) — deliberately counts logging days, not period entries, since patterns need repeated daily check-ins, not period history.

## Journal entries

| Table | Purpose |
|--------|---------|
| `journal_entries` | Free-text reflections — one row per calendar day (`logged_on` unique). Written from the Journal tab **and** from the daily log Notes step. |

**Lifecycle:**

1. User writes in Journal → `JournalEntryRepository.upsert(loggedOn: today, body: ...)`
2. Or: Home → **Log today** → Notes step with non-empty text → same `upsert` for that day
3. UI reads `todayJournalEntryProvider` / `journalEntryByDateProvider` and `pastJournalEntriesProvider` (entries before today, newest first)
4. First save only: green "Today's reflection saved" card with Edit
5. Once past days exist: editable today's card + "Past entries" preview list

Schema v6 migrated any leftover `daily_logs.notes` into this table (skipping days that already had a journal row) and dropped the old column.

## Planned extensions (not implemented yet)

| Table | Purpose |
|--------|---------|
| `settings` | Reminders, notification prefs, etc. |

Daily logs don't yet feed back into `period_logs` (e.g. a logged "flow" doesn't start/extend a period episode) — that cross-linking is a candidate future extension.

When adding a table:

1. Add `lib/data/local/tables/<name>.dart`
2. Register it on `@DriftDatabase(tables: [...])`
3. Bump `schemaVersion` and add a migration
4. Add a repository under `lib/data/repositories/`
5. Update this document

## Privacy

- Data stays in the app’s sandboxed storage.
- Copy on the name screen (“stays on your phone”) matches this architecture.
- Export / sharing (Reports) should be explicit user actions when those features exist—not background sync.

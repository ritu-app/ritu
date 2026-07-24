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
| DI into UI | `AppScope` (`lib/app/app_scope.dart`) |

Database file name: **`ritu.sqlite`** (opened as `driftDatabase(name: 'ritu')`).

Current **schema version:** `2`.

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
  local/
    app_database.dart
    app_database.g.dart
    tables/
      profiles.dart
      period_logs.dart
  repositories/
    profile_repository.dart
    period_repository.dart
```

```
Widget / flow
    │
    ▼
ProfileRepository / PeriodRepository
    │
    ▼
AppDatabase (Drift / SQLite)
```

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

## Planned extensions (not implemented yet)

| Table | Purpose |
|--------|---------|
| `journal_entries` | Free-text reflections from Journal |
| `mood_logs` | Daily mood check-ins from Home |
| `settings` | Reminders, notification prefs, etc. |

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

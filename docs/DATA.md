# Local data storage

Ritu stores all user data **on-device only** (SQLite via [Drift](https://drift.simonbinder.eu/)). Nothing is uploaded to a backend today.

## Principles

- **UI → repository → database.** Screens do not run SQL. They call repositories (e.g. `ProfileRepository`).
- **Single local user.** The app is phone-scoped; the profile table is a singleton row (`id = 1`).
- **Migrations over ad-hoc edits.** Schema changes bump `AppDatabase.schemaVersion` and use Drift’s `MigrationStrategy`.
- **Extensible tables.** New domains (period logs, journal entries, moods) get their own tables and repositories; they do not overload `profiles`.

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

Current **schema version:** `1`.

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
    app_database.dart      # AppDatabase, schemaVersion, connection
    app_database.g.dart    # generated
    tables/
      profiles.dart
  repositories/
    profile_repository.dart
```

```
Widget / flow
    │
    ▼
ProfileRepository (domain-friendly API)
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
| `display_name` | `TEXT` (1–80) | First name from onboarding |
| `created_at` | `DATETIME` | Set on first insert |
| `onboarding_completed_at` | `DATETIME` nullable | Set when the user reaches Home after setup |

**Lifecycle**

1. Name screen Continue → `upsertDisplayName`
2. Setup finished (notifications Turn on / Skip) → `markOnboardingCompleted`
3. Cold start → if `onboarding_completed_at` is set → Home with `display_name`; else Splash / onboarding
4. Settings → **Delete Data** (with confirmation) → `clearAllData()` wipes every table, then the app remounts at Splash

## Planned extensions (not implemented yet)

Suggested next tables (names may change when built):

| Table | Purpose |
|--------|---------|
| `period_logs` | Period start/end (or day marks) from setup + calendar |
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

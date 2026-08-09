# Home greeting — product spec

Source: Figma **Ritu app** → Home greeting frames
([rules](https://www.figma.com/design/WADkFXx1HBoQaC6eS7g6en/Ritu-app?node-id=523-1459),
[before logged AM/PM](https://www.figma.com/design/WADkFXx1HBoQaC6eS7g6en/Ritu-app?node-id=557-1527),
[before logged Eve/Night](https://www.figma.com/design/WADkFXx1HBoQaC6eS7g6en/Ritu-app?node-id=573-1457),
[after logged AM/PM](https://www.figma.com/design/WADkFXx1HBoQaC6eS7g6en/Ritu-app?node-id=573-1543),
[after logged Eve/Night](https://www.figma.com/design/WADkFXx1HBoQaC6eS7g6en/Ritu-app?node-id=573-1699)).

The home header shows **two lines**:

| UI slot | Typography (code) | Example |
| ------- | ----------------- | ------- |
| Line 1  | DM Sans 13 / w500 / secondary (`text/md`) | `Good morning` |
| Line 2 (name) | DM Serif Display **28** / w400 / primary (`display/md`) | `Maya ✨` |
| Line 2 (message) | DM Serif Display **18** / w400 / primary (`display/xs`) | `How are you feeling today?` |

When the resolved greeting includes the user's name, line 2 is `{name} ✨`.
Otherwise line 2 is the copy from the message table.

---

## Resolution priority

Evaluate top to bottom; first match wins.

### Logged today

If today's daily log exists → pick from the **After logged** pool for the
current time window (see below). Name is never shown in these strings.

### Not logged today

Only on **first home open of the calendar day** (local time):

1. **First home visit ever** → `Welcome,` + `{name}`
2. **Streak milestone** (streak equals 3, 7, 14, 30, or 100 today) → milestone
   line + `{name}`
3. **Returning after absence** (≥ 2 calendar days since last home open) → absence
   line + `{name}`
4. **Streak broken** — yesterday has no log and the user has logged before →
   fall through to time pool (no dedicated copy in linked Figma frames)

On **every** open when not logged (including repeat opens the same day) → pick
from the **Before logged** pool for the current time window.

---

## Time windows

Local device clock (overridable in Cycle Studio / Widgetbook):

| Window    | Range              |
| --------- | ------------------ |
| Morning   | 5:00 – 10:59       |
| Afternoon | 11:00 – 15:59      |
| Evening   | 16:00 – 19:59      |
| Night     | 20:00 – 4:59       |

Night wraps midnight (20:00–23:59 and 00:00–04:59).

---

## Message pools

Each pool has **12** `{line1, line2}` pairs per window. The active pair is
chosen deterministically: `dayOfYear % 12` (0-based index into the list).

Implementation: `lib/core/home_greeting.dart`.

### Special (first open, not logged)

**New user — first home visit**

| Line 1     | Line 2   |
| ---------- | -------- |
| Welcome,   | {name}   |

**Returning after absence** (calendar days since last home session)

| Days away | Line 1                         | Line 2 |
| --------- | ------------------------------ | ------ |
| 2–3       | Ready when you are             | {name} |
| 2–3 (alt) | Let's pick up where you left off | {name} |
| 4–7       | Glad to see you again,         | {name} |
| 7+        | Welcome back                   | {name} |

For 2–3 days, alternate with `dayOfYear % 2`.

**Streak milestones** (first open only, streak equals milestone today)

| Milestone | Line 1                         | Line 2 |
| --------- | ------------------------------ | ------ |
| 3 days    | Building a great habit         | {name} |
| 7 days    | Your consistency is growing    | {name} |
| 14 days   | You're in a great rhythm         | {name} |
| 30 days   | Amazing dedication             | {name} |
| 100 days  | What an incredible journey     | {name} |

---

## Persistence

Stored in `SharedPreferences` (see `lib/services/home_greeting_prefs.dart`):

| Key                    | Purpose                                      |
| ---------------------- | -------------------------------------------- |
| `home_has_seen`        | First home visit complete                    |
| `home_last_open_date`  | ISO date of previous home session (absence)  |

Updated when `HomeScreen` mounts. Days-away uses calendar-day difference between
the previous stored open date and today **before** overwriting with today.

---

## Testing

| Surface      | Control                                              |
| ------------ | ---------------------------------------------------- |
| Widgetbook   | **Home → Greeting** use-case with time-of-day knob   |
| Cycle Studio | **Time of day** dropdown + simulated today           |

Pure logic tests: `test/home_greeting_test.dart`.

---

## References

- `lib/core/home_greeting.dart` — pools + resolver
- `lib/features/home/home_greeting_header.dart` — header widget
- `lib/providers/home_greeting_provider.dart` — Riverpod wiring

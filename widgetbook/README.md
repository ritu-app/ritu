# Ritu Widgetbook

A browsable catalog of Ritu's reusable widgets and screens — the Storybook
equivalent for Flutter. It's an independent Flutter app that depends on the
main `ritu` package via a path dependency ([pubspec.yaml](pubspec.yaml)), so
`widgetbook`/`widgetbook_annotation`/`widgetbook_generator`/`device_frame`
never pollute the main app's dependencies.

## Running it

```bash
cd widgetbook
flutter pub get
flutter run -d macos    # or: flutter run -d chrome / -d <ios-simulator-id>
```

### Running in a browser

To launch it in Chrome with hot reload:

```bash
cd widgetbook
flutter run -d chrome
```

Once it's running, use the keys printed in the terminal: `r` for hot reload,
`R` for hot restart, `q` to quit.

If you'd rather use a different browser (or don't want a dedicated Chrome
window to pop up), run it as a plain web server instead and open the printed
URL yourself:

```bash
cd widgetbook
flutter run -d web-server
# then open the printed http://localhost:<port> URL in any browser
```

To see which browsers/devices Flutter can already target on your machine:

```bash
flutter devices
```

To build a deployable web bundle (e.g. for GitHub Pages or Widgetbook Cloud):

```bash
cd widgetbook
flutter build web
# output in widgetbook/build/web — serve it with any static file host
```

**Note on web:** screen-level use-cases (anything under `[Screens]/...`) spin
up an in-memory Drift database via `AppDatabase.memory()`, which uses drift's
native (FFI-based) sqlite backend — not available on web. So the app *builds
and runs* on web, but those specific use-cases show a "Not available on web"
placeholder ([lib/support/seeded_app_scope.dart](lib/support/seeded_app_scope.dart))
instead of crashing. Component-level use-cases (`[Components]/...`) don't
touch the database and render normally on web.

## Deploy to Vercel (GitHub Actions)

Widgetbook is deployed as a static Flutter web app via
[.github/workflows/widgetbook-vercel.yml](../.github/workflows/widgetbook-vercel.yml).
The workflow builds on GitHub (which has Flutter) and uploads
`widgetbook/build/web` to Vercel — Vercel itself does not need Flutter installed.

### One-time setup

1. **Create a Vercel project** linked to this GitHub repo.
   - Framework preset: **Other**
   - Root directory: **repository root** (not `widgetbook/`) — the catalog depends on the parent `ritu` package via `path: ..`
   - You can disable Vercel's own builds; GitHub Actions performs the build.

2. **Collect three values** for GitHub Actions secrets (repo → Settings → Secrets and variables → Actions):

   | Secret | Where to find it |
   |--------|------------------|
   | `VERCEL_TOKEN` | [vercel.com/account/tokens](https://vercel.com/account/tokens) → Create Token |
   | `VERCEL_ORG_ID` | Vercel project → Settings → General, or run `vercel link` locally and read `.vercel/project.json` |
   | `VERCEL_PROJECT_ID` | Same as above |

3. **Push to `main`** (or run the workflow manually via **Actions → Deploy Widgetbook to Vercel → Run workflow**).

The workflow runs when files under `widgetbook/`, `lib/`, or root `pubspec.yaml` change.

### Local preview of the production bundle

```bash
cd widgetbook
flutter build web --release
cd build/web
python3 -m http.server 8080
# open http://localhost:8080
```

### Web limitations (reminder)

`[Screens]/...` use-cases show a placeholder on web because in-memory Drift needs native SQLite.
`[Components]/...` render normally — enough for a shared design-system link.

## Adding a use-case

1. Pick (or create) a file under `lib/use_cases/components/` or
   `lib/use_cases/screens/`.
2. Import the real widget/screen from `package:ritu/...` — never copy or
   reimplement it here.
3. Write a builder function annotated with `@widgetbook.UseCase`:

   ```dart
   @widgetbook.UseCase(name: 'Default', type: MyWidget, path: '[Components]/Foo')
   Widget myWidgetUseCase(BuildContext context) {
     return MyWidget(label: context.knobs.string(label: 'Label', initialValue: 'Hi'));
   }
   ```

   - `path` controls where it shows up in the sidebar. A segment wrapped in
     `[Square Brackets]` becomes a top-level category; plain segments become
     folders under it. This catalog uses two categories: `[Components]` and
     `[Screens]`.
   - Use `context.knobs.*` (`string`, `boolean`, `int.slider`,
     `object.dropdown`, etc.) to make props interactive instead of
     hardcoding example values.
4. If the widget/screen reads repositories via Riverpod (i.e. it uses
   `ref.watch` / `ref.read` on repository providers, directly or transitively),
   wrap it in `SeededAppScope` (see
   [lib/support/seeded_app_scope.dart](lib/support/seeded_app_scope.dart))
   and seed whatever fake data the use-case needs:

   ```dart
   @widgetbook.UseCase(name: 'Logged today', type: HomeScreen, path: '[Screens]/Home')
   Widget homeLoggedTodayUseCase(BuildContext context) {
     return SeededAppScope(
       seed: (repos) async {
         await seedOnboardedProfile(repos);
         await repos.dailyLogs.upsert(loggedOn: DateTime.now(), flowIntensity: 'Light');
       },
       builder: (context) => HomeScreen(name: 'Maya', loggingSince: DateTime.now()),
     );
   }
   ```

5. Regenerate the navigation tree:

   ```bash
   dart run build_runner build -d
   ```

   This updates `lib/main.directories.g.dart`, which is committed to the repo
   so nobody needs to run codegen just to open the catalog — only run it
   after adding, renaming, moving, or removing a use-case.

## Addons

Configured in [lib/main.dart](lib/main.dart):

- **Viewport** — preview at iPhone SE / iPhone 13 / Galaxy S20 sizes (or full
  size via "None"). This is the main defense against the kind of
  layout-only-visible-on-some-screens bug that motivated this catalog (chips
  inside a `Wrap` silently stacking vertically instead of flowing
  horizontally — see `[Components]/Chips → RituChoiceChip → Wrap of options`).
- **Theme** — applies `buildRituTheme()` so `FilledButton`/`OutlinedButton`/
  `TextField` render with Ritu's real styling.
- **Text scale** — stress-test layouts at larger accessibility text sizes.

## Layout

```
lib/
  main.dart                     Entry point + addon configuration
  main.directories.g.dart       Generated navigation tree (commit this)
  support/
    seeded_app_scope.dart       ProviderScope + in-memory DB helper for screen use-cases
  use_cases/
    components/                 Chips, buttons, progress dots, slider, calendar
    screens/                    Home, Settings, Onboarding
```

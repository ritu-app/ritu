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

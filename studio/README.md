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

## Deploy to Vercel (GitHub Actions)

Production URL: **[studio.ritu.care](https://studio.ritu.care/)** *(after DNS is configured)*

Cycle Studio is deployed as a static Flutter web app via
[.github/workflows/studio-vercel.yml](../.github/workflows/studio-vercel.yml).
The workflow builds on GitHub (Flutter available there) and uploads
`studio/build/web` to Vercel — Vercel itself does not run Flutter.

### One-time setup

1. **Create a second Vercel project** for Cycle Studio (separate from Widgetbook).
   - Framework preset: **Other**
   - Root directory: **repository root** (not `studio/`) — Studio depends on the parent `ritu` package via `path: ..`
   - Disable Vercel's own builds; GitHub Actions performs the build.

2. **Add GitHub Actions secrets** (repo → Settings → Secrets and variables → Actions):

   | Secret | Where to find it |
   |--------|------------------|
   | `VERCEL_TOKEN` | Reuse the same token as Widgetbook — [vercel.com/account/tokens](https://vercel.com/account/tokens) |
   | `VERCEL_ORG_ID` | Reuse the same org ID as Widgetbook |
   | `VERCEL_STUDIO_PROJECT_ID` | The **Studio** project's ID (not Widgetbook's) — Vercel project → Settings → General, or `.vercel/project.json` after `vercel link` |

3. **Custom domain** (optional): in the Studio Vercel project, add `studio.ritu.care` and point DNS per Vercel's instructions.

4. **Push to `main`** (or run **Actions → Deploy Cycle Studio to Vercel → Run workflow** manually).

The workflow runs when files under `studio/`, `lib/`, `assets/`, or root `pubspec.yaml` change.

### Local preview of the production bundle

```bash
cd studio
flutter build web --release
cd build/web
python3 -m http.server 8080
# open http://localhost:8080
```

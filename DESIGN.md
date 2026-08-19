---
version: alpha
name: Ritu
description: Private cycle journal — warm, calm, wellness-focused mobile UI
colors:
  primary: "#5F8F7A"
  primary-hover: "#4F7765"
  primary-pressed: "#416252"
  on-primary: "#FFFFFF"
  secondary: "#AFCDB8"
  accent: "#E4C6B8"
  background: "#F9F7F4"
  surface: "#FFFFFF"
  surface-subtle: "#EDF5F0"
  text-primary: "#322F2D"
  text-secondary: "#69635F"
  text-tertiary: "#A9A19B"
  text-disabled: "#C8C1BC"
  text-inverse: "#FCFBFA"
  text-brand: "#4F7765"
  text-positive: "#588164"
  text-critical: "#945959"
  text-attention: "#C49A3A"
  text-info: "#8B7BB5"
  border-subtle: "#F0ECE8"
  border-default: "#D9D4CF"
  border-disabled: "#DADADA"
  border-brand: "#5F8F7A"
  border-focus: "#5F8F7A"
  fill-secondary: "#EDF5F0"
  fill-secondary-hover: "#B9D3C0"
  fill-accent: "#EFD8CE"
  fill-critical: "#EFD0D0"
  fill-critical-secondary: "#FCF4F4"
  fill-positive-secondary: "#F3FBF5"
  fill-attention-secondary: "#FFFBEF"
  fill-info: "#E1DAF0"
  fill-info-secondary: "#F8F6FC"
  cycle-menstrual: "#C98A8A"
  cycle-follicular: "#8DBE9A"
  cycle-ovulatory: "#F2D38B"
  cycle-luteal: "#B9AECF"
typography:
  display-xl:
    fontFamily: DM Serif Display
    fontSize: 52px
    fontWeight: 400
    lineHeight: 54px
    letterSpacing: -0.5px
  display-lg:
    fontFamily: DM Serif Display
    fontSize: 38px
    fontWeight: 400
    lineHeight: 42px
    letterSpacing: -0.3px
  display-md:
    fontFamily: DM Serif Display
    fontSize: 28px
    fontWeight: 400
    lineHeight: 34px
    letterSpacing: 0px
  display-sm:
    fontFamily: DM Serif Display
    fontSize: 20px
    fontWeight: 400
    lineHeight: 26px
    letterSpacing: 0px
  display-xs:
    fontFamily: DM Serif Display
    fontSize: 18px
    fontWeight: 400
    lineHeight: 25px
    letterSpacing: 0px
  text-2xl:
    fontFamily: DM Sans
    fontSize: 22px
    fontWeight: 400
    lineHeight: 26px
    letterSpacing: -0.2px
  text-xl:
    fontFamily: DM Sans
    fontSize: 18px
    fontWeight: 400
    lineHeight: 24px
    letterSpacing: 0px
  text-lg:
    fontFamily: DM Sans
    fontSize: 15px
    fontWeight: 400
    lineHeight: 24px
    letterSpacing: 0px
  text-lg-medium:
    fontFamily: DM Sans
    fontSize: 15px
    fontWeight: 500
    lineHeight: 24px
    letterSpacing: 0px
  text-lg-semibold:
    fontFamily: DM Sans
    fontSize: 15px
    fontWeight: 600
    lineHeight: 24px
    letterSpacing: 0px
  text-md:
    fontFamily: DM Sans
    fontSize: 13px
    fontWeight: 400
    lineHeight: 20px
    letterSpacing: 0px
  text-md-medium:
    fontFamily: DM Sans
    fontSize: 13px
    fontWeight: 500
    lineHeight: 20px
    letterSpacing: 0px
  text-md-semibold:
    fontFamily: DM Sans
    fontSize: 13px
    fontWeight: 600
    lineHeight: 20px
    letterSpacing: 0px
  text-sm:
    fontFamily: DM Sans
    fontSize: 11px
    fontWeight: 400
    lineHeight: 18px
    letterSpacing: 0px
  text-xs-caps:
    fontFamily: DM Sans
    fontSize: 10px
    fontWeight: 600
    lineHeight: 14px
    letterSpacing: 0.08em
spacing:
  none: 0px
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 20px
  2xl: 24px
  3xl: 32px
  4xl: 40px
  5xl: 48px
  6xl: 64px
  margin: 16px
  gutter: 8px
  grid-columns: 4
rounded:
  none: 0px
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 20px
  2xl: 24px
  3xl: 32px
  full: 9999px
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.text-lg-semibold}"
    rounded: "{rounded.full}"
    height: 48px
    padding: 12px
  button-primary-pressed:
    backgroundColor: "{colors.primary-pressed}"
    textColor: "{colors.on-primary}"
    typography: "{typography.text-lg-semibold}"
    rounded: "{rounded.full}"
    height: 48px
  button-secondary:
    backgroundColor: transparent
    textColor: "{colors.text-tertiary}"
    typography: "{typography.text-lg-medium}"
    padding: 4px
  button-outlined:
    backgroundColor: transparent
    textColor: "{colors.text-brand}"
    typography: "{typography.text-lg-semibold}"
    rounded: "{rounded.full}"
    height: 48px
  input-field:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    typography: "{typography.text-lg}"
    rounded: "{rounded.md}"
    padding: 12px
  card-standard:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.lg}"
    padding: 16px
---

## Overview

Ritu is a private cycle journal used in quiet, personal moments — logging how
you feel, reading patterns, writing in a journal. The visual language should
feel like a **wellness companion**, not a clinical tracker or productivity
dashboard.

**Brand personality:** warm, trustworthy, calm, spacious. Sage-led palette with
soft earth tones — no stereotypical pinks, no medical blues, no aggressive
contrast.

**Type pairing:** DM Serif Display for moments of meaning (greetings, hero
numbers, journal prompts). DM Sans for everything operational (buttons, body,
labels, navigation).

**Platform:** Flutter mobile (iOS + Android). **Light mode only** for now —
`AppAppearance` persists dark preference but does not apply a dark theme yet.

**Source of truth:** Figma file [Ritu app](https://www.figma.com/design/WADkFXx1HBoQaC6eS7g6en/Ritu-app)
(→ Colors, → Typography, → Spacing, radius & grid). Code tokens live in
`lib/theme/ritu_colors.dart` and `lib/theme/ritu_theme.dart`. Reusable widgets
are catalogued in Widgetbook ([components.ritu.care](https://components.ritu.care/)).

## Colors

Three-layer architecture: **primitive palettes** (Sage, Mist Sage, Blush,
Neutrals, phase colors) → **semantic tokens** (text-*, fill-*, border-*) →
**component usage**. Target distribution: 60% neutral, 20% brand, 10% accent,
10% cycle phase. WCAG AA minimum (4.5:1 normal text).

- **Primary (#5F8F7A Sage):** Brand actions, focus rings, key interactive
  chrome. Warm alternative to clinical healthcare blue.
- **Primary hover / pressed (#4F7765 / #416252):** Hover and pressed states for
  brand-filled controls.
- **Background (#F9F7F4):** Warm off-white page canvas — softer than pure white
  for extended daily use.
- **Surface (#FFFFFF):** Elevated cards and inputs; use sparingly so content
  stands out against the warm background.
- **Text primary (#322F2D):** Headlines, body, labels — deep brown, not pure
  black.
- **Text secondary / tertiary (#69635F / #A9A19B):** Supporting copy, metadata,
  timestamps.
- **Cycle colors (informational only):** Rosewood menstrual (#C98A8A), Meadow
  follicular (#8DBE9A), Honey ovulatory (#F2D38B), Lavender luteal (#B9AECF).
  Never use cycle colors as primary brand fills.
- **Gradients:** Hero cards, onboarding, splash only — **never** button or
  interactive control backgrounds. See `RituColors.gradient*` in code.

In Flutter, always reference `RituColors.*` — never inline `Color(0xFF…)`.

## Typography

Built on a **Minor Third (1.200×) scale** anchored at 16px base. Only weights
**400, 500, 600** in live UI — **700 is never used**.

**Serif for reflection, sans for function.** DM Serif Display: hero numbers,
greeting name/message, journal prompts, insight headlines. DM Sans: buttons,
labels, body, navigation, forms.

**Line height:** body copy ~1.6× (`text-md` → 20/13), cards ~1.5× (`text-lg` →
24/15).

**Minimum sizes (live UI):**

| Context | Size | Weight |
| ------- | ---- | ------ |
| Body copy | 13px | 400 |
| Buttons / CTAs | 15px | 600 |
| Caption / meta | 11px | 400 |
| Uppercase labels | 10px | 600 |
| Phase strip labels | 8px | 600 — **only exception** |

In Flutter use `GoogleFonts.dmSans(...)` and `GoogleFonts.dmSerifDisplay(...)`.
Load fonts via `google_fonts` — do not substitute Material default fonts.

Common screen mappings:

- Home greeting line 1 → `text-md-medium` (13/w500) + `text-secondary`
- Home greeting name → `display-md` (28/w400) + `text-primary`
- Home greeting message → `display-xs` (18/w400) + `text-primary`
- Onboarding hero → `display-lg` (38/w400)
- Primary button label → `text-lg-semibold` (15/w600)

Feature copy rules (e.g. home greeting pools) live in `docs/home-greeting-spec.md`.

## Layout

**Base unit:** 4px. All spacing uses 4px multiples.

**Screen grid:** 4 columns, 8px gutter, **16px horizontal margin** on standard
content. On iPhone 13 width, content area ≈ 343px.

**Full-bleed exceptions:** hero card and bottom nav extend edge-to-edge; content
*inside* the hero still uses 16px internal padding.

**Column usage:**

- Most content spans all 4 columns (cards, buttons, calendar, phase strip).
- Highlights grid is the **only** 2-column layout (columns 1–2 and 3–4).
- Hero card breaks side margins intentionally for immersion.

**Spacing rhythm:** large gaps separate unrelated sections; small gaps connect
related elements. Prefer `space-lg` (16px) as default component padding and
`space-2xl` (24px) between sections.

In Flutter prefer named spacing constants from this scale over magic numbers.
Common pattern: `EdgeInsets.symmetric(horizontal: 16)` for screen insets.

## Elevation & Depth

Flat design — no drop shadows. Hierarchy uses **tonal layers**: warm background
(`background`) → white elevated surface (`surface`) → subtle borders
(`border-subtle`, `border-default`). Hero cards may use phase gradients as
ambient depth; they remain full-bleed decorative layers, not elevated shadows.

## Shapes

Soft but not playful. Sharp corners feel clinical; extreme roundness feels
toy-like. Ritu sits in between.

| Token | Radius | Use |
| ----- | ------ | --- |
| `radius-sm` | 8px | Small chips, compact controls |
| `radius-md` | 12px | Inputs, dropdowns |
| `radius-lg` | 16px | Standard cards |
| `radius-xl` | 20px | Large wellness panels |
| `radius-2xl` | 24px | Modals, bottom sheets |
| `radius-3xl` | 32px | Hero components |
| `radius-full` | 9999px | Pills, primary/secondary buttons, tags |

Interactive pill elements always use `StadiumBorder` / `radius-full`. Charts and
edge-to-edge elements may use `radius-none`.

## Components

Reuse existing widgets before creating new ones. Check Widgetbook under
`[Components]/` and screen use-cases before building ad-hoc UI.

**Buttons**

- **Primary:** full-width pill, 48px height, sage fill, white label. Use
  `FilledButton` via theme or `SetupFooter` (`lib/features/setup/widgets/setup_footer.dart`).
- **Secondary (text):** DM Sans 15/w500, `text-tertiary`, no fill — skip link
  below primary in `SetupFooter`.
- **Outlined pill:** `OutlinedPillButton` — sage border, sage600 text, 48px
  height.

**Inputs**

- Filled white surface, `border-subtle` default border, `primary` focus border,
  12px radius, 16×12px content padding.

**Cards**

- White (`surface`) on warm background, 16px radius, 16px internal padding.
- Status banners use semantic `fill-*-secondary` surfaces (positive, attention,
  critical, info).

**Chips**

- `RituChoiceChip`, `RituDateChip` in `lib/features/setup/widgets/choice_chips.dart`.

**Icons**

- Lucide only (`lucide_icons_flutter`). Settings back: `chevronLeft`. Sheet
  close: `x`. Do not mix icon families.

**Sheets & dialogs**

- Bottom sheets: 24px top radius (`radius-2xl`). Modal dialogs: 16px (`radius-lg`).

**Cycle hero**

- Phase-specific linear gradients from `RituColors.gradient*`. Full-bleed;
  gradient is decorative — never on tappable fills.

When adding a new shared component, add a Widgetbook use-case and regenerate
`widgetbook/lib/main.directories.g.dart`.

## Do's and Don'ts

**Do**

- Read this file and check Figma before UI work.
- Use `RituColors` and `GoogleFonts` — match token names to this spec.
- Reuse `SetupFooter`, `OutlinedPillButton`, `RituChoiceChip`, `RituCalendar`,
  `LogSliderCard` when applicable.
- Preserve Figma copy spelling where screens intentionally match design (e.g.
  "Calender" label on journal filter sheet).
- Keep light-mode-only until dark theme is explicitly implemented.
- Maintain WCAG AA contrast; approved pairs documented in Figma Typography page.

**Don't**

- Hardcode hex colors or invent new palette entries without updating this file
  and `ritu_colors.dart`.
- Use font weight 700 anywhere in the app.
- Use cycle phase colors as primary brand or button fills.
- Put gradients on buttons, chips, or other interactive fills.
- Use drop shadows — hierarchy is tonal (background → white surface → border).
- Use radius values outside the scale (e.g. 7px) on new work.
- Build screen-only button/chip styles when a shared component exists.
- Implement dark mode styling while `AppAppearance.dark` is still a stub.

**Known code drift (fix when touching these files):**

- `ritu_theme.dart` input `borderRadius` is 8px — spec says **12px** (`radius-md`).
- Some journal UI uses 7px radius — not in the scale; migrate to 8px or 12px.

Validate this file locally: `npx @google/design.md lint DESIGN.md`

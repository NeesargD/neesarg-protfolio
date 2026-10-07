# Neesarg Darji — Portfolio

An editorial-dark, motion-rich personal resume site built in **Flutter Web**.
Inspired by sites like laurarountree.net and andrevv.com — big serif
typography, a floating glass nav, a custom trailing cursor, film grain, and
scroll-driven reveals.

## Design language

- **Vibe:** editorial luxury on a warm near-black canvas (`#0A0908`) with a
  single vermilion accent (`#FF5A1F`) — a nod to the healthcare / ambulance work.
- **Type:** Fraunces (display serif) · Space Grotesk (UI sans) · JetBrains Mono
  (labels & numbers), loaded via `google_fonts`.
- **Motion:** custom cubic-bezier curves (no stock easing), staggered masked
  headline reveals, fade/blur-up on scroll, magnetic buttons, an animated
  aurora backdrop, and an intro counter + curtain wipe.
- **Accessibility:** honours `prefers-reduced-motion` (skips the intro and
  collapses reveals to instant).

## Architecture

```
lib/
  core/
    data/resume_data.dart       # all copy, in one place
    theme/                      # colours, type, theme, motion curves
    utils/                      # responsive + reduced-motion helpers
  widgets/
    cursor/                     # custom cursor controller + render layer
    grain_overlay.dart          # pre-rendered noise tile via ImageShader
    aurora_background.dart      # drifting radial glows
    reveal.dart / rising_text.dart / marquee.dart / magnetic.dart
    section_header.dart / section_shell.dart
  sections/                     # nav, hero, about, skills, experience, contact
  screens/                      # intro_loader, home_screen
  main.dart
```

Continuous pointer values (cursor, magnetic hover, marquee) are driven through
`ValueNotifier` + `AnimatedBuilder` rather than `setState`, so only the
transform repaints.

## Run

```bash
flutter pub get
flutter run -d chrome          # dev
flutter build web              # production -> build/web
```

> On this machine Flutter is a Windows SDK; from WSL run it via
> `cmd.exe /c "flutter ..."`.

## Edit your content

Everything (headline, intro, stats, skills, experience, contact) lives in
`lib/core/data/resume_data.dart`. Change copy there; layout code never needs
touching.

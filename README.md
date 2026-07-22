# MeterPulse

**Track your utility meters throughout the billing cycle — not just once a month. Fully offline.**

MeterPulse is a personal Android app for recording electricity, gas, water (and other) meter readings, watching consumption build up day-by-day within each billing cycle, and keeping bills in one place. Photograph the dial and on-device OCR reads the number for you. No account, no internet, no data ever leaves your phone.

![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter&logoColor=white)
![Material 3](https://img.shields.io/badge/Material%203-Material%20You-4285F4)
![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)
![Offline](https://img.shields.io/badge/offline-100%25-success)

---

## Why MeterPulse — my use case

I have **five utility meters** and actively monitor **four** of them. My problem with every other tracker (and with just jotting numbers in Notes) is that they only capture **one reading a month** — the value on billing day. By then it's too late to do anything about a high bill.

What I actually want is to **track readings throughout the billing cycle**:

- Take a reading whenever I walk past a meter — the 15th, the 17th, the 20th…
- See how many units I've used **so far this cycle**, my **average per day**, and a **projected month-end** total, so a spike is obvious *before* the bill arrives.
- Keep a **timeline** for each cycle (15 Jul → 12500, 17 Jul → 12518 (+18), 20 Jul → 12546 (+28)…) with the differences computed automatically.
- Snap a photo of the dial and let the app read the digits instead of squinting and typing.
- File the paper bill next to the readings it corresponds to.
- Have all of it work **offline**, on **my device only** — no sign-up, no sync, no cloud.

MeterPulse is built around exactly that workflow.

---

## Features (Phase 1 — shipped)

- **Meters** — add unlimited meters (electricity / gas / water / other), each with a name, meter number, unit, reading day-of-month, optional rollover/max value, a custom accent colour, and a high-usage threshold. Mark meters active/inactive (so my unmonitored 5th meter stays out of the way without being deleted).
- **OCR-assisted readings** — photograph the meter → on-device Google ML Kit extracts the longest numeric sequence → you confirm/edit the value. Falls back to **gallery pick** or **manual entry**, and warns when a reading is lower than the last one (meter reset vs. typo).
- **Consumption timeline** — every reading in a cycle with the units consumed since the previous one, computed automatically.
- **Dashboard** — one card per active meter: units used this cycle, avg/day, projected month-end, reading & bill status, days until next reading/bill, quick actions.
- **Bills** — manual entry (amount, date, due date, units billed, paid status) with an optional photo of the paper bill.
- **Statistics** — total consumed, average monthly/yearly, highest/lowest reading, cycles tracked.
- **Automatic billing cycles** — a new cycle starts when you take a cycle-opening reading; the previous cycle becomes read-only. No background jobs required.
- **Material You design** — dynamic colour (Android 12+) with a seed fallback, light/dark/system themes, rounded cards, shimmer loading, empty & error states, and shared-element transitions.

## Roadmap

- **Phase 2** — reading & bill reminders (local notifications), rule-based high-usage / abnormal-spike alerts, and usage charts (fl_chart).
- **Phase 3** — CSV export and local database backup/restore.
- **Later** — automatic OCR of bills; optional cloud sync (the repository layer is already abstracted for it).

---

## Architecture

Clean Architecture, **feature-first**. Each feature is split into `domain` (entities, repository interfaces, use cases), `data` (Isar models + repository implementations), and `presentation` (cubits + pages + widgets). The calculation engine is **pure Dart** with no Flutter/Isar imports, so it is fully unit-tested.

```
lib/
  app/            # MaterialApp, GoRouter, theme wiring
  core/
    calculation_engine/   # pure, tested: consumption, projections, date math
    theme/                # Material You tokens (colour, spacing, type)
    widgets/              # reusable AppCard, StatTile, EmptyState, LoadingView…
    services/             # camera, file storage, permissions
    database/             # Isar setup
    di/                   # get_it service locator
    error/ · utils/
  features/
    meters/ · readings/ · bills/ · billing_cycles/ · dashboard/ · settings/
test/
  core/calculation_engine/   # 47 unit tests
```

- **State management:** Cubit / `flutter_bloc`
- **Dependency injection:** `get_it` (manual registration, no codegen)
- **Routing:** `go_router`
- **Persistence:** Isar (via the `isar_community` fork — see notes)

## Tech stack

| Concern | Package |
|---|---|
| UI | Flutter, Material 3, `dynamic_color`, `animations` |
| State | `flutter_bloc`, `equatable` |
| Routing | `go_router` |
| Database | `isar_community`, `isar_community_flutter_libs` |
| OCR | `google_mlkit_text_recognition` (on-device) |
| Camera / images | `camera`, `image_picker`, `path_provider` |
| DI | `get_it` |
| Misc | `permission_handler`, `intl`, `uuid`, `fl_chart` (Phase 2) |

---

## Getting started

**Prerequisites:** Flutter (latest stable), an Android device or emulator (min SDK 21; the OCR model downloads on first launch).

```bash
git clone git@github.com:NadeemIqbal/MeterPulse.git
cd MeterPulse
flutter pub get
flutter run
```

The generated Isar files (`*.g.dart`) are committed, so no code-generation step is needed to build. If you change an Isar model, regenerate them with:

```bash
dart run build_runner build
```

## Testing

The calculation engine (the correctness-critical core) is covered by unit tests:

```bash
flutter test
```

## Implementation notes

- **Isar fork for 16 KB pages** — uses `isar_community` (not mainline `isar` 3.1.0) because its native library is aligned for Android 15+'s 16 KB memory page size, which Google Play requires for new API-35+ apps. Mainline Isar's binary fails that check. `android/build.gradle.kts` also injects an Android `namespace` for the Isar module (an AGP 8 requirement).
- **OCR confidence is an estimate** — ML Kit doesn't expose a per-number confidence, so the "% confidence" shown is a heuristic (digit-run length, decimal presence, how many numeric candidates were found). Always double-check the detected value.

## License

Personal project — all rights reserved unless a license file is added.

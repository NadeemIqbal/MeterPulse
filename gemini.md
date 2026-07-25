# Gemini AI Agent Guidelines for MeterPulse

This document provides essential repository context, architectural guidelines, code standards, and workflow instructions for AI coding assistants working on the **MeterPulse** codebase.

---

## 1. Project Overview

**MeterPulse** is a personal, 100% offline Android application built with Flutter for tracking utility meters (electricity, gas, water, etc.) throughout their billing cycles. It includes OCR-assisted meter reading capture, daily consumption analytics, automatic cycle calculations, bill management, smart alerts, and data export/backup capabilities.

### Key Tech Stack
- **Framework:** Flutter (Dart SDK `^3.11.5`, Material 3 design)
- **State Management:** `flutter_bloc` (Cubit pattern) with `equatable`
- **Routing:** `go_router`
- **Dependency Injection:** `get_it` (manual service locator, no codegen)
- **Database:** `isar_community` & `isar_community_flutter_libs` (Isar 3.3.x fork supporting Android 15+ 16 KB page sizes)
- **On-Device OCR:** `google_mlkit_text_recognition`
- **Charts:** `fl_chart`
- **Local Notifications:** `flutter_local_notifications` + `timezone`
- **Export & Storage:** `csv`, `share_plus`, `file_picker`, `path_provider`

---

## 2. Repository Architecture & Directory Structure

MeterPulse adheres to **Clean Architecture** structured **feature-first**.

```
lib/
├── main.dart                   # Entry point (initializes DB, DI, App)
├── app/                        # App config, GoRouter routes, Material Theme wiring
├── core/
│   ├── calculation_engine/     # PURE DART: consumption, projections, date math (Zero Flutter/Isar imports!)
│   ├── database/               # Isar DB setup and schema definitions
│   ├── di/                     # GetIt dependency injection registrations
│   ├── error/                  # Custom Failure & Exception classes
│   ├── services/               # Camera, OCR, Notifications, Storage, Permission services
│   ├── theme/                  # Material You color schemes, typography, spacing tokens
│   ├── utils/                  # Date, string, and number parsing helpers
│   └── widgets/                # Shared reusable UI components (AppCard, StatTile, EmptyState, etc.)
└── features/
    ├── analytics/              # Usage stats & charts
    ├── backup/                 # DB backup & restore
    ├── billing_cycles/         # Billing cycle management & history
    ├── bills/                  # Bill logging & image handling
    ├── dashboard/              # Active meters overview & status cards
    ├── export/                 # CSV data export
    ├── meters/                 # Meter management (CRUD, active/inactive state)
    ├── readings/               # Reading entries, OCR scanner integration, timeline
    └── settings/               # App settings & reminder configuration
```

### Feature Architecture Pattern
Each feature folder under `lib/features/<feature_name>/` follows this layer separation:
- `domain/`: Pure Dart entities, repository interfaces, and use cases.
- `data/`: Isar collection models, repository implementations, and data mappers.
- `presentation/`: Cubits/Blocs, UI pages, and feature-specific widgets.

---

## 3. Critical Architecture Rules & Constraints

### 🔴 Pure Dart Calculation Engine (`lib/core/calculation_engine/`)
- **STRICT RULE:** Code inside `lib/core/calculation_engine/` must remain **100% pure Dart**.
- **NO** `package:flutter/...` or `package:isar/...` imports are allowed.
- All core calculations (units consumed, daily averages, projections, month-end date math, cycle delta comparisons) live here and MUST be covered by unit tests.

### 🔴 Isar Database & 16 KB Page Alignment
- **STRICT RULE:** Use `isar_community` / `isar_community_flutter_libs` package imports. Do **NOT** replace them with standard mainline `isar` packages.
- Mainline Isar binaries fail Google Play's 16 KB memory page size requirements for Android 15+ (API 35+). `isar_community` provides the necessary native libraries.
- Isar models (`*.g.dart`) are checked into git. When modifying an Isar model (`lib/core/database/` or `lib/features/*/data/models/`), run code generation to update `.g.dart` files.

### 🟡 State Management & Dependency Injection
- Use **Cubit** (`flutter_bloc`) for presentation logic.
- Register services, repositories, and cubits in `lib/core/di/injection_container.dart` using **GetIt**. Avoid adding auto-generated DI packages like `injectable` unless requested.

---

## 4. Development Workflow & Commands

### Prerequisites
- Flutter SDK (stable channel)
- Dart SDK `^3.11.5`
- Android SDK (min SDK 21)

### Standard Commands

| Action | Command |
|---|---|
| Fetch Dependencies | `flutter pub get` |
| Run Application | `flutter run` |
| Execute Unit Tests | `flutter test` |
| Run Static Analysis | `flutter analyze` |
| Code Generation (Isar) | `dart run build_runner build` |
| Clean Codegen Conflicts | `dart run build_runner build --delete-conflicting-outputs` |

---

## 5. Coding Standards & Best Practices

1. **Immutability & Value Equality:**
   - Use `equatable` for Domain Entities and Cubit States.
2. **Null Safety & Error Handling:**
   - Return `Either<Failure, T>` or throw typed `Failure` objects in Repositories/Use Cases.
   - Never swallow errors silently or return dummy fallbacks that obscure root causes.
3. **Static Analysis & Linting:**
   - Follow `analysis_options.yaml` (`package:flutter_lints/flutter.yaml`).
   - Isar generated files (`**/*.g.dart`) are excluded from analysis.
4. **Testing Guidelines:**
   - Always run `flutter test` after modifying any calculation engine, utility, or business logic code.
   - Write unit tests in `test/core/calculation_engine/` or `test/core/utils/` for any new mathematical or parsing algorithms.

---

## 6. Guidelines for AI Assistants

- **Check Tests First:** Verify that existing tests in `test/` pass before and after applying changes.
- **Maintain Clean Boundaries:** Do not bleed Flutter UI code into domain or calculation layers.
- **Preserve Documentation & Comments:** Retain existing doc comments and context when editing files.
- **Do Not Mask Bugs:** If a test or execution fails, investigate the root cause via logs rather than suppressing lint rules or commenting out assertions.

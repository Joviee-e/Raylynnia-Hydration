# Raylynnia Hydration

> **Stay hydrated. Automatically. On your schedule.**

A Flutter-based mobile application that delivers adaptive, sleep-aware hydration reminders — fully offline, fully private.

---

## The Problem

Most hydration apps either nag you with reminders at fixed clock times (which ignore your actual sleep/wake schedule), require a cloud account to function, or send notifications at 6am on a Sunday when you're sleeping in. None of them adapt to the difference between your workday routine and your weekend rhythm.

## The Solution

Raylynnia Hydration builds a personalized hydration window around your actual day — when you wake up, when you go to sleep, and whether it's a weekday or weekend. It distributes reminder notifications evenly across that window, respects your sleep boundary, and stores everything on your device. No internet. No account. No noise.

---

## Features

### Core Features

- **Adaptive Scheduling** — Separate reminder cadences for weekdays and weekends. Reminders only fire within your active hydration window (wake time → sleep time, with configurable buffers).
- **Sleep-Aware** — Never scheduled during your defined sleep window. The schedule adjusts automatically as your preferences change.
- **Persistent Notifications** — Local notifications that survive app restarts. Rescheduled automatically when preferences change.
- **Hydration Logging** — Tap to log a drink. Tracks volume and timestamp per entry.
- **Daily Progress** — Visual summary of today's intake vs. your goal.
- **History View** — Review past logs by day and week.
- **Fully Offline** — Zero network dependency. All data lives on your device.
- **First-Run Onboarding** — Guided setup for your name, wake/sleep times, day preference, and daily intake goal.

### Upcoming Features (Future Scope)

See [Future Scope](#future-scope) below.

---

## Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| Local Storage | Hive (time-series logs) + SharedPreferences (profile/settings) |
| Notifications | flutter_local_notifications |
| Dependency Injection | GetIt |
| Navigation | GoRouter |
| Testing | flutter_test, mocktail |

All dependencies are local-only. No Firebase, no REST APIs, no analytics SDKs.

---

## Architecture Summary

Raylynnia Hydration follows **Clean Architecture** with three principal layers:

```
Presentation Layer   →   What the user sees and interacts with
      ↕
Domain Layer         →   Business rules, scheduling logic (pure Dart)
      ↕
Data Layer           →   Persistence, notification platform adapters
```

The **Scheduling Engine** lives in the Domain layer as a pure Dart service. It accepts wake time, sleep time, day type, and reminder interval — and returns an ordered list of reminder `DateTime` values. This design means the algorithm can be unit-tested without any Flutter or platform dependency.

The **Notification Manager** lives in the Data layer and wraps `flutter_local_notifications` behind a repository interface. The Domain layer never knows which notification library is in use.

The **User Profile Manager** spans the Domain (use cases + entity) and Data (repository implementation + local datasource) layers, with reactive state exposure to the Presentation layer via Riverpod providers.

For full architectural details, see [`docs/SYSTEM_ARCHITECTURE.md`](./docs/SYSTEM_ARCHITECTURE.md).
For the complete file structure, see [`docs/FILE_STRUCTURE.md`](./docs/FILE_STRUCTURE.md).

---

## Project Structure (Summary)

```
lib/
├── core/          # Shared utilities, theme, routing, DI
├── domain/        # Entities, use cases, repository contracts, scheduling engine
├── data/          # Repository implementations, local datasources, notification manager
└── features/
    ├── onboarding/
    ├── home/
    ├── scheduling_engine/
    ├── user_profile/
    └── history/
```

---

## Setup Instructions

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart `>=3.0.0`
- Android Studio or VS Code with Flutter extension
- Xcode (for iOS builds)
- CocoaPods (for iOS dependency resolution)

### Getting Started

**1. Clone the repository**
```bash
git clone https://github.com/your-org/raylynnia_hydration.git
cd raylynnia_hydration
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Generate Hive adapters** (required for local storage models)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**4. Run the app**
```bash
# Development
flutter run

# Android release build
flutter build apk --release

# iOS release build
flutter build ios --release
```

### Platform-Specific Setup

**Android:**
- Minimum SDK: API 21 (Android 5.0)
- For exact alarm support (Android 12+): The `SCHEDULE_EXACT_ALARM` permission must be declared in `AndroidManifest.xml`. The app handles graceful fallback if the permission is not granted.

**iOS:**
- Minimum deployment target: iOS 13.0
- Notification permission is requested at the end of onboarding. Users may manage it via Settings → Notifications at any time.

### Running Tests

```bash
# All tests
flutter test

# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/
```

---

## Development Phases

| Phase | Focus |
|---|---|
| Phase 1 | Core domain entities, repository interfaces, SchedulingEngine algorithm |
| Phase 2 | Data layer — Hive setup, local datasources, repository implementations |
| Phase 3 | Notification Manager integration, scheduling end-to-end |
| Phase 4 | Onboarding flow — multi-step wizard, profile persistence |
| Phase 5 | Home screen — logging, daily progress, next reminder display |
| Phase 6 | Settings — schedule preferences, live schedule preview |
| Phase 7 | History — daily log view, weekly summary chart |
| Phase 8 | Polish — theming, animations, accessibility, edge case handling |

---

## Future Scope

| Feature | Description |
|---|---|
| Data Export | Export hydration history as CSV for personal records |
| Wearable Support | WearOS / Apple Watch complication integration |
| Widget Support | Home screen widget showing today's progress |
| Streaks & Milestones | Motivational tracking of consistent hydration days |
| Custom Volume Presets | Quick-log buttons for common container sizes |
| Multi-Profile | Support for multiple household members |
| Cloud Backup (opt-in) | Optional encrypted backup to iCloud / Google Drive |
| Siri / Google Assistant | Voice shortcuts for logging a drink |

## System Architecture Mechanisms

### Timezone-Aware Notification Scheduling
To ensure notifications fire at the exact user-defined times without battery-draining GPS/location requests, Raylynnia Hydration utilizes device-local timezone detection:
- Uses the `flutter_timezone` package to automatically determine the device's current IANA timezone name.
- Initializes the `timezone` database (`tz.initializeDatabase()`) and binds `tz.local` to the identified timezone.
- Schedules all daily reminders using `tz.TZDateTime.from` in the user's local timezone.
- When timezone offsets change (e.g., traveling), the scheduling layer triggers rescheduling upon app resume or startup, recalculating dates in the new timezone offset.

### Data Reset & Recovery Flow
The app is designed to support total local state resets from the User Profile screen:
1. **SharedPreferences Clearance**: Clears the key-value store, which deletes onboarding completion state, user profile metadata, and notification schedules.
2. **Hive Clearance**: Invokes `clear()` on the hydration logs local box to purge historical drink logs.
3. **Notification Purge**: Invokes `cancelAll()` on the platform notification manager to delete queued alarm instances.
4. **Onboarding Redirect**: Performs an animated routing redirect to `/onboarding`.

---

## Maintainer Guidelines

To keep the Raylynnia codebase robust, optimized, and compliant with production guidelines:
- **Zero Warnings**: Ensure `flutter analyze` runs with 0 errors and warnings. Replace any deprecated APIs (such as `withOpacity(x)` with `withValues(alpha: x)`).
- **Safe BuildContexts**: Avoid accessing `BuildContext` across asynchronous gaps without confirming `context.mounted`.
- **UI & Layout Integrity**: Do not adjust spacing, grid tokens, typography, or the custom HSL color palette unless requested explicitly.
- **Provider Refactoring**: Do not implement manual, ad-hoc state managers in the screens. Maintain the Riverpod provider boundaries and keep domain logic in the use cases and viewmodels.

---

## License

MIT License. See `LICENSE` for details.

---

## Contributing

This project is in architectural design phase. Contributions will be welcomed once the core structure is scaffolded. Please read `CONTRIBUTING.md` before opening a pull request.

---

*Raylynnia Hydration — Designed for people who forget to drink water. Built for their phone to remind them, intelligently.*

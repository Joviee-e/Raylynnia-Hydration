# FILE_STRUCTURE.md
## Raylynnia Hydration — Project File Structure

**Version:** 1.0.0
**Status:** Design Draft
**Last Updated:** April 2026

---

## Table of Contents

1. [Root Project Structure](#root-project-structure)
2. [lib/ Directory Deep Dive](#lib-directory-deep-dive)
3. [Folder Explanations](#folder-explanations)
4. [Feature Module Anatomy](#feature-module-anatomy)
5. [Naming Conventions](#naming-conventions)
6. [Separation of Concerns Summary](#separation-of-concerns-summary)

---

## Root Project Structure

```
raylynnia_hydration/
│
├── android/                        # Android platform project
├── ios/                            # iOS platform project
├── test/                           # All test files (mirrors lib/ structure)
│   ├── unit/
│   ├── widget/
│   └── integration/
├── assets/
│   ├── fonts/
│   ├── icons/
│   └── images/
├── docs/
│   ├── SYSTEM_ARCHITECTURE.md
│   ├── FILE_STRUCTURE.md
│   ├── JOURNAL.md
│   └── diagrams/
├── lib/
│   └── ...                         # See detailed breakdown below
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## lib/ Directory Deep Dive

```
lib/
│
├── main.dart                           # App entry point; initializes services & DI
├── app.dart                            # MaterialApp / root widget; theme & routing
│
├── core/                               # Shared infrastructure, cross-cutting concerns
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── timing_constants.dart
│   │   └── notification_constants.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── extensions/
│   │   ├── datetime_extensions.dart
│   │   └── string_extensions.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   ├── routing/
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   └── volume_formatter.dart
│   └── di/
│       └── injection_container.dart    # Dependency injection setup (GetIt or Riverpod)
│
├── domain/                             # Pure business logic — no Flutter imports
│   ├── entities/
│   │   ├── user_profile.dart
│   │   ├── hydration_log.dart
│   │   ├── daily_hydration_summary.dart
│   │   ├── reminder_schedule.dart
│   │   └── user_schedule_preferences.dart
│   ├── repositories/
│   │   ├── i_user_profile_repository.dart
│   │   ├── i_hydration_log_repository.dart
│   │   ├── i_notification_repository.dart
│   │   └── i_scheduling_repository.dart
│   ├── usecases/
│   │   ├── save_user_profile_usecase.dart
│   │   ├── get_user_profile_usecase.dart
│   │   ├── log_hydration_intake_usecase.dart
│   │   ├── get_daily_history_usecase.dart
│   │   ├── get_weekly_progress_usecase.dart
│   │   ├── compute_reminder_schedule_usecase.dart
│   │   ├── reschedule_all_notifications_usecase.dart
│   │   └── mark_onboarding_complete_usecase.dart
│   └── services/
│       └── scheduling_engine.dart      # Core scheduling algorithm (pure Dart)
│
├── data/                               # Concrete implementations of domain contracts
│   ├── models/                         # DTOs — data transfer objects with serialization
│   │   ├── user_profile_model.dart
│   │   ├── hydration_log_model.dart
│   │   ├── daily_hydration_summary_model.dart
│   │   └── user_schedule_preferences_model.dart
│   ├── mappers/                        # Convert between DTOs and domain entities
│   │   ├── user_profile_mapper.dart
│   │   ├── hydration_log_mapper.dart
│   │   └── schedule_preferences_mapper.dart
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── user_profile_local_datasource.dart
│   │   │   ├── hydration_log_local_datasource.dart
│   │   │   └── schedule_local_datasource.dart
│   │   └── interfaces/
│   │       ├── i_user_profile_datasource.dart
│   │       └── i_hydration_log_datasource.dart
│   ├── repositories/
│   │   ├── user_profile_repository_impl.dart
│   │   ├── hydration_log_repository_impl.dart
│   │   ├── notification_repository_impl.dart
│   │   └── scheduling_repository_impl.dart
│   └── services/
│       └── notification_manager.dart   # flutter_local_notifications wrapper
│
├── features/                           # Feature-scoped presentation code
│   ├── onboarding/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── welcome_screen.dart
│   │   │   │   ├── name_entry_screen.dart
│   │   │   │   ├── schedule_setup_screen.dart
│   │   │   │   └── goal_setup_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── onboarding_step_indicator.dart
│   │   │   │   └── time_picker_field.dart
│   │   │   └── viewmodels/
│   │   │       └── onboarding_viewmodel.dart
│   │   └── README.md
│   │
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── daily_progress_ring.dart
│   │   │   │   ├── log_drink_button.dart
│   │   │   │   └── next_reminder_chip.dart
│   │   │   └── viewmodels/
│   │   │       └── home_viewmodel.dart
│   │   └── README.md
│   │
│   ├── scheduling_engine/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── schedule_settings_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── interval_slider.dart
│   │   │   │   ├── sleep_window_picker.dart
│   │   │   │   └── schedule_preview_list.dart
│   │   │   └── viewmodels/
│   │   │       └── schedule_settings_viewmodel.dart
│   │   └── README.md
│   │
│   ├── user_profile/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── profile_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── goal_editor_card.dart
│   │   │   │   └── profile_header.dart
│   │   │   └── viewmodels/
│   │   │       └── profile_viewmodel.dart
│   │   └── README.md
│   │
│   └── history/
│       ├── presentation/
│       │   ├── screens/
│       │   │   └── history_screen.dart
│       │   ├── widgets/
│       │   │   ├── daily_log_tile.dart
│       │   │   └── weekly_bar_chart.dart
│       │   └── viewmodels/
│       │       └── history_viewmodel.dart
│       └── README.md
```

---

## Folder Explanations

### `core/`

**Purpose:** Cross-cutting concerns and shared infrastructure that do not belong to any single feature or layer.

| Subfolder | Contents |
|---|---|
| `constants/` | App-wide magic values — notification channel IDs, default intake volume, buffer window durations |
| `errors/` | Sealed failure classes and exception types used across layers for typed error handling |
| `extensions/` | Dart extension methods on primitives — `DateTime` day-of-week helpers, time formatting |
| `theme/` | Design system tokens — color palette, typography scale, component themes |
| `routing/` | Named route definitions and the root router configuration (GoRouter or auto_route) |
| `utils/` | Stateless helper functions — volume unit conversion, date range helpers |
| `di/` | Dependency injection wiring — all repository bindings, service registrations |

**Rule:** Nothing in `core/` should depend on a feature. Features may depend on `core/`.

---

### `domain/`

**Purpose:** The business heart of the application. Contains entities, repository contracts, and use cases in pure Dart. This folder has zero Flutter and zero third-party package dependencies.

| Subfolder | Contents |
|---|---|
| `entities/` | Immutable data objects representing core concepts: UserProfile, HydrationLog, etc. |
| `repositories/` | Abstract interfaces (contracts) defining what data operations the app requires |
| `usecases/` | Single-responsibility action classes; each represents one thing the user can do |
| `services/` | Domain-level algorithmic services (SchedulingEngine); complex logic that doesn't map to a single use case |

**Rule:** No `import 'package:flutter/...'`. No `import 'package:hive/...'`. If you need to add such an import, the code belongs in `data/` or `features/`, not here.

---

### `data/`

**Purpose:** Concrete implementation of the domain's repository interfaces. This is where third-party persistence and notification libraries are used.

| Subfolder | Contents |
|---|---|
| `models/` | DTOs with `fromJson`/`toJson` and Hive adapter annotations |
| `mappers/` | Pure functions that convert between domain entities and data models |
| `datasources/local/` | Direct read/write access to Hive boxes, SharedPreferences, etc. |
| `datasources/interfaces/` | Optional: abstract contracts for datasource-level mocking in tests |
| `repositories/` | Implements domain `I*Repository` interfaces, coordinates datasources |
| `services/` | Low-level service wrappers — NotificationManager wraps flutter_local_notifications |

**Rule:** Only `data/` knows about Hive, SharedPreferences, flutter_local_notifications, etc. Domain and Presentation must not import these packages directly.

---

### `features/`

**Purpose:** Vertical slices of the application, organized by user-facing capability. Each feature owns its own screens, widgets, and view models. Features are consumers of Domain use cases.

**Rule:** Features do not directly call repositories or datasources. They call use cases. Features do not know about each other (no cross-feature imports). Shared UI elements are promoted to `core/theme/` or a shared `widgets/` subfolder.

---

### `features/onboarding/`

The onboarding flow is a first-run experience, triggered when no `UserProfile` is found in local storage.

**Screens:**
- Welcome screen introducing the app.
- Name entry (personalizes the experience).
- Schedule setup (wake time, sleep time, weekday/weekend toggle).
- Goal setup (daily intake target).

**ViewModel responsibility:** Accumulate multi-step form data in memory, then dispatch a single `SaveUserProfileUseCase` call on final confirmation. Route to Home on completion.

---

### `features/scheduling_engine/`

This feature is the settings surface for the Scheduling Engine. It is not the engine itself (which lives in `domain/services/`), but the UI through which the user configures it.

**Key widget:** `schedule_preview_list.dart` — renders a live preview of computed notification times based on the user's current slider/picker values before they save. This is powered by calling `ComputeReminderScheduleUseCase` with in-progress (unsaved) values.

---

### `features/user_profile/`

Manages the user's name, hydration goal, and provides access to account-level actions (e.g., reset data). Unlike onboarding (which is a first-run wizard), the Profile screen is a persistent settings surface available from the main navigation.

---

## Naming Conventions

### Files
- All Dart files: `snake_case.dart`
- Screens: `<feature_name>_screen.dart` (e.g., `schedule_settings_screen.dart`)
- Widgets: descriptive noun phrase (e.g., `daily_progress_ring.dart`)
- ViewModels: `<feature>_viewmodel.dart`
- Use cases: `<verb>_<noun>_usecase.dart` (e.g., `log_hydration_intake_usecase.dart`)
- Repositories (interfaces): `i_<noun>_repository.dart`
- Repositories (implementations): `<noun>_repository_impl.dart`
- Data models: `<noun>_model.dart`
- Mappers: `<noun>_mapper.dart`

### Classes
- Entities: `PascalCase` nouns (e.g., `UserProfile`, `HydrationLog`)
- Use cases: `PascalCase` verb phrases (e.g., `LogHydrationIntakeUseCase`)
- Repository interfaces: `I` prefix + `PascalCase` (e.g., `IHydrationLogRepository`)
- Implementations: suffix `Impl` (e.g., `HydrationLogRepositoryImpl`)
- ViewModels: suffix `ViewModel` (e.g., `HomeViewModel`)
- Models/DTOs: suffix `Model` (e.g., `HydrationLogModel`)

### Constants
- Top-level constants: `camelCase` inside a sealed class or `abstract class` namespace.
- Example: `NotificationConstants.hydrationChannelId`

---

## Separation of Concerns Summary

| Concern | Location |
|---|---|
| Business rules | `domain/usecases/` + `domain/services/` |
| Data structures | `domain/entities/` |
| Data contracts | `domain/repositories/` |
| Persistence | `data/datasources/local/` |
| Serialization | `data/models/` + `data/mappers/` |
| Notification platform | `data/services/notification_manager.dart` |
| UI state | `features/<feature>/presentation/viewmodels/` |
| UI rendering | `features/<feature>/presentation/screens/` + `widgets/` |
| Design tokens | `core/theme/` |
| Navigation | `core/routing/` |
| DI wiring | `core/di/injection_container.dart` |
| Cross-layer utilities | `core/utils/` + `core/extensions/` |
| Typed errors | `core/errors/` |

---

*End of FILE_STRUCTURE.md*

# SYSTEM_ARCHITECTURE.md
## Raylynnia Hydration — System Architecture

**Version:** 1.0.0
**Status:** Design Draft
**Author:** Architecture Team
**Last Updated:** April 2026

---

## Table of Contents

1. [Overview](#overview)
2. [High-Level Architecture](#high-level-architecture)
3. [Layered Design](#layered-design)
4. [Component Breakdown](#component-breakdown)
5. [Data Flow](#data-flow)
6. [Key Design Decisions](#key-design-decisions)
7. [Scalability Considerations](#scalability-considerations)

---

## Overview

Raylynnia Hydration is a fully offline, Flutter-based mobile application that delivers adaptive hydration reminders to users based on their personal schedule, sleep windows, and weekday/weekend behavior patterns. The system is designed around the principle of local-first data ownership — no network dependency, no cloud sync, no external authentication.

The architecture follows a strict **Clean Architecture** pattern with three principal layers: Presentation, Domain, and Data. Inter-layer communication is enforced through abstractions (abstract classes / interfaces), ensuring each layer can be developed, tested, and replaced in isolation.

---

## High-Level Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                      │
│   Screens · Widgets · ViewModels (Riverpod/Bloc)               │
│   - Renders UI based on state                                  │
│   - Captures user intent, dispatches to domain                 │
└────────────────────┬───────────────────────────────────────────┘
                     │  Uses Cases / Commands
┌────────────────────▼───────────────────────────────────────────┐
│                         DOMAIN LAYER                           │
│   Entities · Use Cases · Repository Interfaces                 │
│   - Pure Dart: no Flutter, no external packages                │
│   - Expresses business rules only                              │
└────────────────────┬───────────────────────────────────────────┘
                     │  Repository Contracts
┌────────────────────▼───────────────────────────────────────────┐
│                          DATA LAYER                            │
│   Repository Implementations · Local Data Sources             │
│   - Hive / Isar / SharedPreferences                           │
│   - Notification Service (flutter_local_notifications)        │
│   - Platform Adapters                                          │
└────────────────────────────────────────────────────────────────┘
```

---

## Layered Design

### Presentation Layer

**Responsibility:** Render application state as UI; translate user gestures and inputs into domain commands.

**Key Constituents:**
- **Screens** — Full-page views corresponding to each feature (Onboarding, Home, Settings, History, Profile).
- **Widgets** — Reusable UI components scoped to individual features or shared across the app.
- **ViewModels / Notifiers** — State holders that own UI-level state. They call into Domain use cases and expose streams or state objects back to the UI. No business logic lives here.
- **State Management** — Riverpod is the recommended choice for its compile-time safety and testability; a Bloc/Cubit approach is an equally valid alternative.

**Rule:** The Presentation layer must never directly access a repository or a local database. All data access goes through the Domain layer.

---

### Domain Layer

**Responsibility:** Express the app's business rules in pure, framework-agnostic Dart. This layer is the heart of the application and must remain independent of Flutter, any state management library, and any persistence mechanism.

**Key Constituents:**

- **Entities**
  - `UserProfile` — Name, preferred daily intake goal, onboarding completion flag, timezone offset.
  - `HydrationLog` — A single drink event: timestamp, volume in ml.
  - `DailyHydrationSummary` — Aggregated intake for a calendar day.
  - `ReminderSchedule` — Computed set of notification times for a given day type.
  - `UserSchedulePreferences` — Wake time, sleep time, weekday/weekend overrides, reminder interval.

- **Repository Interfaces (Contracts)**
  - `IUserProfileRepository` — Read/write user profile and preferences.
  - `IHydrationLogRepository` — Append, query, and delete hydration log entries.
  - `INotificationRepository` — Schedule, cancel, and list pending notifications.
  - `ISchedulingRepository` — Persist and retrieve computed schedules.

- **Use Cases** (one class per action, single `execute()` method)
  - `SaveUserProfileUseCase`
  - `GetUserProfileUseCase`
  - `LogHydrationIntakeUseCase`
  - `GetDailyHistoryUseCase`
  - `ComputeReminderScheduleUseCase`
  - `RescheduleAllNotificationsUseCase`
  - `MarkOnboardingCompleteUseCase`
  - `GetWeeklyProgressUseCase`

- **Domain Services**
  - `SchedulingEngine` — Core algorithm logic. See Component Breakdown below.

**Rule:** No `import 'package:flutter/...'`. No `import 'package:hive/...'`. Pure Dart only.

---

### Data Layer

**Responsibility:** Implement the repository contracts defined in the Domain layer using concrete persistence and notification technologies.

**Key Constituents:**

- **Local Data Sources**
  - `UserProfileLocalDataSource` — Backed by `SharedPreferences` for lightweight key-value profile storage.
  - `HydrationLogLocalDataSource` — Backed by Hive or Isar for structured, indexed, fast local queries on time-series log data.
  - `ScheduleLocalDataSource` — Persists computed schedule objects as JSON or Hive boxes.

- **Repository Implementations**
  - `UserProfileRepositoryImpl implements IUserProfileRepository`
  - `HydrationLogRepositoryImpl implements IHydrationLogRepository`
  - `NotificationRepositoryImpl implements INotificationRepository`
  - `SchedulingRepositoryImpl implements ISchedulingRepository`

- **Notification Service**
  - Wraps `flutter_local_notifications` behind the `INotificationRepository` contract.
  - Handles platform channel configuration (Android channel setup, iOS permission requests).
  - Maintains a notification ID registry to allow targeted cancellation.

- **Data Models (DTOs)**
  - Mirror domain entities but include serialization (`fromJson` / `toJson`, Hive adapters).
  - Mappers convert between DTOs and domain entities at the repository boundary.

---

## Component Breakdown

### 1. Scheduling Engine

**Location:** `lib/domain/services/scheduling_engine.dart`

**Role:** Computes the full ordered list of reminder times for a given day, based on user preferences. This is the most intellectually complex component in the system.

**Inputs:**
- User's wake time
- User's sleep time
- Day type: weekday or weekend
- Preferred reminder interval (minutes)
- Any manual overrides

**Algorithm (conceptual):**
1. Determine the active hydration window: `[wakeTime + bufferMinutes, sleepTime - bufferMinutes]`.
2. Select the interval appropriate for the day type (weekday vs. weekend may differ).
3. Distribute reminder slots evenly across the window using the interval.
4. Truncate any slots that fall outside the window boundary.
5. Apply any user-defined skip windows (e.g., "no reminders during 1pm–3pm on weekends").
6. Return an ordered `List<DateTime>` representing absolute reminder times for the next occurrence of that day type.

**Key invariants:**
- No reminder is scheduled before wake time + configurable buffer (default: 30 min).
- No reminder is scheduled after sleep time - configurable buffer (default: 30 min).
- Minimum one reminder per active window, regardless of interval setting.
- Weekend and weekday schedules are computed and stored independently.

**Recalculation triggers:**
- User saves updated preferences.
- App foregrounds after midnight (day boundary crossed).
- App completes first-launch onboarding.

---

### 2. Notification Manager

**Location:** `lib/data/services/notification_manager.dart`

**Role:** Bridge between the domain's scheduling intent and the platform's local notification APIs.

**Responsibilities:**
- Initialize `flutter_local_notifications` on app start, including Android channel creation and iOS permission requests.
- Accept a `ReminderSchedule` (list of `DateTime` + message content) and translate each entry into a scheduled local notification.
- Cancel all pending notifications before rescheduling (full replacement strategy) to prevent stale or duplicate alerts.
- Persist the active notification ID set so that targeted cancellation is possible.
- Handle the case where the notification permission has been revoked (graceful degradation).

**Notification payload:** Each notification carries a lightweight JSON payload:
```
{ "type": "hydration_reminder", "scheduledAt": "<ISO8601>" }
```
This allows the app to respond intelligently when a notification is tapped (e.g., open the logging screen).

**Platform considerations:**
- Android: Exact alarm permission (`SCHEDULE_EXACT_ALARM`) may be required on Android 12+. A graceful fallback to inexact alarms should be documented.
- iOS: Notifications are limited to 64 pending at once. The engine must cap its schedule accordingly.

---

### 3. User Profile Manager

**Location:** `lib/domain/usecases/` (use cases) + `lib/data/repositories/user_profile_repository_impl.dart`

**Role:** Manages the lifecycle of user identity and preferences within the app.

**Responsibilities:**
- Detect first launch (onboarding flag absent from local store).
- Persist and retrieve the `UserProfile` entity.
- Persist and retrieve `UserSchedulePreferences`.
- Expose a reactive stream of current preferences so that the Scheduling Engine and UI can reactively respond to preference changes without polling.

**Onboarding detection logic:**
- On app start, the `GetUserProfileUseCase` is invoked.
- If it returns `null` (no profile stored), the app routes to the Onboarding flow.
- If a profile exists, the app routes to the Home screen.
- Onboarding completion writes the profile and triggers `RescheduleAllNotificationsUseCase`.

---

## Data Flow

### Flow 1: App Launch

```
App Start
  → Check onboarding flag (UserProfileRepository)
      → No profile found → Route to Onboarding
      → Profile found    → Route to Home
                           → Load today's summary (HydrationLogRepository)
                           → Validate/refresh today's notification schedule
```

### Flow 2: User Logs a Drink

```
User taps "Log Drink" on Home Screen
  → LogHydrationIntakeUseCase.execute(volume, timestamp)
      → HydrationLogRepository.appendEntry(log)
          → HydrationLogLocalDataSource.insert(dto)
  → UI state updates via ViewModel stream
  → DailyProgress widget reflects updated total
```

### Flow 3: Preferences Changed

```
User saves new schedule preferences in Settings
  → SaveUserProfileUseCase.execute(updatedPreferences)
      → UserProfileRepository.savePreferences(prefs)
  → RescheduleAllNotificationsUseCase.execute()
      → ComputeReminderScheduleUseCase.execute() [weekday]
      → ComputeReminderScheduleUseCase.execute() [weekend]
      → NotificationRepository.cancelAll()
      → NotificationRepository.scheduleAll(weekdaySchedule + weekendSchedule)
```

### Flow 4: Notification Tapped

```
User taps a hydration reminder notification
  → Platform delivers payload to app
  → NotificationResponseHandler routes based on payload "type"
      → Navigates to Home / Log screen
```

---

## Key Design Decisions

### Decision 1: Clean Architecture over Feature-First Flat Structure
A strict layered Clean Architecture was chosen over a simpler flat structure because the Scheduling Engine logic is complex enough to warrant pure unit testing in isolation. The Domain layer can be tested with zero Flutter dependency, making the test suite fast and stable.

**Trade-off:** Higher initial boilerplate (interfaces, mappers, DTOs) in exchange for long-term maintainability and testability.

### Decision 2: Local-Only Storage
All data remains on the device. No backend, no authentication, no analytics. This simplifies the architecture significantly, eliminates privacy concerns, reduces attack surface, and makes the app work seamlessly in airplane mode.

**Trade-off:** No cross-device sync. Backup/restore must be handled via export functionality if needed in the future.

### Decision 3: Full Schedule Replacement on Preference Change
When the user changes their schedule, all pending notifications are cancelled and the full set is rescheduled from scratch. This is simpler and more correct than trying to diff the old and new schedules.

**Trade-off:** Slightly higher CPU cost on save. Acceptable given the infrequency of preference changes.

### Decision 4: SchedulingEngine as a Pure Domain Service
The interval calculation and time distribution logic lives entirely in the Domain layer with no platform imports. It operates on plain `DateTime` objects and returns plain data structures. This makes it the most testable component in the system.

### Decision 5: Riverpod for State Management
Riverpod was selected over BLoC for its compile-time safety, simpler provider composition, and native support for async data loading with `AsyncValue`. It does not require `BuildContext` to read state, which aligns well with the MVVM pattern.

**Trade-off:** Riverpod has a steeper learning curve than Provider; the team must maintain discipline around provider scoping.

---

## Scalability Considerations

While Raylynnia Hydration is intentionally minimal, the architecture anticipates the following growth vectors:

| Concern | Current Design | Future Path |
|---|---|---|
| Multiple reminder types | Single hydration type | Add `ReminderType` enum to entities; engine emits typed schedules |
| Wearable integration | Not applicable | Add a `WearableRepository` contract in domain; implement via WearOS/WatchKit SDK in data layer |
| Cloud backup | Not applicable | Add `ICloudSyncRepository`; implement with Firebase or custom backend without touching domain logic |
| Multi-user / family mode | Single profile | Extend `UserProfileRepository` to manage a list of profiles indexed by ID |
| Localization | Single language | UI strings are already separated from logic; add `l10n` package without architectural change |
| Analytics / telemetry | None | A `IAnalyticsRepository` contract can be injected; domain use cases emit events; data layer sends to desired provider |

The layered architecture ensures that none of these extensions require changes to the Domain layer — only new repository contracts and data-layer implementations.

---

*End of SYSTEM_ARCHITECTURE.md*

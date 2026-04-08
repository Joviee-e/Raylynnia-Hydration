# JOURNAL.md
## Raylynnia Hydration — Development Journal

**Format:** Structured design journal, organized by development phase.
**Tone:** Technical and reflective.
**Purpose:** Capture design intent, trade-offs, and lessons for future contributors and for retrospective review.

---

> *"Good architecture is not found, it is decided. This journal is a record of those decisions."*

---

## Phase 0 — Project Conception & Scoping

**Date:** Pre-development
**Status:** Complete

### Goal

Define what this app is, and — just as importantly — what it is not. Establish the philosophical guardrails before writing a single line of code or naming a single file.

### Design Decisions

The name "Raylynnia" was chosen as a unique identifier that carries no functional baggage. It doesn't pre-constrain the brand to a single metaphor (no "drops" or "waves" in the name), leaving visual language open for design exploration.

The decision to make the app **fully local** was not a technical concession — it was a values decision. Hydration data is personal health data. A user should not need to create an account, expose an email address, or trust a server to be reminded to drink water. The architecture reflects this: the entire domain layer has no concept of a network, and this is enforced structurally, not just by convention.

The adaptive scheduler concept emerged from a real pain point: most reminder apps treat every day identically. A person's Monday 9am is not the same as their Sunday 9am. The system was scoped to support two day-type profiles (weekday / weekend) as the minimum viable differentiator, with the architecture designed to support further differentiation (e.g., per-day overrides) without structural change.

### Trade-offs

Choosing **local-only storage** means there is no cross-device sync story. This was accepted as a deliberate constraint. Users who switch phones lose their history unless an explicit export/import flow is built. This is a known gap, documented in Future Scope. The purity of the offline architecture is worth this trade-off for the initial version.

### Challenges

The conceptual challenge in scoping was avoiding feature creep during the design phase. The instinct to add step counting, water type tracking, or integration with Apple Health was present early. These were deferred deliberately. A focused app that does one thing excellently is more valuable than a broad app that does many things tolerably.

### Future Improvements

Revisit scope after an initial user cohort validates the core loop. If users consistently request streak tracking or Apple Health sync, those should be the first additions — not arbitrary enhancements.

---

## Phase 1 — Domain Layer Design

**Date:** Architecture Phase
**Status:** Complete (design)

### Goal

Design the domain layer in isolation: define the entities that model the problem, the repository contracts that define what data the system needs, and the use cases that express every meaningful action a user can take.

### Design Decisions

**Entities were designed as immutable value objects.** `UserProfile`, `HydrationLog`, and `ReminderSchedule` carry no methods beyond simple accessors and a `copyWith` pattern. This keeps them easy to reason about, serialize, and test. Business logic is kept in use cases and the scheduling engine — not in the entities themselves.

**Use cases follow a strict single-responsibility pattern.** Each use case is a class with a single public method (`execute`). This makes the system's capabilities scannable — the full list of use cases in `domain/usecases/` is a readable spec of what the app can do. It also makes mocking trivial in tests.

**The SchedulingEngine was separated from the use case layer.** It is a domain service rather than a use case because it encapsulates a non-trivial algorithm that multiple use cases may call. It has no concept of persistence or notification — it purely transforms preferences into a list of times. This is intentional. The algorithm can change without affecting the use case layer, as long as its input/output contract remains stable.

**Repository contracts were defined from the domain outward.** Rather than designing the database schema first and working upward, the repository interfaces were designed by asking: "What does the domain need to know?" and "What does the domain need to store?" The data layer was then shaped to answer those questions. This keeps the domain clean of any persistence bias.

### Trade-offs

The use-case-per-class approach creates more files than a simpler service-class approach. A `HydrationService` with five methods would be fewer files. The cost is that single-responsibility suffers — a service class tends to accumulate methods and dependencies over time, becoming a hidden orchestration layer. The use case pattern prevents this by design.

Keeping `UserSchedulePreferences` as a separate entity from `UserProfile` adds a join at the ViewModel layer (the ViewModel must load both and compose them for the UI). This was preferred over embedding preferences inside the profile, because preferences are changed frequently and independently — they should have a distinct save lifecycle.

### Challenges

The hardest conceptual challenge in this phase was defining the boundary between a use case and a domain service. The rule adopted: if the logic is purely computational (input → output, no side effects, no I/O), it belongs in a domain service. If it involves reading from or writing to a repository, it is a use case.

Defining the `ReminderSchedule` entity took several iterations. The initial design stored a flat list of `DateTime` values. The revised design stores the schedule as a typed object carrying its `dayType`, `generatedAt` timestamp, and the list of times — making it self-describing and auditable. This proved valuable when designing the "schedule preview" UI feature, which needed to display schedule metadata alongside the times.

### Future Improvements

Consider adding a `ValidateSchedulePreferencesUseCase` that checks inputs for logical inconsistencies (e.g., wake time after sleep time, interval longer than the active window) and returns typed validation errors. Currently this validation is handled implicitly by the SchedulingEngine, which silently clamps invalid inputs. Explicit validation with user-facing error messages would improve the Settings UX.

---

## Phase 2 — Data Layer Design

**Date:** Architecture Phase
**Status:** Complete (design)

### Goal

Implement concrete persistence behind each domain repository interface. Select storage technologies appropriate to each data type and access pattern.

### Design Decisions

**Two storage technologies were selected intentionally.** `SharedPreferences` handles the user profile and preferences — small, key-value data that is written infrequently and read on every app launch. Hive handles hydration log entries — structured, append-heavy, time-indexed records that grow over time and must be queryable by date range.

This is not over-engineering. Using Hive for user preferences would add adapter generation overhead for no query benefit. Using SharedPreferences for log entries would be fragile and slow for date-range queries. The right tool for each job.

**The Mapper pattern is used at every repository boundary.** Data models (DTOs) are never returned by repository implementations — they are always mapped to domain entities before being returned. This ensures the domain layer remains insulated from serialization details. If the storage format changes, only the mapper and model change; the domain entity is untouched.

**The NotificationManager uses a full-replacement strategy.** When `RescheduleAllNotificationsUseCase` is called, the NotificationManager cancels all pending notifications before scheduling the new set. A diff-based update (cancel only changed slots, add only new slots) would be faster but significantly more complex to implement correctly. Given that preference changes are infrequent (typically a handful of times over the app's lifetime), the full-replacement cost is negligible.

**iOS 64-notification limit is handled at the data layer.** The domain's SchedulingEngine may theoretically produce more than 64 notification slots over a multi-week horizon. The NotificationManager is responsible for truncating the schedule to the platform limit (64 for iOS, effectively unlimited for Android). This constraint does not pollute the domain logic. The domain expresses intent; the data layer enforces platform reality.

### Trade-offs

Using Hive over Isar was a pragmatic choice — Hive is more widely documented and the project team has existing familiarity with it. Isar offers better query performance and more type-safe queries for complex schemas. This decision should be revisited if log volume or query complexity grows (e.g., if the future roadmap adds nutritional tracking with compound queries). The repository interface abstraction means a migration from Hive to Isar would not require any domain changes.

The `notification_id_registry.dart` (a small local registry mapping scheduled times to notification IDs) adds a coordination responsibility to the data layer. This is necessary to enable targeted cancellation (e.g., "cancel the 2pm reminder only") without scanning all pending notifications. If the registry gets out of sync with the actual platform state (e.g., after a system reboot), the full-replacement strategy on reschedule ensures correctness is restored.

### Challenges

The most operationally complex part of this phase was reasoning about notification state across app lifecycle events. Notifications persist across app restarts, but the app's in-memory state does not. After a cold start, the app must reconcile what it intends to have scheduled with what the platform actually has pending.

The design decision was to treat app foreground events (specifically, the first foreground event after midnight) as a reschedule trigger. This keeps the notification state fresh without requiring a background service.

### Future Improvements

Introduce a `DataMigration` layer as part of the data module setup. As the app evolves and Hive adapters change, a structured migration path (version N → version N+1) will prevent data corruption on app update. This is not needed for v1 but should be built before any schema-changing feature is shipped.

---

## Phase 3 — Scheduling Engine Design

**Date:** Architecture Phase
**Status:** Complete (design)

### Goal

Design the core algorithm that is the intellectual centerpiece of the product: given a user's wake time, sleep time, day type, and interval preference, produce the correct ordered list of reminder times.

### Design Decisions

**The algorithm was kept purely functional.** Given the same inputs, the SchedulingEngine always returns the same output. There are no random elements, no time-of-day checks inside the engine (the caller is responsible for providing the correct day type), and no side effects. This makes the engine trivially testable — a test is simply: "given these inputs, assert these outputs."

**Configurable buffers are first-class inputs.** The engine does not hardcode "don't remind within 30 minutes of wake time." That buffer is a constant defined in `core/constants/timing_constants.dart` and passed into the engine. This means the buffer can be made user-configurable in a future version without touching the algorithm.

**Edge cases were identified and handled explicitly:**
- Wake time and sleep time on the same clock hour: minimum one reminder is generated at the midpoint.
- Interval longer than the active window: a single reminder is placed at the midpoint of the window.
- Sleep time is past midnight (e.g., 1am): the engine normalizes times to a 24-hour offset from wake time to handle overnight windows correctly.
- Weekend wake time significantly later than weekday: treated as a fully independent schedule computation, not a delta from the weekday schedule.

**The "schedule preview" feature informed the engine's API.** During design of the `schedule_preview_list.dart` widget, it became clear that the engine needed to be callable with unsaved, in-progress preference values — not just the persisted values. This drove the decision to make `ComputeReminderScheduleUseCase` accept parameters directly rather than reading from the repository internally. The ViewModel passes the current form state into the use case; the use case passes it to the engine. The user sees a live preview that matches what will actually be scheduled.

### Trade-offs

The engine computes an absolute `List<DateTime>` for a given day, rather than returning a relative `List<Duration>` from wake time. Absolute times are more directly usable for notification scheduling but must be recomputed each day (since the base date changes). A duration-based representation would be more compact to store but would require date-anchoring at notification scheduling time, adding complexity there.

The chosen approach (absolute times, recomputed daily) was preferred for its simplicity. The recomputation cost is trivial.

### Challenges

Reasoning about time zones was a latent challenge. The SchedulingEngine operates on `DateTime` objects, which in Dart can be UTC or local. The decision: all user-facing time preferences (wake, sleep) are stored as local time (hour:minute, no date) and resolved to the current device's local `DateTime` at schedule computation time. The app does not attempt to follow the user across time zones automatically (a future scope item). If a user travels to a new timezone, they are expected to update their preferences.

### Future Improvements

Add a "quiet period" concept — a user-defined time range within the active window where no reminders fire (e.g., "no reminders during my lunch break from 12pm–1pm"). The engine's slot-distribution algorithm should be extended to exclude these windows before distributing. The entity and preference model should be updated to include a `List<QuietPeriod>` field.

---

## Phase 4 — Onboarding Flow Design

**Date:** Architecture Phase
**Status:** In Design

### Goal

Design a first-run experience that collects the minimum information needed to produce a personalized, immediately useful reminder schedule — without overwhelming the user or requiring a long setup process.

### Design Decisions

**Multi-step wizard, single save.** All onboarding inputs are accumulated in the `OnboardingViewModel`'s in-memory state as the user moves through steps. A single `SaveUserProfileUseCase` call fires on the final step. This avoids partial saves and keeps the domain transaction atomic.

**Progressive disclosure.** The schedule setup step shows a live preview of the reminder times that will be scheduled, powered by the SchedulingEngine. This gives the user immediate feedback and makes the abstract concept of "adaptive scheduling" tangible before they complete setup.

**Onboarding is not re-entrant.** Once the onboarding flag is set, re-navigating to the onboarding flow from outside the app's normal settings path is not supported. Preference changes post-onboarding flow through the Settings screens. This simplifies state management.

### Trade-offs

Showing a schedule preview during onboarding requires calling `ComputeReminderScheduleUseCase` with unsaved values, which adds ViewModel complexity. The alternative (previewing after save) would feel abrupt and remove the user's ability to adjust before committing. The UX benefit justifies the added ViewModel state.

### Challenges

Deciding when to ask for notification permission is a UX challenge as much as a technical one. Asking before the user understands the app's value (first screen) leads to denial. Asking after onboarding is complete is technically simpler but may feel like a second "onboarding." The adopted design: notification permission is requested on the final onboarding confirmation screen, framed as: "Ready to start your reminders?" The context makes the permission request meaningful.

### Future Improvements

Provide an "edit schedule" shortcut from the Home screen header for users who want to quickly adjust their wake time without navigating to full settings. The onboarding schedule setup widget can be reused as a bottom sheet for this purpose.

---

## Phase 5 — Notification System Integration

**Date:** Architecture Phase
**Status:** In Design

### Goal

Ensure that the right notifications fire at the right times, survive app restarts, handle permission edge cases gracefully, and integrate cleanly with the scheduling engine's output.

### Design Decisions

**The notification ID strategy must be deterministic.** Notification IDs are integers in `flutter_local_notifications`. Rather than generating random IDs, the NotificationManager computes a deterministic ID from the notification's scheduled time (e.g., a hash of the date + slot index). This makes the registry reconstructable from the schedule alone, providing a recovery path if the registry is lost.

**Tapped notification routing.** When a notification is tapped, the app opens to the Home screen with a contextual state that prompts the user to log a drink. This is implemented by embedding the notification type in the payload and handling it in the `NotificationResponseHandler` class, which is initialized in `main.dart`.

**Graceful degradation.** If notification permission is revoked after onboarding, the app detects this on foreground and displays a non-intrusive banner prompting the user to re-enable notifications. The core app (logging, history) continues to function normally.

### Trade-offs

Exact alarms on Android 12+ require the `SCHEDULE_EXACT_ALARM` permission, which users must explicitly grant in system settings. The app targets inexact alarms as the default (which do not require special permission) and only requests exact alarm access as an opt-in for users who want precise reminder timing. This is a UX simplification with a minor accuracy trade-off.

### Challenges

The 64-notification iOS limit is the most operationally significant platform constraint. With a 4-week horizon and up to 12 reminders per day, the app could generate 336 notification entries. The NotificationManager must prioritize the nearest 64 slots. The scheduling window is therefore practically limited to ~5 days on iOS. This is acceptable for a daily-use app — notifications are rescheduled on each app foreground event, keeping the window rolling.

### Future Improvements

Investigate `background_fetch` or iOS Background App Refresh as a mechanism to reschedule notifications even when the user hasn't opened the app for several days. This would extend the effective notification horizon beyond the current foreground-triggered reschedule model.

---

## Phase 6 — Reflection & Architectural Retrospective

**Date:** Post-Design Review
**Status:** Ongoing

### What Worked Well

The strictness of the Clean Architecture layering paid dividends during design. When deciding where a new concept should live, the rules were clear enough to answer the question definitively rather than debating it. The domain layer has no ambiguous code.

The SchedulingEngine as a pure domain service was the right call. During design of the settings preview feature, the team realized the engine needed to be called with transient (unsaved) values. Because it was a pure function from the start, this required no refactoring — only the ViewModel needed updating.

Designing repository interfaces before implementations prevented database-schema-driven thinking from infecting the domain model. The `HydrationLog` entity does not have a `hiveKey` field. This discipline was maintained because the interface was written first.

### What Could Be Improved

The mapper layer adds ceremony. For simple entities, converting a `HydrationLogModel` to a `HydrationLog` and back feels like boilerplate without clear benefit at small scale. At larger scale (more fields, nested objects, versioning), mappers earn their existence. For v1, a lighter approach (using Hive's `TypeAdapter` to serialize domain entities directly) would have reduced file count. The mapper pattern was retained for the architectural discipline it enforces.

The `core/di/injection_container.dart` will become a long file as the app grows. A modular DI approach (each feature registers its own providers) should be adopted before the list of registrations becomes unmanageable.

### Enduring Principles for Future Contributors

1. **The Domain layer is sacred.** If a PR adds a Flutter or third-party import to any file in `domain/`, that is a blocking review issue.
2. **New capabilities = new use case.** Resist the temptation to add a method to an existing use case class. Add a new class.
3. **Mappers own the conversion.** Data models and domain entities are never cast to each other. Mappers are the only place where the conversion is expressed.
4. **Recalculate, don't mutate.** When user preferences change, recompute the full schedule rather than patching the existing one. Correctness over cleverness.
5. **Test the engine, not the platform.** The SchedulingEngine must have comprehensive unit test coverage. Notification delivery is a platform concern and should be integration-tested minimally via mock interfaces, not via real platform notification APIs in unit tests.

---

*End of JOURNAL.md*

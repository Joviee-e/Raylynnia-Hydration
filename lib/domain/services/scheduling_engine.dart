import '../entities/user_schedule_preferences.dart';

class SchedulingEngine {
  const SchedulingEngine();

  // Phase 2 skeleton only. Full scheduling algorithm is intentionally deferred.
  List<DateTime> computeReminderTimes({
    required DateTime dayAnchor,
    required UserSchedulePreferences preferences,
    required bool isWeekend,
  }) {
    return <DateTime>[];
  }
}

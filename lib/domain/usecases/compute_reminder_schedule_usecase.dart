import '../entities/reminder_schedule.dart';
import '../entities/user_schedule_preferences.dart';
import '../services/scheduling_engine.dart';

class ComputeReminderScheduleUseCase {
  const ComputeReminderScheduleUseCase(this._schedulingEngine);

  final SchedulingEngine _schedulingEngine;

  ReminderSchedule execute({
    required DateTime dayAnchor,
    required UserSchedulePreferences preferences,
    required bool isWeekend,
  }) {
    final List<DateTime> times = _schedulingEngine.computeReminderTimes(
      dayAnchor: dayAnchor,
      preferences: preferences,
      isWeekend: isWeekend,
    );

    return ReminderSchedule(
      isWeekend: isWeekend,
      generatedAt: DateTime.now(),
      times: times,
    );
  }
}

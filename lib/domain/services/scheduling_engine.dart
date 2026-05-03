import '../entities/user_schedule_preferences.dart';
import '../../core/constants/timing_constants.dart';

class SchedulingEngine {
  const SchedulingEngine();

  List<DateTime> computeReminderTimes({
    required DateTime dayAnchor,
    required UserSchedulePreferences preferences,
    required bool isWeekend,
  }) {
    final Duration wakeTime =
        isWeekend ? preferences.weekendWakeTime : preferences.weekdayWakeTime;
    final Duration sleepTime =
        isWeekend ? preferences.weekendSleepTime : preferences.weekdaySleepTime;

    final int wakeMinutes = wakeTime.inMinutes;
    int sleepMinutes = sleepTime.inMinutes;
    if (sleepMinutes <= wakeMinutes) {
      sleepMinutes += Duration.minutesPerDay;
    }

    int startMinutes = wakeMinutes + TimingConstants.wakeBuffer.inMinutes;
    int endMinutes = sleepMinutes - TimingConstants.sleepBuffer.inMinutes;

    if (endMinutes <= startMinutes) {
      final int midpoint = wakeMinutes + ((sleepMinutes - wakeMinutes) ~/ 2);
      return <DateTime>[
        _anchorFromMinutes(dayAnchor, midpoint),
      ];
    }

    final int intervalMinutes = preferences.reminderIntervalMinutes <
            TimingConstants.minimumIntervalMinutes
        ? TimingConstants.minimumIntervalMinutes
        : preferences.reminderIntervalMinutes;

    final int windowMinutes = endMinutes - startMinutes;
    if (intervalMinutes > windowMinutes) {
      final int midpoint = startMinutes + (windowMinutes ~/ 2);
      return <DateTime>[
        _anchorFromMinutes(dayAnchor, midpoint),
      ];
    }

    final List<DateTime> result = <DateTime>[];
    for (int cursor = startMinutes; cursor <= endMinutes; cursor += intervalMinutes) {
      result.add(_anchorFromMinutes(dayAnchor, cursor));
    }

    if (result.isEmpty) {
      final int midpoint = startMinutes + (windowMinutes ~/ 2);
      result.add(_anchorFromMinutes(dayAnchor, midpoint));
    }

    return result;
  }

  DateTime _anchorFromMinutes(DateTime dayAnchor, int absoluteMinutes) {
    final int dayOffset = absoluteMinutes ~/ Duration.minutesPerDay;
    final int minuteOfDay = absoluteMinutes % Duration.minutesPerDay;
    final int hour = minuteOfDay ~/ Duration.minutesPerHour;
    final int minute = minuteOfDay % Duration.minutesPerHour;

    return DateTime(
      dayAnchor.year,
      dayAnchor.month,
      dayAnchor.day + dayOffset,
      hour,
      minute,
    );
  }
}

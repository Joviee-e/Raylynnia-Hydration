import 'package:flutter_test/flutter_test.dart';
import 'package:raylynnia_hydration/domain/entities/user_schedule_preferences.dart';
import 'package:raylynnia_hydration/domain/services/scheduling_engine.dart';

void main() {
  group('SchedulingEngine', () {
    const SchedulingEngine engine = SchedulingEngine();
    const UserSchedulePreferences preferences = UserSchedulePreferences(
      weekdayWakeTime: Duration(hours: 7),
      weekdaySleepTime: Duration(hours: 22),
      weekendWakeTime: Duration(hours: 9),
      weekendSleepTime: Duration(hours: 1),
      reminderIntervalMinutes: 120,
    );

    test('computes weekday reminders within buffered window', () {
      final DateTime anchor = DateTime(2026, 5, 4);
      final List<DateTime> result = engine.computeReminderTimes(
        dayAnchor: anchor,
        preferences: preferences,
        isWeekend: false,
      );

      expect(result.isNotEmpty, isTrue);
      expect(result.first.hour, 7);
      expect(result.first.minute, 30);
      expect(result.last.isBefore(DateTime(2026, 5, 4, 21, 31)), isTrue);
    });

    test('handles overnight weekend schedule', () {
      final DateTime anchor = DateTime(2026, 5, 3);
      final List<DateTime> result = engine.computeReminderTimes(
        dayAnchor: anchor,
        preferences: preferences,
        isWeekend: true,
      );

      expect(result.isNotEmpty, isTrue);
      expect(result.first, DateTime(2026, 5, 3, 9, 30));
      expect(result.last.day, anyOf(3, 4));
    });

    test('returns midpoint when interval exceeds active window', () {
      const UserSchedulePreferences tinyWindow = UserSchedulePreferences(
        weekdayWakeTime: Duration(hours: 8),
        weekdaySleepTime: Duration(hours: 9),
        weekendWakeTime: Duration(hours: 8),
        weekendSleepTime: Duration(hours: 9),
        reminderIntervalMinutes: 180,
      );

      final List<DateTime> result = engine.computeReminderTimes(
        dayAnchor: DateTime(2026, 5, 5),
        preferences: tinyWindow,
        isWeekend: false,
      );

      expect(result.length, 1);
      expect(result.first, DateTime(2026, 5, 5, 8, 30));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:raylynnia_hydration/domain/entities/reminder_schedule.dart';
import 'package:raylynnia_hydration/domain/entities/user_schedule_preferences.dart';
import 'package:raylynnia_hydration/domain/repositories/i_notification_repository.dart';
import 'package:raylynnia_hydration/domain/repositories/i_scheduling_repository.dart';
import 'package:raylynnia_hydration/domain/services/scheduling_engine.dart';
import 'package:raylynnia_hydration/domain/usecases/compute_reminder_schedule_usecase.dart';
import 'package:raylynnia_hydration/domain/usecases/reschedule_all_notifications_usecase.dart';

void main() {
  group('RescheduleAllNotificationsUseCase', () {
    test('cancels existing notifications and schedules newly computed times',
        () async {
      final _FakeNotificationRepository notificationRepo =
          _FakeNotificationRepository();
      final _FakeSchedulingRepository schedulingRepo = _FakeSchedulingRepository(
        const UserSchedulePreferences(
          weekdayWakeTime: Duration(hours: 7),
          weekdaySleepTime: Duration(hours: 22),
          weekendWakeTime: Duration(hours: 8),
          weekendSleepTime: Duration(hours: 23),
          reminderIntervalMinutes: 120,
        ),
      );

      final useCase = RescheduleAllNotificationsUseCase(
        notificationRepository: notificationRepo,
        schedulingRepository: schedulingRepo,
        computeReminderScheduleUseCase: const ComputeReminderScheduleUseCase(
          SchedulingEngine(),
        ),
      );

      await useCase.execute(now: DateTime(2026, 5, 4, 9));

      expect(notificationRepo.cancelAllCount, 1);
      expect(notificationRepo.lastScheduled, isNotNull);
      expect(notificationRepo.lastScheduled!.times, isNotEmpty);
      expect(notificationRepo.lastScheduled!.isWeekend, isFalse);
    });
  });
}

class _FakeNotificationRepository implements INotificationRepository {
  int cancelAllCount = 0;
  ReminderSchedule? lastScheduled;

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async {
    return true;
  }

  @override
  Future<void> scheduleAll(ReminderSchedule schedule) async {
    lastScheduled = schedule;
  }
}

class _FakeSchedulingRepository implements ISchedulingRepository {
  _FakeSchedulingRepository(this.preferences);

  final UserSchedulePreferences? preferences;

  @override
  Future<UserSchedulePreferences?> getSchedulePreferences() async {
    return preferences;
  }

  @override
  Future<void> saveSchedulePreferences(UserSchedulePreferences preferences) async {}
}

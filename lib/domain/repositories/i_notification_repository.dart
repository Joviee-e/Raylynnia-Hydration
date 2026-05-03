import '../entities/reminder_schedule.dart';

abstract class INotificationRepository {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> cancelAll();
  Future<void> scheduleAll(ReminderSchedule schedule);
}

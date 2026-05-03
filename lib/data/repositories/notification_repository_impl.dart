import '../../domain/entities/reminder_schedule.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../services/notification_manager.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  NotificationRepositoryImpl(this._notificationManager);

  final NotificationManager _notificationManager;

  @override
  Future<void> initialize() {
    return _notificationManager.initialize();
  }

  @override
  Future<bool> requestPermission() {
    return _notificationManager.requestPermission();
  }

  @override
  Future<void> cancelAll() {
    return _notificationManager.cancelAll();
  }

  @override
  Future<void> scheduleAll(ReminderSchedule schedule) {
    return _notificationManager.scheduleAll(schedule);
  }
}

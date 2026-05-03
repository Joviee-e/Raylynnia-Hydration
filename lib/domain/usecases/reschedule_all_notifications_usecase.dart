import '../entities/reminder_schedule.dart';
import '../repositories/i_notification_repository.dart';
import '../repositories/i_scheduling_repository.dart';
import 'compute_reminder_schedule_usecase.dart';

class RescheduleAllNotificationsUseCase {
  const RescheduleAllNotificationsUseCase({
    required INotificationRepository notificationRepository,
    required ISchedulingRepository schedulingRepository,
    required ComputeReminderScheduleUseCase computeReminderScheduleUseCase,
  }) : _notificationRepository = notificationRepository,
       _schedulingRepository = schedulingRepository,
       _computeReminderScheduleUseCase = computeReminderScheduleUseCase;

  final INotificationRepository _notificationRepository;
  final ISchedulingRepository _schedulingRepository;
  final ComputeReminderScheduleUseCase _computeReminderScheduleUseCase;

  Future<void> execute({DateTime? now}) async {
    final preferences = await _schedulingRepository.getSchedulePreferences();
    if (preferences == null) {
      return;
    }

    final DateTime anchor = now ?? DateTime.now();
    final ReminderSchedule schedule = _computeReminderScheduleUseCase.execute(
      dayAnchor: anchor,
      preferences: preferences,
      isWeekend: _isWeekend(anchor),
    );

    await _notificationRepository.cancelAll();
    await _notificationRepository.scheduleAll(schedule);
  }

  bool _isWeekend(DateTime dateTime) {
    return dateTime.weekday == DateTime.saturday ||
        dateTime.weekday == DateTime.sunday;
  }
}

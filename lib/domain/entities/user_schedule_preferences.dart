class UserSchedulePreferences {
  const UserSchedulePreferences({
    required this.weekdayWakeTime,
    required this.weekdaySleepTime,
    required this.weekendWakeTime,
    required this.weekendSleepTime,
    required this.reminderIntervalMinutes,
    this.notificationsActive = true,
  });

  final Duration weekdayWakeTime;
  final Duration weekdaySleepTime;
  final Duration weekendWakeTime;
  final Duration weekendSleepTime;
  final int reminderIntervalMinutes;
  final bool notificationsActive;
}

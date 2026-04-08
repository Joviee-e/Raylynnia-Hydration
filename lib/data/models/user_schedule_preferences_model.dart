class UserSchedulePreferencesModel {
  const UserSchedulePreferencesModel({
    required this.weekdayWakeTimeMinutes,
    required this.weekdaySleepTimeMinutes,
    required this.weekendWakeTimeMinutes,
    required this.weekendSleepTimeMinutes,
    required this.reminderIntervalMinutes,
  });

  final int weekdayWakeTimeMinutes;
  final int weekdaySleepTimeMinutes;
  final int weekendWakeTimeMinutes;
  final int weekendSleepTimeMinutes;
  final int reminderIntervalMinutes;

  factory UserSchedulePreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserSchedulePreferencesModel(
      weekdayWakeTimeMinutes: json['weekdayWakeTimeMinutes'] as int,
      weekdaySleepTimeMinutes: json['weekdaySleepTimeMinutes'] as int,
      weekendWakeTimeMinutes: json['weekendWakeTimeMinutes'] as int,
      weekendSleepTimeMinutes: json['weekendSleepTimeMinutes'] as int,
      reminderIntervalMinutes: json['reminderIntervalMinutes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'weekdayWakeTimeMinutes': weekdayWakeTimeMinutes,
      'weekdaySleepTimeMinutes': weekdaySleepTimeMinutes,
      'weekendWakeTimeMinutes': weekendWakeTimeMinutes,
      'weekendSleepTimeMinutes': weekendSleepTimeMinutes,
      'reminderIntervalMinutes': reminderIntervalMinutes,
    };
  }
}

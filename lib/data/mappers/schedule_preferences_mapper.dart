import '../../domain/entities/user_schedule_preferences.dart';
import '../models/user_schedule_preferences_model.dart';

abstract final class SchedulePreferencesMapper {
  static UserSchedulePreferences toEntity(UserSchedulePreferencesModel model) {
    return UserSchedulePreferences(
      weekdayWakeTime: Duration(minutes: model.weekdayWakeTimeMinutes),
      weekdaySleepTime: Duration(minutes: model.weekdaySleepTimeMinutes),
      weekendWakeTime: Duration(minutes: model.weekendWakeTimeMinutes),
      weekendSleepTime: Duration(minutes: model.weekendSleepTimeMinutes),
      reminderIntervalMinutes: model.reminderIntervalMinutes,
    );
  }

  static UserSchedulePreferencesModel toModel(
    UserSchedulePreferences entity,
  ) {
    return UserSchedulePreferencesModel(
      weekdayWakeTimeMinutes: entity.weekdayWakeTime.inMinutes,
      weekdaySleepTimeMinutes: entity.weekdaySleepTime.inMinutes,
      weekendWakeTimeMinutes: entity.weekendWakeTime.inMinutes,
      weekendSleepTimeMinutes: entity.weekendSleepTime.inMinutes,
      reminderIntervalMinutes: entity.reminderIntervalMinutes,
    );
  }
}

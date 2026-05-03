import '../entities/user_schedule_preferences.dart';

abstract class ISchedulingRepository {
  Future<UserSchedulePreferences?> getSchedulePreferences();
  Future<void> saveSchedulePreferences(UserSchedulePreferences preferences);
}

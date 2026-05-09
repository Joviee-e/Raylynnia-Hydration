import '../entities/user_profile.dart';
import '../entities/user_schedule_preferences.dart';

abstract class IUserProfileRepository {
  Future<UserProfile?> getUserProfile();
  Future<void> saveProfile(UserProfile userProfile);
  Future<void> savePreferences(UserSchedulePreferences preferences);
  Future<void> markOnboardingComplete();
  Future<UserSchedulePreferences?> getPreferences();
}


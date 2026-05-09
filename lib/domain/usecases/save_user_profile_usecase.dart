import '../entities/user_profile.dart';
import '../entities/user_schedule_preferences.dart';
import '../repositories/i_user_profile_repository.dart';

/// Use case: Save user profile and preferences.
/// Persists both profile and schedule preferences atomically.
class SaveUserProfileUseCase {
  const SaveUserProfileUseCase(this.userProfileRepository);

  final IUserProfileRepository userProfileRepository;

  /// Execute the use case.
  /// Saves the profile and preferences to local storage.
  Future<void> execute({
    required UserProfile profile,
    required UserSchedulePreferences preferences,
  }) async {
    await userProfileRepository.saveProfile(profile);
    await userProfileRepository.savePreferences(preferences);
  }
}

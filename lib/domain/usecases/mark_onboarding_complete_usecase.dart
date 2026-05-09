import '../repositories/i_user_profile_repository.dart';

/// Use case: Mark onboarding as complete.
/// Sets the onboarding complete flag on the user profile.
class MarkOnboardingCompleteUseCase {
  const MarkOnboardingCompleteUseCase(this.userProfileRepository);

  final IUserProfileRepository userProfileRepository;

  /// Execute the use case.
  /// Marks onboarding as complete in local storage.
  Future<void> execute() async {
    await userProfileRepository.markOnboardingComplete();
  }
}

abstract class IUserProfileLocalDataSource {
  Future<Map<String, dynamic>?> getUserProfile();
  Future<void> saveUserProfile(Map<String, dynamic> json);
  Future<void> savePreferences(Map<String, dynamic> json);
  Future<void> markOnboardingComplete();
  Future<Map<String, dynamic>?> getPreferences();
}


abstract class IUserProfileLocalDataSource {
  Future<Map<String, dynamic>?> getUserProfile();
  Future<void> saveUserProfile(Map<String, dynamic> json);
}

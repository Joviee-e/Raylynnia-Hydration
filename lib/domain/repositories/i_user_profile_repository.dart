import '../entities/user_profile.dart';

abstract class IUserProfileRepository {
  Future<UserProfile?> getUserProfile();
  Future<void> saveUserProfile(UserProfile userProfile);
}

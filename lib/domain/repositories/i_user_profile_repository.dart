import '../entities/user_profile.dart';

abstract class IUserProfileRepository {
  Future<UserProfile?> getUserProfile();
}

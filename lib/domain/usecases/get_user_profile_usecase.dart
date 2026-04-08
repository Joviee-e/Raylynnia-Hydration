import '../entities/user_profile.dart';
import '../repositories/i_user_profile_repository.dart';

class GetUserProfileUseCase {
  const GetUserProfileUseCase(this._userProfileRepository);

  final IUserProfileRepository _userProfileRepository;

  Future<UserProfile?> execute() {
    return _userProfileRepository.getUserProfile();
  }
}

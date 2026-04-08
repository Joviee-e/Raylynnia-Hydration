import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_user_profile_repository.dart';
import '../datasources/interfaces/i_user_profile_datasource.dart';
import '../mappers/user_profile_mapper.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements IUserProfileRepository {
  UserProfileRepositoryImpl(this._localDataSource);

  final IUserProfileLocalDataSource _localDataSource;

  @override
  Future<UserProfile?> getUserProfile() async {
    final Map<String, dynamic>? json = await _localDataSource.getUserProfile();
    if (json == null) {
      return null;
    }

    final UserProfileModel model = UserProfileModel.fromJson(json);
    return UserProfileMapper.toEntity(model);
  }

  @override
  Future<void> saveUserProfile(UserProfile userProfile) async {
    final UserProfileModel model = UserProfileMapper.toModel(userProfile);
    await _localDataSource.saveUserProfile(model.toJson());
  }
}

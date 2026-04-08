import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

abstract final class UserProfileMapper {
  static UserProfile toEntity(UserProfileModel model) {
    return UserProfile(
      id: model.id,
      name: model.name,
      dailyGoalMl: model.dailyGoalMl,
      isOnboardingComplete: model.isOnboardingComplete,
      timezoneOffsetMinutes: model.timezoneOffsetMinutes,
    );
  }

  static UserProfileModel toModel(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      dailyGoalMl: entity.dailyGoalMl,
      isOnboardingComplete: entity.isOnboardingComplete,
      timezoneOffsetMinutes: entity.timezoneOffsetMinutes,
    );
  }
}

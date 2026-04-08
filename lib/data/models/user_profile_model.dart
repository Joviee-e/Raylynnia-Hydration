class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.name,
    required this.dailyGoalMl,
    required this.isOnboardingComplete,
    required this.timezoneOffsetMinutes,
  });

  final String id;
  final String name;
  final int dailyGoalMl;
  final bool isOnboardingComplete;
  final int timezoneOffsetMinutes;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dailyGoalMl: json['dailyGoalMl'] as int,
      isOnboardingComplete: json['isOnboardingComplete'] as bool,
      timezoneOffsetMinutes: json['timezoneOffsetMinutes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'dailyGoalMl': dailyGoalMl,
      'isOnboardingComplete': isOnboardingComplete,
      'timezoneOffsetMinutes': timezoneOffsetMinutes,
    };
  }
}

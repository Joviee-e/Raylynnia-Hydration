class UserProfile {
  const UserProfile({
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

  UserProfile copyWith({
    String? id,
    String? name,
    int? dailyGoalMl,
    bool? isOnboardingComplete,
    int? timezoneOffsetMinutes,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/entities/user_schedule_preferences.dart';
import '../../../../domain/entities/reminder_schedule.dart';
import '../../../../domain/repositories/i_user_profile_repository.dart';
import '../../../../domain/usecases/get_user_profile_usecase.dart';
import '../../../../domain/usecases/save_user_profile_usecase.dart';
import '../../../../domain/usecases/compute_reminder_schedule_usecase.dart';

class ProfileState {
  const ProfileState({
    this.userProfile,
    this.preferences,
    this.schedulePreview,
    this.isLoading = false,
    this.error,
    this.isSaving = false,
  });

  final UserProfile? userProfile;
  final UserSchedulePreferences? preferences;
  final ReminderSchedule? schedulePreview;
  final bool isLoading;
  final String? error;
  final bool isSaving;

  ProfileState copyWith({
    UserProfile? userProfile,
    UserSchedulePreferences? preferences,
    ReminderSchedule? schedulePreview,
    bool? isLoading,
    String? error,
    bool? isSaving,
    bool clearError = false,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      preferences: preferences ?? this.preferences,
      schedulePreview: schedulePreview ?? this.schedulePreview,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  ProfileViewModel({
    required this.getUserProfileUseCase,
    required this.saveUserProfileUseCase,
    required this.computeReminderScheduleUseCase,
  }) : super(const ProfileState()) {
    _initialize();
  }

  final GetUserProfileUseCase getUserProfileUseCase;
  final SaveUserProfileUseCase saveUserProfileUseCase;
  final ComputeReminderScheduleUseCase computeReminderScheduleUseCase;

  Future<void> _initialize() async {
    await loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await getUserProfileUseCase.execute();
      final preferences = await getIt<IUserProfileRepository>().getPreferences();
      state = state.copyWith(
        userProfile: profile,
        preferences: preferences,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load profile: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> updateDailyGoal(int goalMl) async {
    if (state.userProfile == null) return;
    
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updatedProfile = state.userProfile!.copyWith(dailyGoalMl: goalMl);
      
      // Use existing preferences or create defaults
      final preferences = state.preferences ?? const UserSchedulePreferences(
        weekdayWakeTime: Duration(hours: 6),
        weekdaySleepTime: Duration(hours: 22),
        weekendWakeTime: Duration(hours: 8),
        weekendSleepTime: Duration(hours: 23),
        reminderIntervalMinutes: 60,
      );
      
      await saveUserProfileUseCase.execute(
        profile: updatedProfile,
        preferences: preferences,
      );
      state = state.copyWith(
        userProfile: updatedProfile,
        isSaving: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update goal: ${e.toString()}',
        isSaving: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

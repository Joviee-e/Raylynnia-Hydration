import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/entities/user_schedule_preferences.dart';
import '../../../../domain/entities/reminder_schedule.dart';
import '../../../../domain/repositories/i_user_profile_repository.dart';
import '../../../../domain/usecases/get_user_profile_usecase.dart';
import '../../../../domain/usecases/save_user_profile_usecase.dart';
import '../../../../domain/usecases/compute_reminder_schedule_usecase.dart';
import '../../../../domain/usecases/reschedule_all_notifications_usecase.dart';

class ScheduleSettingsState {
  const ScheduleSettingsState({
    this.userProfile,
    this.preferences,
    this.weekdayWakeTime,
    this.weekdaySleepTime,
    this.weekendWakeTime,
    this.weekendSleepTime,
    this.reminderIntervalMinutes = 60,
    this.weekdaySchedulePreview,
    this.weekendSchedulePreview,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  final UserProfile? userProfile;
  final UserSchedulePreferences? preferences;
  final Duration? weekdayWakeTime;
  final Duration? weekdaySleepTime;
  final Duration? weekendWakeTime;
  final Duration? weekendSleepTime;
  final int reminderIntervalMinutes;
  final ReminderSchedule? weekdaySchedulePreview;
  final ReminderSchedule? weekendSchedulePreview;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  ScheduleSettingsState copyWith({
    UserProfile? userProfile,
    UserSchedulePreferences? preferences,
    Duration? weekdayWakeTime,
    Duration? weekdaySleepTime,
    Duration? weekendWakeTime,
    Duration? weekendSleepTime,
    int? reminderIntervalMinutes,
    ReminderSchedule? weekdaySchedulePreview,
    ReminderSchedule? weekendSchedulePreview,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return ScheduleSettingsState(
      userProfile: userProfile ?? this.userProfile,
      preferences: preferences ?? this.preferences,
      weekdayWakeTime: weekdayWakeTime ?? this.weekdayWakeTime,
      weekdaySleepTime: weekdaySleepTime ?? this.weekdaySleepTime,
      weekendWakeTime: weekendWakeTime ?? this.weekendWakeTime,
      weekendSleepTime: weekendSleepTime ?? this.weekendSleepTime,
      reminderIntervalMinutes: reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      weekdaySchedulePreview: weekdaySchedulePreview ?? this.weekdaySchedulePreview,
      weekendSchedulePreview: weekendSchedulePreview ?? this.weekendSchedulePreview,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ScheduleSettingsViewModel extends StateNotifier<ScheduleSettingsState> {
  ScheduleSettingsViewModel({
    required this.getUserProfileUseCase,
    required this.saveUserProfileUseCase,
    required this.computeReminderScheduleUseCase,
    required this.rescheduleAllNotificationsUseCase,
  }) : super(const ScheduleSettingsState()) {
    _initialize();
  }

  final GetUserProfileUseCase getUserProfileUseCase;
  final SaveUserProfileUseCase saveUserProfileUseCase;
  final ComputeReminderScheduleUseCase computeReminderScheduleUseCase;
  final RescheduleAllNotificationsUseCase rescheduleAllNotificationsUseCase;

  Future<void> _initialize() async {
    await loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await getUserProfileUseCase.execute();
      final preferences = await getIt<IUserProfileRepository>().getPreferences();
      state = state.copyWith(
        userProfile: profile,
        preferences: preferences,
        weekdayWakeTime: preferences?.weekdayWakeTime,
        weekdaySleepTime: preferences?.weekdaySleepTime,
        weekendWakeTime: preferences?.weekendWakeTime,
        weekendSleepTime: preferences?.weekendSleepTime,
        reminderIntervalMinutes: preferences?.reminderIntervalMinutes ?? 60,
        isLoading: false,
      );
      _updateSchedulePreviews();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load settings: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  void setWeekdayWakeTime(Duration time) {
    state = state.copyWith(weekdayWakeTime: time);
    _updateSchedulePreviews();
  }

  void setWeekdaySleepTime(Duration time) {
    state = state.copyWith(weekdaySleepTime: time);
    _updateSchedulePreviews();
  }

  void setWeekendWakeTime(Duration time) {
    state = state.copyWith(weekendWakeTime: time);
    _updateSchedulePreviews();
  }

  void setWeekendSleepTime(Duration time) {
    state = state.copyWith(weekendSleepTime: time);
    _updateSchedulePreviews();
  }

  void setReminderInterval(int minutes) {
    state = state.copyWith(reminderIntervalMinutes: minutes);
    _updateSchedulePreviews();
  }

  void _updateSchedulePreviews() {
    if (state.weekdayWakeTime == null ||
        state.weekdaySleepTime == null ||
        state.weekendWakeTime == null ||
        state.weekendSleepTime == null) {
      return;
    }

    final preferences = UserSchedulePreferences(
      weekdayWakeTime: state.weekdayWakeTime!,
      weekdaySleepTime: state.weekdaySleepTime!,
      weekendWakeTime: state.weekendWakeTime!,
      weekendSleepTime: state.weekendSleepTime!,
      reminderIntervalMinutes: state.reminderIntervalMinutes,
    );

    final now = DateTime.now();
    final weekdaySchedule = computeReminderScheduleUseCase.execute(
      dayAnchor: now,
      preferences: preferences,
      isWeekend: false,
    );
    final weekendSchedule = computeReminderScheduleUseCase.execute(
      dayAnchor: now,
      preferences: preferences,
      isWeekend: true,
    );

    state = state.copyWith(
      weekdaySchedulePreview: weekdaySchedule,
      weekendSchedulePreview: weekendSchedule,
    );
  }

  Future<void> saveSettings() async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      if (state.weekdayWakeTime == null ||
          state.weekdaySleepTime == null ||
          state.weekendWakeTime == null ||
          state.weekendSleepTime == null) {
        state = state.copyWith(
          error: 'All schedule settings are required',
          isSaving: false,
        );
        return;
      }

      final preferences = UserSchedulePreferences(
        weekdayWakeTime: state.weekdayWakeTime!,
        weekdaySleepTime: state.weekdaySleepTime!,
        weekendWakeTime: state.weekendWakeTime!,
        weekendSleepTime: state.weekendSleepTime!,
        reminderIntervalMinutes: state.reminderIntervalMinutes,
      );

      await saveUserProfileUseCase.execute(
        profile: state.userProfile!,
        preferences: preferences,
      );

      await rescheduleAllNotificationsUseCase.execute();

      state = state.copyWith(
        preferences: preferences,
        isSaving: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to save settings: ${e.toString()}',
        isSaving: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

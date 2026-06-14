import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/entities/user_schedule_preferences.dart';
import '../../../../domain/repositories/i_notification_repository.dart';
import '../../../../domain/usecases/compute_reminder_schedule_usecase.dart';
import '../../../../domain/usecases/save_user_profile_usecase.dart';
import '../../../../domain/usecases/mark_onboarding_complete_usecase.dart';
import '../../../../domain/usecases/reschedule_all_notifications_usecase.dart';

/// State holder for the multi-step onboarding flow.
/// Accumulates form data in memory across steps and only persists on final confirmation.
class OnboardingState {
  const OnboardingState({
    this.name = '',
    this.weekdayWakeTime = const Duration(hours: 7),
    this.weekdaySleepTime = const Duration(hours: 23),
    this.weekendWakeTime = const Duration(hours: 9),
    this.weekendSleepTime = const Duration(hours: 0, minutes: 30), // 12:30 AM
    this.dailyGoalMl = 2000,
    this.reminderIntervalMinutes = 60,
    this.currentStep = 0,
    this.isLoading = false,
    this.error,
  });

  final String name;
  final Duration weekdayWakeTime;
  final Duration weekdaySleepTime;
  final Duration weekendWakeTime;
  final Duration weekendSleepTime;
  final int dailyGoalMl;
  final int reminderIntervalMinutes;
  final int currentStep;
  final bool isLoading;
  final String? error;

  OnboardingState copyWith({
    String? name,
    Duration? weekdayWakeTime,
    Duration? weekdaySleepTime,
    Duration? weekendWakeTime,
    Duration? weekendSleepTime,
    int? dailyGoalMl,
    int? reminderIntervalMinutes,
    int? currentStep,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      weekdayWakeTime: weekdayWakeTime ?? this.weekdayWakeTime,
      weekdaySleepTime: weekdaySleepTime ?? this.weekdaySleepTime,
      weekendWakeTime: weekendWakeTime ?? this.weekendWakeTime,
      weekendSleepTime: weekendSleepTime ?? this.weekendSleepTime,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      reminderIntervalMinutes: reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// ViewModel for onboarding flow.
/// Manages form state, step progression, and final profile save.
class OnboardingViewModel extends StateNotifier<OnboardingState> {
  OnboardingViewModel({
    required this.saveUserProfileUseCase,
    required this.markOnboardingCompleteUseCase,
    required this.rescheduleAllNotificationsUseCase,
    required this.computeReminderScheduleUseCase,
    required this.notificationRepository,
  }) : super(const OnboardingState());

  final SaveUserProfileUseCase saveUserProfileUseCase;
  final MarkOnboardingCompleteUseCase markOnboardingCompleteUseCase;
  final RescheduleAllNotificationsUseCase rescheduleAllNotificationsUseCase;
  final ComputeReminderScheduleUseCase computeReminderScheduleUseCase;
  final INotificationRepository notificationRepository;

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setWeekdayWakeTime(Duration time) {
    state = state.copyWith(weekdayWakeTime: time);
  }

  void setWeekdaySleepTime(Duration time) {
    state = state.copyWith(weekdaySleepTime: time);
  }

  void setWeekendWakeTime(Duration time) {
    state = state.copyWith(weekendWakeTime: time);
  }

  void setWeekendSleepTime(Duration time) {
    state = state.copyWith(weekendSleepTime: time);
  }

  void setDailyGoalMl(int goal) {
    state = state.copyWith(dailyGoalMl: goal);
  }

  void setReminderIntervalMinutes(int interval) {
    state = state.copyWith(reminderIntervalMinutes: interval);
  }

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        clearError: true,
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        clearError: true,
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String buildSchedulePreviewText() {
    final DateTime anchor = DateTime.now();
    final preferences = UserSchedulePreferences(
      weekdayWakeTime: state.weekdayWakeTime,
      weekdaySleepTime: state.weekdaySleepTime,
      weekendWakeTime: state.weekendWakeTime,
      weekendSleepTime: state.weekendSleepTime,
      reminderIntervalMinutes: state.reminderIntervalMinutes,
    );
    final schedule = computeReminderScheduleUseCase.execute(
      dayAnchor: anchor,
      preferences: preferences,
      isWeekend: anchor.weekday == DateTime.saturday ||
          anchor.weekday == DateTime.sunday,
    );

    if (schedule.times.isEmpty) {
      return 'No reminders scheduled';
    }

    final times = schedule.times
        .map((time) =>
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}')
        .join(', ');
    return 'Reminders: $times';
  }

  /// Save profile, mark onboarding complete, and reschedule notifications.
  /// Called on final step confirmation.
  Future<bool> completeOnboarding() async {
    // Validate required fields
    if (state.name.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter your name');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Create preferences from form state
      final preferences = UserSchedulePreferences(
        weekdayWakeTime: state.weekdayWakeTime,
        weekdaySleepTime: state.weekdaySleepTime,
        weekendWakeTime: state.weekendWakeTime,
        weekendSleepTime: state.weekendSleepTime,
        reminderIntervalMinutes: state.reminderIntervalMinutes,
        notificationsActive: true,
      );

      // Create profile
      final profile = UserProfile(
        id: 'default_user',
        name: state.name.trim(),
        dailyGoalMl: state.dailyGoalMl,
        isOnboardingComplete: true,
        timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      );

      // Save profile
      await saveUserProfileUseCase.execute(
        profile: profile,
        preferences: preferences,
      );

      // Mark onboarding complete
      await markOnboardingCompleteUseCase.execute();

      // Ask permission contextually at the onboarding confirmation step.
      await notificationRepository.requestPermission();

      // Reschedule notifications with persisted preferences.
      await rescheduleAllNotificationsUseCase.execute();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save profile: ${e.toString()}',
      );
      return false;
    }
  }
}

/// Riverpod provider for OnboardingViewModel
final onboardingViewModelProvider = StateNotifierProvider<
    OnboardingViewModel,
    OnboardingState>((ref) {
  final saveProfileUseCase = getIt<SaveUserProfileUseCase>();
  final markCompleteUseCase = getIt<MarkOnboardingCompleteUseCase>();
  final rescheduleNotificationsUseCase =
      getIt<RescheduleAllNotificationsUseCase>();
  final computeUseCase = getIt<ComputeReminderScheduleUseCase>();
  final notificationRepository = getIt<INotificationRepository>();

  return OnboardingViewModel(
    saveUserProfileUseCase: saveProfileUseCase,
    markOnboardingCompleteUseCase: markCompleteUseCase,
    rescheduleAllNotificationsUseCase: rescheduleNotificationsUseCase,
    computeReminderScheduleUseCase: computeUseCase,
    notificationRepository: notificationRepository,
  );
});

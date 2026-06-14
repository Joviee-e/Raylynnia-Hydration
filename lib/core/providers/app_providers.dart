import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../data/repositories/hydration_log_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/scheduling_repository_impl.dart';
import '../../domain/repositories/i_user_profile_repository.dart';
import '../../domain/repositories/i_hydration_log_repository.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../../domain/repositories/i_scheduling_repository.dart';
import '../../domain/usecases/compute_reminder_schedule_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/save_user_profile_usecase.dart';
import '../../domain/usecases/mark_onboarding_complete_usecase.dart';
import '../../domain/usecases/reschedule_all_notifications_usecase.dart';
import '../../domain/usecases/log_hydration_intake_usecase.dart';
import '../../domain/usecases/get_daily_history_usecase.dart';
import '../../domain/usecases/get_weekly_progress_usecase.dart';
import '../../core/di/injection_container.dart';
import '../../features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import '../../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../../features/history/presentation/viewmodels/history_viewmodel.dart';
import '../../features/user_profile/presentation/viewmodels/profile_viewmodel.dart';
import '../../features/scheduling_engine/presentation/viewmodels/schedule_settings_viewmodel.dart';

// Repository Providers
final userProfileRepositoryProvider = Provider<IUserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(getIt());
});

final hydrationLogRepositoryProvider = Provider<IHydrationLogRepository>((ref) {
  return HydrationLogRepositoryImpl(getIt());
});

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepositoryImpl(getIt());
});

final schedulingRepositoryProvider = Provider<ISchedulingRepository>((ref) {
  return SchedulingRepositoryImpl(getIt());
});

// Use Case Providers
final computeReminderScheduleProvider = Provider<ComputeReminderScheduleUseCase>((ref) {
  return ComputeReminderScheduleUseCase(getIt());
});

final getUserProfileProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(ref.watch(userProfileRepositoryProvider));
});

final saveUserProfileProvider = Provider<SaveUserProfileUseCase>((ref) {
  return SaveUserProfileUseCase(
    ref.watch(userProfileRepositoryProvider),
    ref.watch(schedulingRepositoryProvider),
  );
});

final markOnboardingCompleteProvider = Provider<MarkOnboardingCompleteUseCase>((ref) {
  return MarkOnboardingCompleteUseCase(ref.watch(userProfileRepositoryProvider));
});

final rescheduleAllNotificationsProvider = Provider<RescheduleAllNotificationsUseCase>((ref) {
  return RescheduleAllNotificationsUseCase(
    notificationRepository: ref.watch(notificationRepositoryProvider),
    schedulingRepository: ref.watch(schedulingRepositoryProvider),
    computeReminderScheduleUseCase: ref.watch(computeReminderScheduleProvider),
  );
});

final logHydrationIntakeProvider = Provider<LogHydrationIntakeUseCase>((ref) {
  return LogHydrationIntakeUseCase(ref.watch(hydrationLogRepositoryProvider));
});

final getDailyHistoryProvider = Provider<GetDailyHistoryUseCase>((ref) {
  return GetDailyHistoryUseCase(ref.watch(hydrationLogRepositoryProvider));
});

final getWeeklyProgressProvider = Provider<GetWeeklyProgressUseCase>((ref) {
  return GetWeeklyProgressUseCase(ref.watch(hydrationLogRepositoryProvider));
});

// ViewModel Providers
final onboardingViewModelProvider =
    StateNotifierProvider.autoDispose<OnboardingViewModel, OnboardingState>((ref) {
  return OnboardingViewModel(
    saveUserProfileUseCase: ref.watch(saveUserProfileProvider),
    markOnboardingCompleteUseCase: ref.watch(markOnboardingCompleteProvider),
    rescheduleAllNotificationsUseCase: ref.watch(rescheduleAllNotificationsProvider),
    computeReminderScheduleUseCase: ref.watch(computeReminderScheduleProvider),
    notificationRepository: ref.watch(notificationRepositoryProvider),
  );
});

final homeViewModelProvider = StateNotifierProvider.autoDispose<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(
    getUserProfileUseCase: ref.watch(getUserProfileProvider),
    logHydrationIntakeUseCase: ref.watch(logHydrationIntakeProvider),
    getDailyHistoryUseCase: ref.watch(getDailyHistoryProvider),
    computeReminderScheduleUseCase: ref.watch(computeReminderScheduleProvider),
  );
});

final historyViewModelProvider =
    StateNotifierProvider.autoDispose<HistoryViewModel, HistoryState>((ref) {
  return HistoryViewModel(
    getDailyHistoryUseCase: ref.watch(getDailyHistoryProvider),
    getWeeklyProgressUseCase: ref.watch(getWeeklyProgressProvider),
  );
});

final profileViewModelProvider = StateNotifierProvider.autoDispose<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(
    getUserProfileUseCase: ref.watch(getUserProfileProvider),
    saveUserProfileUseCase: ref.watch(saveUserProfileProvider),
    computeReminderScheduleUseCase: ref.watch(computeReminderScheduleProvider),
  );
});

final scheduleSettingsViewModelProvider =
    StateNotifierProvider.autoDispose<ScheduleSettingsViewModel, ScheduleSettingsState>((ref) {
  return ScheduleSettingsViewModel(
    getUserProfileUseCase: ref.watch(getUserProfileProvider),
    saveUserProfileUseCase: ref.watch(saveUserProfileProvider),
    computeReminderScheduleUseCase: ref.watch(computeReminderScheduleProvider),
    rescheduleAllNotificationsUseCase: ref.watch(rescheduleAllNotificationsProvider),
  );
});

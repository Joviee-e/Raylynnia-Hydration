import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/interfaces/i_user_profile_datasource.dart';
import '../../data/datasources/interfaces/i_hydration_log_datasource.dart';
import '../../data/datasources/local/schedule_local_datasource.dart';
import '../../data/datasources/local/user_profile_local_datasource.dart';
import '../../data/datasources/local/hydration_log_local_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/scheduling_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../data/repositories/hydration_log_repository_impl.dart';
import '../../data/services/notification_manager.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../../domain/repositories/i_scheduling_repository.dart';
import '../../domain/repositories/i_user_profile_repository.dart';
import '../../domain/repositories/i_hydration_log_repository.dart';
import '../../domain/services/scheduling_engine.dart';
import '../../domain/usecases/compute_reminder_schedule_usecase.dart';
import '../../domain/usecases/reschedule_all_notifications_usecase.dart';
import '../../domain/usecases/save_user_profile_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/mark_onboarding_complete_usecase.dart';
import '../../domain/usecases/log_hydration_intake_usecase.dart';
import '../../domain/usecases/get_daily_history_usecase.dart';
import '../../domain/usecases/get_weekly_progress_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  }

  if (!getIt.isRegistered<FlutterLocalNotificationsPlugin>()) {
    getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
      FlutterLocalNotificationsPlugin.new,
    );
  }

  if (!getIt.isRegistered<NotificationManager>()) {
    getIt.registerLazySingleton<NotificationManager>(
      () => NotificationManager(getIt<FlutterLocalNotificationsPlugin>()),
    );
  }

  // Data Sources
  if (!getIt.isRegistered<ScheduleLocalDataSource>()) {
    getIt.registerLazySingleton<ScheduleLocalDataSource>(
      () => ScheduleLocalDataSource(getIt<SharedPreferences>()),
    );
  }

  if (!getIt.isRegistered<IUserProfileLocalDataSource>()) {
    getIt.registerLazySingleton<IUserProfileLocalDataSource>(
      () => UserProfileLocalDataSource(getIt<SharedPreferences>()),
    );
  }

  if (!getIt.isRegistered<IHydrationLogLocalDataSource>()) {
    getIt.registerLazySingleton<IHydrationLogLocalDataSource>(
      () => HydrationLogLocalDataSource(),
    );
  }

  // Repositories
  if (!getIt.isRegistered<INotificationRepository>()) {
    getIt.registerLazySingleton<INotificationRepository>(
      () => NotificationRepositoryImpl(getIt<NotificationManager>()),
    );
  }

  if (!getIt.isRegistered<ISchedulingRepository>()) {
    getIt.registerLazySingleton<ISchedulingRepository>(
      () => SchedulingRepositoryImpl(getIt<ScheduleLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<IUserProfileRepository>()) {
    getIt.registerLazySingleton<IUserProfileRepository>(
      () => UserProfileRepositoryImpl(getIt<IUserProfileLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<IHydrationLogRepository>()) {
    getIt.registerLazySingleton<IHydrationLogRepository>(
      () => HydrationLogRepositoryImpl(getIt<IHydrationLogLocalDataSource>()),
    );
  }

  // Domain Services
  if (!getIt.isRegistered<SchedulingEngine>()) {
    getIt.registerLazySingleton<SchedulingEngine>(SchedulingEngine.new);
  }

  // Use Cases
  if (!getIt.isRegistered<ComputeReminderScheduleUseCase>()) {
    getIt.registerLazySingleton<ComputeReminderScheduleUseCase>(
      () => ComputeReminderScheduleUseCase(getIt<SchedulingEngine>()),
    );
  }

  if (!getIt.isRegistered<RescheduleAllNotificationsUseCase>()) {
    getIt.registerLazySingleton<RescheduleAllNotificationsUseCase>(
      () => RescheduleAllNotificationsUseCase(
        notificationRepository: getIt<INotificationRepository>(),
        schedulingRepository: getIt<ISchedulingRepository>(),
        computeReminderScheduleUseCase: getIt<ComputeReminderScheduleUseCase>(),
      ),
    );
  }

  if (!getIt.isRegistered<SaveUserProfileUseCase>()) {
    getIt.registerLazySingleton<SaveUserProfileUseCase>(
      () => SaveUserProfileUseCase(getIt<IUserProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<GetUserProfileUseCase>()) {
    getIt.registerLazySingleton<GetUserProfileUseCase>(
      () => GetUserProfileUseCase(getIt<IUserProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<MarkOnboardingCompleteUseCase>()) {
    getIt.registerLazySingleton<MarkOnboardingCompleteUseCase>(
      () => MarkOnboardingCompleteUseCase(getIt<IUserProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<LogHydrationIntakeUseCase>()) {
    getIt.registerLazySingleton<LogHydrationIntakeUseCase>(
      () => LogHydrationIntakeUseCase(getIt<IHydrationLogRepository>()),
    );
  }

  if (!getIt.isRegistered<GetDailyHistoryUseCase>()) {
    getIt.registerLazySingleton<GetDailyHistoryUseCase>(
      () => GetDailyHistoryUseCase(getIt<IHydrationLogRepository>()),
    );
  }

  if (!getIt.isRegistered<GetWeeklyProgressUseCase>()) {
    getIt.registerLazySingleton<GetWeeklyProgressUseCase>(
      () => GetWeeklyProgressUseCase(getIt<IHydrationLogRepository>()),
    );
  }
}


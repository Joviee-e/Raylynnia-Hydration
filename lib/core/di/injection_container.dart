import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/schedule_local_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/scheduling_repository_impl.dart';
import '../../data/services/notification_manager.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../../domain/repositories/i_scheduling_repository.dart';
import '../../domain/services/scheduling_engine.dart';
import '../../domain/usecases/compute_reminder_schedule_usecase.dart';
import '../../domain/usecases/reschedule_all_notifications_usecase.dart';

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

  if (!getIt.isRegistered<ScheduleLocalDataSource>()) {
    getIt.registerLazySingleton<ScheduleLocalDataSource>(
      () => ScheduleLocalDataSource(getIt<SharedPreferences>()),
    );
  }

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

  if (!getIt.isRegistered<SchedulingEngine>()) {
    getIt.registerLazySingleton<SchedulingEngine>(SchedulingEngine.new);
  }

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
}

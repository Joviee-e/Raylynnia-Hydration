import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'data/services/notification_manager.dart';
import 'domain/usecases/get_user_profile_usecase.dart';
import 'domain/usecases/reschedule_all_notifications_usecase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();

  // Initialize notifications
  final notificationManager = getIt<NotificationManager>();
  await notificationManager.initialize();

  // Startup Recovery: Reschedule notifications if user is onboarded
  try {
    final userProfile = await getIt<GetUserProfileUseCase>().execute();
    if (userProfile != null && userProfile.isOnboardingComplete) {
      await getIt<RescheduleAllNotificationsUseCase>().execute();
    }
  } catch (_) {
    // Fail silently on startup initialization errors to avoid blocking the app launch
  }

  runApp(const ProviderScope(child: RaylynniaHydrationApp()));
}

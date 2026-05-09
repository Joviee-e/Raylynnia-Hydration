import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import 'route_names.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.onboarding,
    redirect: (BuildContext context, GoRouterState state) async {
      final profile = await getIt<GetUserProfileUseCase>().execute();
      final onboardingComplete = profile?.isOnboardingComplete ?? false;
      final isOnboardingRoute = state.matchedLocation == RouteNames.onboarding;

      if (!onboardingComplete && !isOnboardingRoute) {
        return RouteNames.onboarding;
      }
      if (onboardingComplete && isOnboardingRoute) {
        return RouteNames.home;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.onboarding,
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingFlowScreen();
        },
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
    ],
  );
}

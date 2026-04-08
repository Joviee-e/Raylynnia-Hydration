import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.onboarding,
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.onboarding,
        builder: (BuildContext context, GoRouterState state) {
          return const _PlaceholderScreen(title: 'Onboarding');
        },
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (BuildContext context, GoRouterState state) {
          return const _PlaceholderScreen(title: 'Home');
        },
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('$title Screen Placeholder'),
      ),
    );
  }
}

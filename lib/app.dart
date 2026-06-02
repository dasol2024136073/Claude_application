import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/route_input_screen.dart';
import 'domain/models/trip_plan.dart';
import 'presentation/screens/route_result_screen.dart';
import 'presentation/theme/app_theme.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, _) => const LoginScreen()),
    GoRoute(path: '/onboarding', builder: (context, _) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (context, _) => const HomeScreen()),
    GoRoute(path: '/route/input', builder: (context, _) => const RouteInputScreen()),
    GoRoute(
      path: '/route/result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return RouteResultScreen(
          destination: extra['destination'] as String,
          days: extra['days'] as int,
          tripPlan: extra['tripPlan'] as TripPlan?,
        );
      },
    ),
  ],
);

class TravelAiApp extends StatelessWidget {
  const TravelAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AI 여행 경로 추천',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

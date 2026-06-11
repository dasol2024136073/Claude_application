import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/route_input_screen.dart';
import 'domain/models/trip_plan.dart';
import 'presentation/screens/route_result_screen.dart';
import 'presentation/screens/map_screen.dart';
import 'presentation/screens/weather_screen.dart';
import 'presentation/screens/mypage_screen.dart';
import 'data/services/weather_service.dart';
import 'presentation/theme/app_theme.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, _) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, _) => const SignupScreen()),
    GoRoute(path: '/onboarding', builder: (context, _) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (context, _) => const HomeScreen()),
    GoRoute(path: '/mypage', builder: (context, _) => const MyPageScreen()),
    GoRoute(path: '/route/input', builder: (context, _) => const RouteInputScreen()),
    GoRoute(
      path: '/route/result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return RouteResultScreen(
          destination: extra['destination'] as String,
          days: extra['days'] as int,
          tripPlan: extra['tripPlan'] as TripPlan?,
          weather: extra['weather'] as WeatherInfo?,
        );
      },
    ),
    GoRoute(
      path: '/route/map',
      builder: (context, state) {
        final plan = state.extra as TripPlan;
        return MapScreen(tripPlan: plan);
      },
    ),
    GoRoute(
      path: '/weather',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return WeatherScreen(
          initialLat: extra?['lat'] as double?,
          initialLon: extra?['lon'] as double?,
          initialCity: extra?['city'] as String? ?? '',
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
      title: 'Tripia',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

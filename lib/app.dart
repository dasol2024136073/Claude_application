import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/welcome_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/my_routes_screen.dart';
import 'presentation/screens/community_screen.dart';
import 'presentation/screens/route_input_screen.dart';
import 'domain/models/trip_plan.dart';
import 'presentation/screens/route_result_screen.dart';
import 'presentation/screens/map_screen.dart';
import 'presentation/screens/weather_screen.dart';
import 'presentation/screens/mypage_screen.dart';
import 'presentation/screens/profile_edit_screen.dart';
import 'presentation/screens/personal_info_screen.dart';
import 'presentation/screens/notification_settings_screen.dart';
import 'presentation/screens/app_settings_screen.dart';
import 'presentation/screens/my_posts_screen.dart';
import 'presentation/screens/liked_posts_screen.dart';
import 'presentation/screens/simple_info_screen.dart';
import 'presentation/screens/review_editor_screen.dart';
import 'presentation/screens/review_view_screen.dart';
import 'presentation/screens/post_editor_screen.dart';
import 'presentation/screens/post_detail_screen.dart';
import 'domain/models/community_post.dart';
import 'presentation/widgets/main_shell.dart';
import 'data/services/trip_repository.dart';
import 'data/services/weather_service.dart';
import 'domain/models/review.dart';
import 'presentation/theme/app_theme.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, _) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, _) => const SignupScreen()),
    GoRoute(path: '/welcome', builder: (context, _) => const WelcomeScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingScreen(existingUser: state.extra as Map<String, dynamic>?),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (context, _) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/my-routes', builder: (context, _) => const MyRoutesScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/community', builder: (context, _) => const CommunityScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/mypage', builder: (context, _) => const MyPageScreen()),
        ]),
      ],
    ),
    GoRoute(
      path: '/route/input',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RouteInputScreen(
          initialDestination: extra?['destination'] as String?,
          initialDays: extra?['days'] as int?,
        );
      },
    ),
    GoRoute(
      path: '/route/result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return RouteResultScreen(
          destination: extra['destination'] as String,
          days: extra['days'] as int,
          tripPlan: extra['tripPlan'] as TripPlan?,
          weather: extra['weather'] as WeatherInfo?,
          tripId: extra['tripId'] as String?,
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
      path: '/review/edit',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ReviewEditorScreen(
          trip: extra['trip'] as SavedTrip,
          existingReview: extra['review'] as Review?,
        );
      },
    ),
    GoRoute(
      path: '/community/write',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return PostEditorScreen(
          category: extra['category'] as PostCategory,
          existingPost: extra['post'] as CommunityPost?,
        );
      },
    ),
    GoRoute(
      path: '/review/view',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ReviewViewScreen(
          trip: extra['trip'] as SavedTrip,
          review: extra['review'] as Review,
        );
      },
    ),
    GoRoute(
      path: '/community/post',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return PostDetailScreen(postId: extra['postId'] as String);
      },
    ),
    GoRoute(
      path: '/mypage/profile-edit',
      builder: (context, state) {
        final user = state.extra as Map<String, dynamic>;
        return ProfileEditScreen(user: user);
      },
    ),
    GoRoute(
      path: '/mypage/personal-info',
      builder: (context, state) {
        final user = state.extra as Map<String, dynamic>;
        return PersonalInfoScreen(user: user);
      },
    ),
    GoRoute(
      path: '/mypage/my-posts',
      builder: (context, state) {
        final email = state.extra as String;
        return MyPostsScreen(myEmail: email);
      },
    ),
    GoRoute(
      path: '/mypage/liked-posts',
      builder: (context, state) {
        final email = state.extra as String;
        return LikedPostsScreen(myEmail: email);
      },
    ),
    GoRoute(
      path: '/mypage/notifications',
      builder: (context, _) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/mypage/app-settings',
      builder: (context, _) => const AppSettingsScreen(),
    ),
    GoRoute(
      path: '/mypage/notice',
      builder: (context, _) => const SimpleInfoScreen(title: '공지사항', content: AppInfoContents.notice),
    ),
    GoRoute(
      path: '/mypage/terms',
      builder: (context, _) => const SimpleInfoScreen(title: '이용약관', content: AppInfoContents.terms),
    ),
    GoRoute(
      path: '/mypage/privacy',
      builder: (context, _) => const SimpleInfoScreen(title: '개인정보처리방침', content: AppInfoContents.privacy),
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

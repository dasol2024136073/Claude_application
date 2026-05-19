import 'package:flutter/material.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';

class TravelAiApp extends StatelessWidget {
  const TravelAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 여행 경로 추천',
      theme: AppTheme.light,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

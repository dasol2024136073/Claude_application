// UI 테스트: 화면 구성 요소가 올바르게 렌더링되는지 확인
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_ai/presentation/screens/login_screen.dart';

GoRouter _buildRouter() => GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, _) => const LoginScreen()),
        GoRoute(path: '/home', builder: (context, _) => const Scaffold(body: Text('홈'))),
        GoRoute(path: '/signup', builder: (context, _) => const Scaffold(body: Text('회원가입 화면'))),
      ],
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('로그인 화면에 앱 타이틀이 표시된다', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: _buildRouter()));
    await tester.pump();
    expect(find.text('Tripia'), findsOneWidget);
  });

  testWidgets('로그인 화면에 이메일·비밀번호 TextField가 2개 있다', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: _buildRouter()));
    await tester.pump();
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('로그인 화면에 로그인 FilledButton이 있다', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: _buildRouter()));
    await tester.pump();
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('로그인 화면에 회원가입 TextButton이 있다', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: _buildRouter()));
    await tester.pump();
    expect(find.text('회원가입'), findsOneWidget);
  });
}

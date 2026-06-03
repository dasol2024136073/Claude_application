import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_trip_data.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/gemini_service.dart';
import '../../data/services/trip_repository.dart';
import '../../data/services/weather_monitor_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SavedTrip> _trips = [];
  List<WeatherAlert> _weatherAlerts = [];
  String _userName = '';
  bool _loading = true;
  bool _checkingWeather = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    WeatherMonitorService.stopMonitoring();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.getCurrentUser();
    final trips = await TripRepository.getAll();
    if (!mounted) return;
    setState(() {
      _userName = user?['name'] ?? '여행자';
      _trips = trips;
      _loading = false;
    });
    _startWeatherMonitoring(trips);
  }

  void _startWeatherMonitoring(List<SavedTrip> trips) {
    if (trips.isEmpty) return;
    WeatherMonitorService.startMonitoring(trips, (alerts) {
      if (!mounted) return;
      setState(() => _weatherAlerts = alerts);
    });
  }

  Future<void> _manualWeatherCheck() async {
    if (_trips.isEmpty) return;
    setState(() => _checkingWeather = true);
    final alerts = await WeatherMonitorService.checkAll(_trips);
    if (!mounted) return;
    setState(() {
      _weatherAlerts = alerts;
      _checkingWeather = false;
    });
    if (alerts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('날씨 변화 없음 — 현재 경로가 최적입니다 ✓'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rerouteForWeather(WeatherAlert alert) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    messenger.showSnackBar(SnackBar(
      content: Text('${alert.newWeather.emoji} 새 경로 생성 중...'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 10),
    ));

    final plan = await GeminiService.generateTripPlan(
      alert.trip.plan.destination,
      alert.trip.plan.days,
      weather: alert.newWeather,
    ).catchError((_) => MockTripData.generate(
      alert.trip.plan.destination,
      alert.trip.plan.days,
    ));

    if (!mounted) return;
    messenger.hideCurrentSnackBar();

    // 알림 제거
    setState(() => _weatherAlerts.removeWhere((a) => a.trip.id == alert.trip.id));

    router.push('/route/result', extra: {
      'destination': alert.trip.plan.destination,
      'days': alert.trip.plan.days,
      'tripPlan': plan,
      'weather': alert.newWeather,
    });
  }

  Future<void> _delete(String id) async {
    final messenger = ScaffoldMessenger.of(context);
    await TripRepository.delete(id);
    final trips = await TripRepository.getAll();
    if (!mounted) return;
    setState(() {
      _trips = trips;
      _weatherAlerts.removeWhere((a) => a.trip.id == id);
    });
    messenger.showSnackBar(
      const SnackBar(content: Text('경로가 삭제되었습니다'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.explore, color: Color(0xFF4A90D9), size: 22),
            const SizedBox(width: 8),
            const Text('AI 여행', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (_trips.isNotEmpty)
            IconButton(
              icon: _checkingWeather
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4A90D9)),
                    )
                  : const Icon(Icons.cloud_sync_outlined),
              tooltip: '날씨 다시 확인',
              onPressed: _checkingWeather ? null : _manualWeatherCheck,
            ),
          GestureDetector(
            onTap: () async {
              final router = GoRouter.of(context);
              await AuthService.logout();
              if (!mounted) return;
              router.go('/');
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4A90D9),
              child: Text(
                _userName.isNotEmpty ? _userName[0] : '?',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GreetingCard(name: _userName),
                    const SizedBox(height: 20),
                    _NewTripCard(onTap: () async {
                      await context.push('/route/input');
                      _load();
                    }),
                    // 날씨 알림 카드
                    if (_weatherAlerts.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      ...List.generate(_weatherAlerts.length, (i) =>
                        _WeatherAlertCard(
                          alert: _weatherAlerts[i],
                          onReroute: () => _rerouteForWeather(_weatherAlerts[i]),
                          onDismiss: () => setState(() => _weatherAlerts.removeAt(i)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '저장된 경로',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                        ),
                        Text('${_trips.length}개', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_trips.isEmpty)
                      _EmptyRouteState()
                    else
                      ..._trips.map((trip) => _TripCard(
                            trip: trip,
                            hasAlert: _weatherAlerts.any((a) => a.trip.id == trip.id),
                            onTap: () => context.push('/route/result', extra: {
                              'destination': trip.plan.destination,
                              'days': trip.plan.days,
                              'tripPlan': trip.plan,
                            }),
                            onDelete: () => _delete(trip.id),
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── 날씨 알림 카드 ───────────────────────────────────────────
class _WeatherAlertCard extends StatelessWidget {
  final WeatherAlert alert;
  final VoidCallback onReroute;
  final VoidCallback onDismiss;

  const _WeatherAlertCard({
    required this.alert,
    required this.onReroute,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(alert.newWeather.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${alert.trip.plan.destination} 날씨 변화 감지',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.message,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 2),
                Text(
                  '현재: ${alert.newWeather.summary}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF4A90D9), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onReroute,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90D9),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('새 경로 받기', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─── 기존 위젯들 ───────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  final String name;
  const _GreetingCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90D9), Color(0xFF6BB3F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('안녕하세요, $name님 👋',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('오늘 어디로 떠나고 싶으신가요?',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 36),
        ],
      ),
    );
  }
}

class _NewTripCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NewTripCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_location_alt_outlined, color: Color(0xFF4A90D9), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('새 여행 경로 만들기',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  Text('AI가 취향에 맞는 동선을 10초 안에 설계합니다',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final SavedTrip trip;
  final bool hasAlert;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TripCard({required this.trip, required this.hasAlert, required this.onTap, required this.onDelete});

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(trip.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
        ),
        onDismissed: (_) => onDelete(),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: hasAlert ? Border.all(color: const Color(0xFFFFD54F), width: 1.5) : null,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF4A90D9), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(trip.plan.destination,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                          if (hasAlert) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFFD54F), borderRadius: BorderRadius.circular(6)),
                              child: const Text('날씨변화', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF795548))),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${trip.plan.days}박 ${trip.plan.days + 1}일 • ${_formatDate(trip.savedAt)} 저장',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyRouteState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(Icons.map_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('저장된 경로가 없습니다', style: TextStyle(fontSize: 14, color: Colors.grey[400], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('위 버튼으로 첫 번째 경로를 만들어보세요', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

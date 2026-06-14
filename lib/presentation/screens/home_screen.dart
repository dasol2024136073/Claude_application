import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/mock/mock_trip_data.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/gemini_service.dart';
import '../../data/services/recommendation_repository.dart';
import '../../data/services/trip_repository.dart';
import '../../data/services/weather_monitor_service.dart';
import '../../data/services/weather_service.dart';
import '../../domain/models/destination_recommendation.dart';

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
  WeatherInfo? _currentWeather;
  String _currentCity = '';
  double? _currentLat, _currentLon;
  bool _loadingWeather = false;
  List<DestinationRecommendation> _recommendations = [];
  bool _loadingRecommendations = true;
  bool _generatingNearby = false;

  @override
  void initState() {
    super.initState();
    _load();
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
    _loadCurrentWeather();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final user = await AuthService.getUserDetails();
    final recommendations = await RecommendationRepository.getOrFetch(
      travelStyles: (user?['travelStyles'] as List<dynamic>?)?.cast<String>() ?? [],
      budgets: (user?['budgets'] as List<dynamic>?)?.cast<String>() ?? [],
      companions: (user?['companions'] as List<dynamic>?)?.cast<String>() ?? [],
      regions: (user?['regions'] as List<dynamic>?)?.cast<String>() ?? [],
      intensities: (user?['intensities'] as List<dynamic>?)?.cast<String>() ?? [],
    );
    if (!mounted) return;
    setState(() {
      _recommendations = recommendations;
      _loadingRecommendations = false;
    });
  }

  Future<void> _loadCurrentWeather() async {
    if (!mounted) return;
    setState(() => _loadingWeather = true);
    try {
      final pos = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 10));
      final (weather, city) =
          await WeatherService.fetchByCoords(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _currentWeather = weather;
        _currentCity = city;
        _currentLat = pos.latitude;
        _currentLon = pos.longitude;
        _loadingWeather = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingWeather = false);
    }
  }

  Future<void> _generateNearbyNow() async {
    if (_currentCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('현재 위치를 확인할 수 없어요. 위치 권한을 허용해주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _generatingNearby = true);

    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final plan = await GeminiService.generateTripPlan(
      _currentCity,
      0,
      weather: _currentWeather,
      arrivalTime: currentTime,
      nearbyNow: true,
    ).catchError((_) => MockTripData.generate(_currentCity, 0));

    if (!mounted) return;
    setState(() => _generatingNearby = false);

    context.push('/route/result', extra: {
      'destination': _currentCity,
      'days': 0,
      'tripPlan': plan,
      'weather': _currentWeather,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.explore, color: Color(0xFF4F9D6E), size: 22),
            const SizedBox(width: 8),
            const Text('Tripia', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (_trips.isNotEmpty)
            IconButton(
              icon: _checkingWeather
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F9D6E)),
                    )
                  : const Icon(Icons.cloud_sync_outlined),
              tooltip: '날씨 다시 확인',
              onPressed: _checkingWeather ? null : _manualWeatherCheck,
            ),
          GestureDetector(
            onTap: () => context.go('/mypage'),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4F9D6E),
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
                    _GreetingCard(
                      name: _userName,
                      weather: _currentWeather,
                      city: _currentCity,
                      loadingWeather: _loadingWeather,
                      onTap: () => context.push('/weather', extra: {
                        'lat': _currentLat,
                        'lon': _currentLon,
                        'city': _currentCity,
                      }),
                    ),
                    const SizedBox(height: 20),
                    _NearbyNowCard(
                      city: _currentCity,
                      weather: _currentWeather,
                      loading: _generatingNearby,
                      onTap: _generatingNearby ? null : _generateNearbyNow,
                    ),
                    const SizedBox(height: 20),
                    _NewTripCard(onTap: () async {
                      await context.push('/route/input');
                      _load();
                    }),
                    const SizedBox(height: 24),
                    _RecommendedTripsSection(
                      loading: _loadingRecommendations,
                      recommendations: _recommendations,
                      onTapRecommendation: (rec) async {
                        await context.push('/route/input', extra: {
                          'destination': rec.destination,
                          'days': rec.days,
                        });
                        _load();
                      },
                    ),
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
                  style: const TextStyle(fontSize: 12, color: Color(0xFF4F9D6E), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onReroute,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4F9D6E),
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
  final WeatherInfo? weather;
  final String city;
  final bool loadingWeather;
  final VoidCallback onTap;

  const _GreetingCard({
    required this.name,
    required this.onTap,
    this.weather,
    this.city = '',
    this.loadingWeather = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F9D6E), Color(0xFF6BB3F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('안녕하세요, $name님 👋',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white54, size: 14),
              ],
            ),
            const SizedBox(height: 14),
            if (loadingWeather)
              Row(children: [
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)),
                const SizedBox(width: 8),
                Text('날씨 불러오는 중...',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13)),
              ])
            else if (weather != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(weather!.emoji,
                      style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${weather!.temp.round()}°C',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              height: 1)),
                      Text(weather!.descriptionKo,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14)),
                      if (city.isNotEmpty)
                        Text(city,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('탭하여 상세 날씨 보기 →',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11)),
            ] else ...[
              Row(children: [
                const Icon(Icons.location_off_outlined,
                    color: Colors.white54, size: 16),
                const SizedBox(width: 6),
                Text('위치 권한을 허용하거나 탭하여 도시 검색',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── AI 추천 여행지 섹션 ───────────────────────────────────────
class _RecommendedTripsSection extends StatelessWidget {
  final bool loading;
  final List<DestinationRecommendation> recommendations;
  final void Function(DestinationRecommendation) onTapRecommendation;

  const _RecommendedTripsSection({
    required this.loading,
    required this.recommendations,
    required this.onTapRecommendation,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '취향에 맞는 추천 여행지',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        const SizedBox(height: 4),
        Text(
          'AI가 회원님의 취향을 분석해 골랐어요',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final r = recommendations[i];
              return _RecommendationCard(
                recommendation: r,
                onTap: () => onTapRecommendation(r),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final DestinationRecommendation recommendation;
  final VoidCallback onTap;

  const _RecommendationCard({required this.recommendation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = recommendation;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 90,
              width: double.infinity,
              child: r.photoUrl != null
                  ? Image.network(
                      r.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _PhotoFallback(emoji: r.emoji),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: const Color(0xFFF0F0F0),
                          child: const Center(
                            child: SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                    )
                  : _PhotoFallback(emoji: r.emoji),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.destination,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${r.days}박 ${r.days + 1}일 추천',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF4F9D6E), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  final String emoji;
  const _PhotoFallback({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F9D6E), Color(0xFF6BB3F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 36)),
      ),
    );
  }
}

// ─── 지금 갈 수 있는 근교 코스 카드 ──────────────────────────────
class _NearbyNowCard extends StatelessWidget {
  final String city;
  final WeatherInfo? weather;
  final bool loading;
  final VoidCallback? onTap;

  const _NearbyNowCard({
    required this.city,
    required this.weather,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = city.isEmpty
        ? '위치 권한을 허용하면 현재 위치 기준으로 추천해드려요'
        : '$city ${weather != null ? '· ${weather!.summary}' : ''} · 지금 바로 떠날 수 있는 코스를 AI가 짜드려요';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9966), Color(0xFFFF5E62)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Icon(Icons.bolt, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loading ? 'AI가 근교 코스를 짜고 있어요...' : '지금 갈 수 있는 근교 코스 추천',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
            if (!loading) const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
          ],
        ),
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
                color: const Color(0xFF4F9D6E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_location_alt_outlined, color: Color(0xFF4F9D6E), size: 28),
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


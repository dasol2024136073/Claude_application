import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;
  final String initialCity;

  const WeatherScreen({
    super.key,
    this.initialLat,
    this.initialLon,
    this.initialCity = '',
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _searchCtrl = TextEditingController();
  WeatherForecast? _forecast;
  bool _loading = false;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLon != null) {
      _loadByCoords(widget.initialLat!, widget.initialLon!);
    } else if (widget.initialCity.isNotEmpty) {
      _loadByCity(widget.initialCity);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadByCoords(double lat, double lon) async {
    setState(() { _loading = true; _notFound = false; });
    final forecast = await WeatherService.fetchForecastByCoords(lat, lon);
    if (!mounted) return;
    setState(() { _forecast = forecast; _loading = false; _notFound = forecast == null; });
  }

  Future<void> _loadByCity(String city) async {
    if (city.trim().isEmpty) return;
    setState(() { _loading = true; _notFound = false; });
    final forecast = await WeatherService.fetchForecastByCity(city.trim());
    if (!mounted) return;
    setState(() { _forecast = forecast; _loading = false; _notFound = forecast == null; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _forecast != null ? '${_forecast!.city} 날씨' : '날씨',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchCtrl,
            onSearch: (city) {
              _searchCtrl.clear();
              _loadByCity(city);
            },
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _notFound
                    ? _NotFoundView()
                    : _forecast == null
                        ? _EmptyView()
                        : _WeatherContent(forecast: _forecast!),
          ),
        ],
      ),
    );
  }
}

// ─── 검색 바 ─────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  const _SearchBar({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSearch,
        decoration: InputDecoration(
          hintText: '도시 검색 (예: 도쿄, Paris, Bangkok)',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF4F9D6E)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send_rounded, color: Color(0xFF4F9D6E)),
            onPressed: () => onSearch(controller.text),
          ),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF4F9D6E), width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// ─── 날씨 전체 콘텐츠 ─────────────────────────────────────────
class _WeatherContent extends StatelessWidget {
  final WeatherForecast forecast;
  const _WeatherContent({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CurrentWeatherCard(forecast: forecast),
          const SizedBox(height: 20),
          _SectionHeader(title: '시간별 날씨', subtitle: '3시간 간격 · 30시간'),
          const SizedBox(height: 10),
          _HourlyRow(hourly: forecast.hourly),
          const SizedBox(height: 20),
          _SectionHeader(title: '5일 예보'),
          const SizedBox(height: 10),
          _DailyList(daily: forecast.daily),
        ],
      ),
    );
  }
}

// ─── 현재 날씨 카드 ───────────────────────────────────────────
class _CurrentWeatherCard extends StatelessWidget {
  final WeatherForecast forecast;
  const _CurrentWeatherCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final w = forecast.current;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          Text(forecast.city,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(w.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${w.temp.round()}°C',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          height: 1)),
                  Text(w.descriptionKo,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 시간별 날씨 가로 스크롤 ──────────────────────────────────
class _HourlyRow extends StatelessWidget {
  final List<HourlyWeather> hourly;
  const _HourlyRow({required this.hourly});

  String _timeLabel(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final item = hourly[i];
          final isFirst = i == 0;
          return Container(
            width: 76,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isFirst
                  ? const Color(0xFF4F9D6E).withValues(alpha: 0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: isFirst
                  ? Border.all(color: const Color(0xFF4F9D6E), width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8)
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(_timeLabel(item.time),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        color: isFirst
                            ? const Color(0xFF4F9D6E)
                            : Colors.grey[500],
                        fontWeight: isFirst
                            ? FontWeight.w700
                            : FontWeight.normal)),
                Text(item.emoji, style: const TextStyle(fontSize: 20)),
                Text('${item.temp.round()}°',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isFirst
                            ? const Color(0xFF4F9D6E)
                            : const Color(0xFF1A1A2E))),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── 일별 예보 리스트 ─────────────────────────────────────────
class _DailyList extends StatelessWidget {
  final List<DailyWeather> daily;
  const _DailyList({required this.daily});

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  String _dayLabel(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '오늘';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (dt.year == tomorrow.year &&
        dt.month == tomorrow.month &&
        dt.day == tomorrow.day) {
      return '내일';
    }
    return '${_weekdays[dt.weekday - 1]}요일';
  }

  String _dateLabel(DateTime dt) =>
      '${dt.month}월 ${dt.day}일';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
        ],
      ),
      child: Column(
        children: List.generate(daily.length, (i) {
          final item = daily[i];
          final isLast = i == daily.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_dayLabel(item.date),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E))),
                          Text(_dateLabel(item.date),
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(item.emoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.description,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[600])),
                    ),
                    Row(
                      children: [
                        Text('${item.tempMin.round()}°',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[300],
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Text('/',
                            style:
                                TextStyle(fontSize: 13, color: Colors.grey[300])),
                        const SizedBox(width: 4),
                        Text('${item.tempMax.round()}°',
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFE8734A),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey[100])
            else
              const SizedBox.shrink(),
            ],
          );
        }),
      ),
    );
  }
}

// ─── 섹션 헤더 ───────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E))),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(subtitle!,
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ],
    );
  }
}

// ─── 빈 화면 / 오류 화면 ──────────────────────────────────────
class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text('도시를 검색해보세요',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 6),
          Text('예: 도쿄, 파리, Bangkok',
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text('도시를 찾을 수 없습니다',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 6),
          Text('다른 도시 이름으로 다시 검색해주세요',
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

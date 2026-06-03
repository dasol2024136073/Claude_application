import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_trip_data.dart';
import '../../data/services/trip_repository.dart';
import '../../data/services/weather_service.dart';
import '../../domain/models/trip_plan.dart';

class RouteResultScreen extends StatefulWidget {
  final String destination;
  final int days;
  final TripPlan? tripPlan;
  final WeatherInfo? weather;

  const RouteResultScreen({
    super.key,
    required this.destination,
    required this.days,
    this.tripPlan,
    this.weather,
  });

  @override
  State<RouteResultScreen> createState() => _RouteResultScreenState();
}

class _RouteResultScreenState extends State<RouteResultScreen> {
  bool _saved = false;
  bool _saving = false;

  static const _categoryColors = {
    '관광': Color(0xFF4A90D9),
    '맛집': Color(0xFFE8734A),
    '맛집·관광': Color(0xFFE8734A),
    '맛집·카페': Color(0xFFE8734A),
    '카페': Color(0xFF8B5CF6),
    '카페·쇼핑': Color(0xFF8B5CF6),
    '쇼핑': Color(0xFFEC4899),
    '자연': Color(0xFF22C55E),
    '자연·문화': Color(0xFF22C55E),
    '역사·문화': Color(0xFF92400E),
    '문화': Color(0xFF7C3AED),
    '문화·쇼핑': Color(0xFF7C3AED),
    '전망대': Color(0xFF0EA5E9),
    '시장': Color(0xFFF59E0B),
    '시장·맛집': Color(0xFFF59E0B),
    '테마파크': Color(0xFFEF4444),
  };

  Color _colorFor(String category) {
    for (final entry in _categoryColors.entries) {
      if (category.contains(entry.key)) return entry.value;
    }
    return const Color(0xFF64748B);
  }

  Future<void> _savePlan(TripPlan plan) async {
    setState(() => _saving = true);
    try {
      await TripRepository.save(plan, weatherCondition: widget.weather?.condition);
      if (!mounted) return;
      setState(() {
        _saved = true;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('경로가 저장되었습니다'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장에 실패했습니다. 다시 시도해주세요'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.tripPlan ?? MockTripData.generate(widget.destination, widget.days);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '${plan.destination} ${plan.days}박 ${plan.days + 1}일',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: '지도로 보기',
            onPressed: () => context.push('/route/map', extra: plan),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _AiBadgeBar(weather: widget.weather),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: plan.dayPlans.length,
              itemBuilder: (context, index) {
                return _DayCard(
                  dayPlan: plan.dayPlans[index],
                  colorFor: _colorFor,
                );
              },
            ),
          ),
          _SaveBar(
            saved: _saved,
            saving: _saving,
            onSave: () => _savePlan(plan),
          ),
        ],
      ),
    );
  }
}

class _AiBadgeBar extends StatelessWidget {
  final WeatherInfo? weather;
  const _AiBadgeBar({this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFFF0F6FF),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('AI 생성', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          if (weather != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${weather!.emoji} ${weather!.summary}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              weather != null ? '실시간 날씨 반영 경로' : 'AI 취향 맞춤 경로',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DayPlan dayPlan;
  final Color Function(String) colorFor;

  const _DayCard({required this.dayPlan, required this.colorFor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Day ${dayPlan.day}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${dayPlan.places.length}곳 방문',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: List.generate(dayPlan.places.length, (i) {
                final place = dayPlan.places[i];
                final isLast = i == dayPlan.places.length - 1;
                return _PlaceRow(
                  place: place,
                  isLast: isLast,
                  color: colorFor(place.category),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final PlaceItem place;
  final bool isLast;
  final Color color;

  const _PlaceRow({required this.place, required this.isLast, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    place.time,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A90D9)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 36,
                      color: const Color(0xFFE8E8E8),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            place.category,
                            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[100]),
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  final bool saved;
  final bool saving;
  final VoidCallback onSave;

  const _SaveBar({required this.saved, required this.saving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: (saved || saving) ? null : onSave,
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Icon(saved ? Icons.check_circle : Icons.bookmark_add_outlined),
          label: Text(
            saved ? '저장 완료' : (saving ? '저장 중...' : '내 경로로 저장'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: saved ? Colors.grey[400] : const Color(0xFF4A90D9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}

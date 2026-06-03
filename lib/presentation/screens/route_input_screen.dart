import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_trip_data.dart';
import '../../data/services/gemini_service.dart';
import '../../data/services/weather_service.dart';

class RouteInputScreen extends StatefulWidget {
  const RouteInputScreen({super.key});

  @override
  State<RouteInputScreen> createState() => _RouteInputScreenState();
}

class _RouteInputScreenState extends State<RouteInputScreen> {
  final _controller = TextEditingController();
  int _days = 3;
  bool _isLoading = false;
  String _loadingMessage = '';
  WeatherInfo? _weather;

  static const _quickDestinations = ['오사카', '도쿄', '제주도', '파리', '방콕', '다낭'];

  Future<void> _generate() async {
    final destination = _controller.text.trim();
    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('여행지를 입력해주세요'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() { _isLoading = true; _loadingMessage = '날씨 정보 확인 중...'; });

    final weather = await WeatherService.fetch(destination);

    if (!mounted) return;
    setState(() { _weather = weather; _loadingMessage = 'AI가 경로를 설계하는 중...'; });

    final plan = await GeminiService.generateTripPlan(destination, _days, weather: weather)
        .catchError((_) => MockTripData.generate(destination, _days));

    if (!mounted) return;
    context.push('/route/result', extra: {
      'destination': destination,
      'days': _days,
      'tripPlan': plan,
      'weather': weather,
    });
    setState(() { _isLoading = false; _weather = null; });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('새 여행 경로', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '어디로 여행하시나요?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 6),
            Text(
              'AI가 취향 프로필을 반영해 최적 동선을 설계합니다',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '예: 오사카, 제주도, 파리...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4A90D9)),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _generate(),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickDestinations.map((dest) {
                return GestureDetector(
                  onTap: () => setState(() => _controller.text = dest),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFCCDEF7)),
                    ),
                    child: Text(
                      dest,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF4A90D9), fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            const Text(
              '여행 기간',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 4),
            Text(
              '총 $_days박 ${_days + 1}일',
              style: const TextStyle(fontSize: 14, color: Color(0xFF4A90D9), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(7, (i) {
                final day = i + 1;
                final selected = _days == day;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 6 ? 6 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _days = day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF4A90D9) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? const Color(0xFF4A90D9) : const Color(0xFFE8E8E8),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: selected ? Colors.white : const Color(0xFF4A4A4A),
                              ),
                            ),
                            Text(
                              '박',
                              style: TextStyle(
                                fontSize: 9,
                                color: selected ? Colors.white.withValues(alpha: 0.8) : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            if (_weather != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCCDEF7)),
                ),
                child: Row(
                  children: [
                    Text(_weather!.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '현재 날씨: ${_weather!.summary}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                        ),
                        Text(
                          '날씨를 반영한 경로로 설계합니다',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isLoading ? null : _generate,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _loadingMessage,
                            style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.9)),
                          ),
                        ],
                      )
                    : const Text('AI 경로 생성', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

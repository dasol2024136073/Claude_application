import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_trip_data.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/gemini_service.dart';
import '../../data/services/weather_service.dart';
import '../../domain/models/trip_plan.dart';
import '../theme/app_theme.dart';

class RouteInputScreen extends StatefulWidget {
  final String? initialDestination;
  final int? initialDays;

  const RouteInputScreen({super.key, this.initialDestination, this.initialDays});

  @override
  State<RouteInputScreen> createState() => _RouteInputScreenState();
}

class _RouteInputScreenState extends State<RouteInputScreen> {
  final _controller = TextEditingController();
  final _accommodationController = TextEditingController();
  late DateTimeRange _dateRange;
  TimeOfDay? _arrivalTime;
  TimeOfDay? _departureTime;
  bool _isLoading = false;
  bool _detailsExpanded = false;
  bool _filterExpanded = false;
  String _loadingMessage = '';
  WeatherInfo? _weather;

  final Set<int> _selectedStyles = {};
  final Set<int> _selectedBudgets = {};
  final Set<int> _selectedCompanions = {};
  final Set<int> _selectedRegions = {};
  final Set<int> _selectedIntensities = {};
  int? _selectedIndoorOutdoor;

  static const _quickDestinations = ['오사카', '도쿄', '제주도', '파리', '방콕', '다낭'];

  static const _styles = [
    (emoji: '🌿', label: '자연·힐링'),
    (emoji: '🏙️', label: '도시·쇼핑'),
    (emoji: '🍜', label: '맛집·카페'),
    (emoji: '🏯', label: '역사·문화'),
  ];
  static const _budgets = ['알뜰 여행', '여유 있게', '럭셔리'];
  static const _companions = ['혼자', '커플', '가족', '친구들'];
  static const _regions = ['아시아', '유럽', '북미·중남미', '오세아니아·기타'];
  static const _intensities = ['느긋한 휴양형', '알차게 액티비티형'];
  static const _indoorOutdoorOptions = ['실내 위주', '실외 위주', '상관없음'];

  int get _days => _dateRange.end.difference(_dateRange.start).inDays;

  @override
  void initState() {
    super.initState();
    if (widget.initialDestination != null) {
      _controller.text = widget.initialDestination!;
    }
    final today = DateTime.now();
    final days = widget.initialDays ?? 3;
    _dateRange = DateTimeRange(start: today, end: today.add(Duration(days: days)));
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final user = await AuthService.getUserDetails();
    if (!mounted || user == null) return;
    setState(() {
      _restoreSelection(user['travelStyles'], _styles.map((s) => s.label).toList(), _selectedStyles);
      _restoreSelection(user['budgets'], _budgets, _selectedBudgets);
      _restoreSelection(user['companions'], _companions, _selectedCompanions);
      _restoreSelection(user['regions'], _regions, _selectedRegions);
      _restoreSelection(user['intensities'], _intensities, _selectedIntensities);
    });
  }

  void _restoreSelection(dynamic saved, List<String> options, Set<int> target) {
    if (saved is! List) return;
    final values = saved.cast<String>();
    for (var i = 0; i < options.length; i++) {
      if (values.contains(options[i])) target.add(i);
    }
  }

  String _formatDate(DateTime d) => '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );
    if (picked == null) return;
    if (!mounted) return;
    final days = picked.end.difference(picked.start).inDays;
    if (days < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1박 이상으로 선택해주세요'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _dateRange = picked);
  }

  Future<void> _pickTime(bool isArrival) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isArrival ? _arrivalTime : _departureTime) ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked == null) return;
    setState(() {
      if (isArrival) {
        _arrivalTime = picked;
      } else {
        _departureTime = picked;
      }
    });
  }

  Future<void> _generate() async {
    final destination = _controller.text.trim();
    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('여행지를 입력해주세요'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final days = _days;
    final arrivalTime = _arrivalTime != null ? _formatTime(_arrivalTime!) : null;
    final departureTime = _departureTime != null ? _formatTime(_departureTime!) : null;
    final accommodation = _accommodationController.text.trim().isEmpty ? null : _accommodationController.text.trim();

    setState(() { _isLoading = true; _loadingMessage = '날씨 정보 확인 중...'; });

    final weather = await WeatherService.fetch(destination);

    if (!mounted) return;
    setState(() { _weather = weather; _loadingMessage = 'AI가 경로를 설계하는 중...'; });

    final plan = await GeminiService.generateTripPlan(
      destination,
      days,
      weather: weather,
      arrivalTime: arrivalTime,
      departureTime: departureTime,
      accommodation: accommodation,
      travelStyles: _selectedStyles.map((i) => _styles[i].label).toList(),
      budgets: _selectedBudgets.map((i) => _budgets[i]).toList(),
      companions: _selectedCompanions.map((i) => _companions[i]).toList(),
      regions: _selectedRegions.map((i) => _regions[i]).toList(),
      intensities: _selectedIntensities.map((i) => _intensities[i]).toList(),
      indoorOutdoor: _selectedIndoorOutdoor != null ? _indoorOutdoorOptions[_selectedIndoorOutdoor!] : null,
    ).catchError((_) => MockTripData.generate(destination, days));

    final finalPlan = TripPlan(
      destination: plan.destination,
      days: plan.days,
      dayPlans: plan.dayPlans,
      startDate: _dateRange.start,
      endDate: _dateRange.end,
      arrivalTime: arrivalTime,
      departureTime: departureTime,
      accommodation: accommodation,
    );

    if (!mounted) return;
    context.push('/route/result', extra: {
      'destination': destination,
      'days': days,
      'tripPlan': finalPlan,
      'weather': weather,
    });
    setState(() { _isLoading = false; _weather = null; });
  }

  @override
  void dispose() {
    _controller.dispose();
    _accommodationController.dispose();
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
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4F9D6E)),
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
                  borderSide: const BorderSide(color: Color(0xFF4F9D6E), width: 2),
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
                      style: const TextStyle(fontSize: 13, color: Color(0xFF4F9D6E), fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            const Text(
              '여행 날짜',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDateRange,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, color: AppTheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_formatDate(_dateRange.start)} ~ ${_formatDate(_dateRange.end)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                      ),
                    ),
                    Text(
                      '$_days박 ${_days + 1}일',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF4F9D6E), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => setState(() => _filterExpanded = !_filterExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.tune, size: 18, color: Color(0xFF4F9D6E)),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'AI 추천 취향 필터',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                      ),
                    ),
                    Text(
                      '이번만 변경',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _filterExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[500],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '내 취향 설정이 기본 적용돼요. 이번 검색에만 다르게 적용하려면 펼쳐서 변경하세요',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            if (_filterExpanded) ...[
              const SizedBox(height: 16),
              _FilterSection(
                title: '여행 스타일',
                children: List.generate(_styles.length, (i) {
                  final selected = _selectedStyles.contains(i);
                  return _FilterChoiceChip(
                    label: '${_styles[i].emoji} ${_styles[i].label}',
                    selected: selected,
                    onTap: () => setState(() {
                      selected ? _selectedStyles.remove(i) : _selectedStyles.add(i);
                    }),
                  );
                }),
              ),
              const SizedBox(height: 16),
              _FilterSection(
                title: '예산 규모',
                children: List.generate(_budgets.length, (i) {
                  final selected = _selectedBudgets.contains(i);
                  return _FilterChoiceChip(
                    label: _budgets[i],
                    selected: selected,
                    onTap: () => setState(() {
                      selected ? _selectedBudgets.remove(i) : _selectedBudgets.add(i);
                    }),
                  );
                }),
              ),
              const SizedBox(height: 16),
              _FilterSection(
                title: '동행 유형',
                children: List.generate(_companions.length, (i) {
                  final selected = _selectedCompanions.contains(i);
                  return _FilterChoiceChip(
                    label: _companions[i],
                    selected: selected,
                    onTap: () => setState(() {
                      selected ? _selectedCompanions.remove(i) : _selectedCompanions.add(i);
                    }),
                  );
                }),
              ),
              const SizedBox(height: 16),
              _FilterSection(
                title: '선호 지역',
                children: List.generate(_regions.length, (i) {
                  final selected = _selectedRegions.contains(i);
                  return _FilterChoiceChip(
                    label: _regions[i],
                    selected: selected,
                    onTap: () => setState(() {
                      selected ? _selectedRegions.remove(i) : _selectedRegions.add(i);
                    }),
                  );
                }),
              ),
              const SizedBox(height: 16),
              _FilterSection(
                title: '여행 강도',
                children: List.generate(_intensities.length, (i) {
                  final selected = _selectedIntensities.contains(i);
                  return _FilterChoiceChip(
                    label: _intensities[i],
                    selected: selected,
                    onTap: () => setState(() {
                      selected ? _selectedIntensities.remove(i) : _selectedIntensities.add(i);
                    }),
                  );
                }),
              ),
              const SizedBox(height: 16),
              _FilterSection(
                title: '실내·실외 선호',
                children: List.generate(_indoorOutdoorOptions.length, (i) {
                  final selected = _selectedIndoorOutdoor == i;
                  return _FilterChoiceChip(
                    label: _indoorOutdoorOptions[i],
                    selected: selected,
                    onTap: () => setState(() {
                      _selectedIndoorOutdoor = selected ? null : i;
                    }),
                  );
                }),
              ),
            ],
            const SizedBox(height: 24),
            InkWell(
              onTap: () => setState(() => _detailsExpanded = !_detailsExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      '상세 설정 (선택)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _detailsExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[500],
                    ),
                  ],
                ),
              ),
            ),
            if (_detailsExpanded) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TimePickerField(
                      label: '입국 시간',
                      time: _arrivalTime,
                      formatTime: _formatTime,
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TimePickerField(
                      label: '출국 시간',
                      time: _departureTime,
                      formatTime: _formatTime,
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accommodationController,
                decoration: InputDecoration(
                  labelText: '숙소 위치',
                  hintText: '예: 신주쿠역 인근 호텔',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.hotel, color: Color(0xFF4F9D6E)),
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
                    borderSide: const BorderSide(color: Color(0xFF4F9D6E), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '입국·출국 시간과 숙소 위치를 반영해 동선을 더 정밀하게 설계합니다',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
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

class _FilterSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FilterSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }
}

class _FilterChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChoiceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4F9D6E) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF4F9D6E) : const Color(0xFFE8E8E8),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.white : const Color(0xFF4A4A4A),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final String Function(TimeOfDay) formatTime;
  final VoidCallback onTap;

  const _TimePickerField({required this.label, required this.time, required this.formatTime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Color(0xFF4F9D6E)),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              time != null ? formatTime(time!) : '선택 안 함',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: time != null ? const Color(0xFF1A1A2E) : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

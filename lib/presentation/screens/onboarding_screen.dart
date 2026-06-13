import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  /// 마이페이지에서 편집할 때 기존 사용자 정보를 전달 (수정 모드)
  final Map<String, dynamic>? existingUser;

  const OnboardingScreen({super.key, this.existingUser});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Set<int> _selectedStyles = {};
  final Set<int> _selectedBudgets = {};
  final Set<int> _selectedCompanions = {};
  final Set<int> _selectedRegions = {};
  final Set<int> _selectedIntensities = {};
  bool _saving = false;

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

  bool get _isEditMode => widget.existingUser != null;

  @override
  void initState() {
    super.initState();
    final user = widget.existingUser;
    if (user == null) return;

    _restoreSelection(user['travelStyles'], _styles.map((s) => s.label).toList(), _selectedStyles);
    _restoreSelection(user['budgets'], _budgets, _selectedBudgets);
    _restoreSelection(user['companions'], _companions, _selectedCompanions);
    _restoreSelection(user['regions'], _regions, _selectedRegions);
    _restoreSelection(user['intensities'], _intensities, _selectedIntensities);
  }

  void _restoreSelection(dynamic saved, List<String> options, Set<int> target) {
    if (saved is! List) return;
    final values = saved.cast<String>();
    for (var i = 0; i < options.length; i++) {
      if (values.contains(options[i])) target.add(i);
    }
  }

  Future<void> _submit() async {
    setState(() => _saving = true);

    await AuthService.updatePreferences(
      travelStyles: _selectedStyles.map((i) => _styles[i].label).toList(),
      budgets: _selectedBudgets.map((i) => _budgets[i]).toList(),
      companions: _selectedCompanions.map((i) => _companions[i]).toList(),
      regions: _selectedRegions.map((i) => _regions[i]).toList(),
      intensities: _selectedIntensities.map((i) => _intensities[i]).toList(),
    );

    if (!mounted) return;

    if (_isEditMode) {
      context.pop(true);
    } else {
      await AuthService.completeOnboarding();
      if (!mounted) return;
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('여행 취향 설정', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: _isEditMode,
        leading: _isEditMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '여러 개를 선택할 수 있어요',
              style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            _SectionTitle(
              step: '01',
              title: '여행 스타일',
              subtitle: '좋아하는 유형을 모두 선택하세요',
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.4,
              children: List.generate(_styles.length, (i) {
                final selected = _selectedStyles.contains(i);
                return _StyleCard(
                  emoji: _styles[i].emoji,
                  label: _styles[i].label,
                  selected: selected,
                  onTap: () => setState(() {
                    selected ? _selectedStyles.remove(i) : _selectedStyles.add(i);
                  }),
                );
              }),
            ),
            const SizedBox(height: 32),
            _SectionTitle(
              step: '02',
              title: '예산 규모',
              subtitle: '1인 기준 하루 평균 예산 (복수 선택 가능)',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_budgets.length, (i) {
                final selected = _selectedBudgets.contains(i);
                return _ChoiceChip(
                  label: _budgets[i],
                  selected: selected,
                  onTap: () => setState(() {
                    selected ? _selectedBudgets.remove(i) : _selectedBudgets.add(i);
                  }),
                );
              }),
            ),
            const SizedBox(height: 32),
            _SectionTitle(
              step: '03',
              title: '동행 유형',
              subtitle: '주로 어떻게 여행하시나요? (복수 선택 가능)',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_companions.length, (i) {
                final selected = _selectedCompanions.contains(i);
                return _ChoiceChip(
                  label: _companions[i],
                  selected: selected,
                  onTap: () => setState(() {
                    selected ? _selectedCompanions.remove(i) : _selectedCompanions.add(i);
                  }),
                );
              }),
            ),
            const SizedBox(height: 32),
            _SectionTitle(
              step: '04',
              title: '선호 지역',
              subtitle: '관심 있는 여행 지역을 선택하세요',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_regions.length, (i) {
                final selected = _selectedRegions.contains(i);
                return _ChoiceChip(
                  label: _regions[i],
                  selected: selected,
                  onTap: () => setState(() {
                    selected ? _selectedRegions.remove(i) : _selectedRegions.add(i);
                  }),
                );
              }),
            ),
            const SizedBox(height: 32),
            _SectionTitle(
              step: '05',
              title: '여행 강도',
              subtitle: '선호하는 일정의 밀도를 선택하세요',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_intensities.length, (i) {
                final selected = _selectedIntensities.contains(i);
                return _ChoiceChip(
                  label: _intensities[i],
                  selected: selected,
                  onTap: () => setState(() {
                    selected ? _selectedIntensities.remove(i) : _selectedIntensities.add(i);
                  }),
                );
              }),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        _isEditMode ? '저장하기' : '설정 완료 — 시작하기',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;

  const _SectionTitle({required this.step, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF4F9D6E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            ],
          ),
        ),
      ],
    );
  }
}

class _StyleCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4F9D6E).withValues(alpha: 0.1) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF4F9D6E) : const Color(0xFFE8E8E8),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? const Color(0xFF4F9D6E) : const Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
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
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.white : const Color(0xFF4A4A4A),
            ),
          ),
        ),
      ),
    );
  }
}

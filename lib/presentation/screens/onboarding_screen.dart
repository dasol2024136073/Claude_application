import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Set<int> _selectedStyles = {};
  int _budgetIndex = 1;
  int _companionIndex = 0;

  static const _styles = [
    (emoji: '🌿', label: '자연·힐링'),
    (emoji: '🏙️', label: '도시·쇼핑'),
    (emoji: '🍜', label: '맛집·카페'),
    (emoji: '🏯', label: '역사·문화'),
  ];

  static const _budgets = ['알뜰 여행', '여유 있게', '럭셔리'];
  static const _companions = ['혼자', '커플', '가족', '친구들'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('여행 취향 설정', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              subtitle: '1인 기준 하루 평균 예산',
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(_budgets.length, (i) {
                final selected = _budgetIndex == i;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < _budgets.length - 1 ? 8 : 0),
                    child: _ChoiceChip(
                      label: _budgets[i],
                      selected: selected,
                      onTap: () => setState(() => _budgetIndex = i),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            _SectionTitle(
              step: '03',
              title: '동행 유형',
              subtitle: '주로 어떻게 여행하시나요?',
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(_companions.length, (i) {
                final selected = _companionIndex == i;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < _companions.length - 1 ? 8 : 0),
                    child: _ChoiceChip(
                      label: _companions[i],
                      selected: selected,
                      onTap: () => setState(() => _companionIndex = i),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => context.go('/home'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('설정 완료 — 시작하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            color: const Color(0xFF4A90D9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ],
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
          color: selected ? const Color(0xFF4A90D9).withValues(alpha: 0.1) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF4A90D9) : const Color(0xFFE8E8E8),
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
                color: selected ? const Color(0xFF4A90D9) : const Color(0xFF4A4A4A),
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
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4A90D9) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF4A90D9) : const Color(0xFFE8E8E8),
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

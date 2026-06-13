import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PersonalInfoScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const PersonalInfoScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRow>[
      _InfoRow(icon: Icons.person_outline, label: '이름', value: user['name'] as String? ?? '-'),
      _InfoRow(icon: Icons.email_outlined, label: '이메일', value: user['email'] as String? ?? '-'),
    ];

    final gender = user['gender'] as String?;
    rows.add(_InfoRow(icon: Icons.wc_outlined, label: '성별', value: (gender != null && gender.isNotEmpty) ? gender : '-'));

    final phone = user['phone'] as String?;
    rows.add(_InfoRow(icon: Icons.phone_outlined, label: '전화번호', value: (phone != null && phone.isNotEmpty) ? phone : '-'));

    final birth = user['birthDate'] as String?;
    rows.add(_InfoRow(icon: Icons.cake_outlined, label: '생년월일', value: (birth != null && birth.isNotEmpty) ? birth : '-'));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('내 개인정보', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: List.generate(rows.length, (i) => Column(
              children: [
                rows[i],
                if (i < rows.length - 1)
                  Divider(height: 1, color: Colors.grey[100], indent: 56),
              ],
            )),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF4F9D6E)),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }
}

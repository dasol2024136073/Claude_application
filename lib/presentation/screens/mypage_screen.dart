import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.getUserDetails();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _changePassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? errorMsg;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('비밀번호 변경', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: '현재 비밀번호', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: '새 비밀번호', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: '새 비밀번호 확인', border: OutlineInputBorder()),
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 10),
                Text(errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                if (newCtrl.text.length < 6) {
                  setDialogState(() => errorMsg = '새 비밀번호는 6자 이상이어야 합니다');
                  return;
                }
                if (newCtrl.text != confirmCtrl.text) {
                  setDialogState(() => errorMsg = '새 비밀번호가 일치하지 않습니다');
                  return;
                }
                final messenger = ScaffoldMessenger.of(context);
                final result = await AuthService.changePassword(currentCtrl.text, newCtrl.text);
                if (!ctx.mounted) return;
                if (result.success) {
                  Navigator.pop(ctx);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('비밀번호가 변경되었습니다'), behavior: SnackBarBehavior.floating),
                  );
                } else {
                  setDialogState(() => errorMsg = result.error);
                }
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4A90D9)),
              child: const Text('변경'),
            ),
          ],
        ),
      ),
    );

    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService.logout();
      if (!mounted) return;
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('마이페이지', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('사용자 정보를 불러올 수 없습니다'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _ProfileHeader(user: _user!),
                      const SizedBox(height: 24),
                      _InfoCard(user: _user!),
                      const SizedBox(height: 24),
                      _ChangePasswordButton(onTap: _changePassword),
                      const SizedBox(height: 12),
                      _LogoutButton(onTap: _logout),
                    ],
                  ),
                ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = (user['name'] as String? ?? '').trim();
    final initial = name.isNotEmpty ? name[0] : '?';

    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: const Color(0xFF4A90D9),
          child: Text(
            initial,
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        const SizedBox(height: 4),
        Text(
          user['email'] as String? ?? '',
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Map<String, dynamic> user;
  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRow>[];

    final gender = user['gender'] as String?;
    if (gender != null && gender.isNotEmpty) {
      rows.add(_InfoRow(icon: Icons.person_outline, label: '성별', value: gender));
    }

    final phone = user['phone'] as String?;
    if (phone != null && phone.isNotEmpty) {
      rows.add(_InfoRow(icon: Icons.phone_outlined, label: '전화번호', value: phone));
    }

    final birth = user['birthDate'] as String?;
    if (birth != null && birth.isNotEmpty) {
      rows.add(_InfoRow(icon: Icons.cake_outlined, label: '생년월일', value: birth));
    }

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
          Icon(icon, size: 22, color: const Color(0xFF4A90D9)),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }
}

class _ChangePasswordButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ChangePasswordButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.lock_outline, size: 18),
        label: const Text('비밀번호 변경'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4A90D9),
          side: const BorderSide(color: Color(0xFF4A90D9)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('로그아웃'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

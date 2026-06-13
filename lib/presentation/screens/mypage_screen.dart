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

  Future<void> _editProfile() async {
    final result = await context.push('/mypage/profile-edit', extra: _user);
    if (result == true) _load();
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
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F9D6E)),
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

  Future<void> _deleteAccount() async {
    final passwordCtrl = TextEditingController();
    String? errorMsg;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('계정 삭제', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('계정을 삭제하면 되돌릴 수 없습니다.\n계속하려면 비밀번호를 입력해주세요.'),
              const SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: '비밀번호', border: OutlineInputBorder()),
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 10),
                Text(errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                final result = await AuthService.deleteAccount(passwordCtrl.text);
                if (!ctx.mounted) return;
                if (result.success) {
                  Navigator.pop(ctx, true);
                } else {
                  setDialogState(() => errorMsg = result.error);
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        ),
      ),
    );

    passwordCtrl.dispose();

    if (confirmed == true) {
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
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('사용자 정보를 불러올 수 없습니다'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _ProfileCard(user: _user!, onTap: _editProfile),
                      const SizedBox(height: 20),
                      _SectionLabel('나의 활동'),
                      _GroupCard(rows: [
                        _MenuRow(
                          icon: Icons.map_outlined,
                          label: '내가 저장한 경로',
                          onTap: () => context.go('/my-routes'),
                        ),
                        _MenuRow(
                          icon: Icons.article_outlined,
                          label: '내가 작성한 게시물·댓글',
                          onTap: () => context.push('/mypage/my-posts', extra: _user!['email']),
                        ),
                        _MenuRow(
                          icon: Icons.favorite_border,
                          label: '좋아요 누른 게시물·댓글',
                          onTap: () => context.push('/mypage/liked-posts', extra: _user!['email']),
                        ),
                        _MenuRow(
                          icon: Icons.tune,
                          label: '여행 취향 설정',
                          onTap: () async {
                            final result = await context.push('/onboarding', extra: _user);
                            if (result == true) _load();
                          },
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _SectionLabel('설정'),
                      _GroupCard(rows: [
                        _MenuRow(
                          icon: Icons.notifications_outlined,
                          label: '알림 설정',
                          onTap: () => context.push('/mypage/notifications'),
                        ),
                        _MenuRow(
                          icon: Icons.settings_outlined,
                          label: '앱 설정',
                          onTap: () => context.push('/mypage/app-settings'),
                        ),
                        _MenuRow(
                          icon: Icons.lock_outline,
                          label: '비밀번호 변경',
                          onTap: _changePassword,
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _SectionLabel('정보'),
                      _GroupCard(rows: [
                        _MenuRow(
                          icon: Icons.badge_outlined,
                          label: '내 개인정보',
                          onTap: () => context.push('/mypage/personal-info', extra: _user!),
                        ),
                        _MenuRow(
                          icon: Icons.campaign_outlined,
                          label: '공지사항',
                          onTap: () => context.push('/mypage/notice'),
                        ),
                        _MenuRow(
                          icon: Icons.description_outlined,
                          label: '이용약관',
                          onTap: () => context.push('/mypage/terms'),
                        ),
                        _MenuRow(
                          icon: Icons.privacy_tip_outlined,
                          label: '개인정보처리방침',
                          onTap: () => context.push('/mypage/privacy'),
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _SectionLabel('계정'),
                      _GroupCard(rows: [
                        _MenuRow(
                          icon: Icons.logout,
                          label: '로그아웃',
                          onTap: _logout,
                        ),
                        _MenuRow(
                          icon: Icons.person_remove_outlined,
                          label: '계정 삭제',
                          labelColor: Colors.red,
                          iconColor: Colors.red,
                          onTap: _deleteAccount,
                        ),
                      ]),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;
  const _ProfileCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = (user['name'] as String? ?? '').trim();
    final initial = name.isNotEmpty ? name[0] : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFF4F9D6E),
              child: Text(
                initial,
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['email'] as String? ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[500]),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final List<_MenuRow> rows;
  const _GroupCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? const Color(0xFF4F9D6E)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: labelColor ?? const Color(0xFF1A1A2E)),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

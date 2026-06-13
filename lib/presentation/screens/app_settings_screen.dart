import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _loading = true;
  bool _darkMode = false;
  String _unit = '미터';

  static const _keyDarkMode = 'app_dark_mode';
  static const _keyUnit = 'app_distance_unit';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _darkMode = prefs.getBool(_keyDarkMode) ?? false;
      _unit = prefs.getString(_keyUnit) ?? '미터';
      _loading = false;
    });
  }

  Future<void> _setDarkMode(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, v);
    setState(() => _darkMode = v);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('다크 모드는 다음 업데이트에 적용됩니다'), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _setUnit(String v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUnit, v);
    setState(() => _unit = v);
  }

  Future<void> _clearCache() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('캐시 삭제'),
        content: const Text('임시 저장된 캐시 데이터를 삭제하시겠습니까?\n저장된 경로, 후기, 게시물은 삭제되지 않습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F9D6E)),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('캐시가 삭제되었습니다'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('앱 설정', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SettingsCard(children: [
                  SwitchListTile(
                    title: const Text('다크 모드'),
                    subtitle: const Text('어두운 테마로 표시'),
                    value: _darkMode,
                    activeThumbColor: const Color(0xFF4F9D6E),
                    onChanged: _setDarkMode,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    title: const Text('거리 단위'),
                    trailing: DropdownButton<String>(
                      value: _unit,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: '미터', child: Text('미터 (m)')),
                        DropdownMenuItem(value: '마일', child: Text('마일 (mi)')),
                      ],
                      onChanged: (v) { if (v != null) _setUnit(v); },
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                _SettingsCard(children: [
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Color(0xFF4F9D6E)),
                    title: const Text('캐시 삭제'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _clearCache,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  const ListTile(
                    leading: Icon(Icons.info_outline, color: Color(0xFF4F9D6E)),
                    title: Text('버전 정보'),
                    trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
                  ),
                ]),
              ],
            ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

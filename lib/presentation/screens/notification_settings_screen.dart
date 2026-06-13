import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _loading = true;
  bool _all = true;
  bool _community = true;
  bool _tripReminder = true;
  bool _marketing = false;

  static const _keyAll = 'noti_all';
  static const _keyCommunity = 'noti_community';
  static const _keyTrip = 'noti_trip_reminder';
  static const _keyMarketing = 'noti_marketing';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _all = prefs.getBool(_keyAll) ?? true;
      _community = prefs.getBool(_keyCommunity) ?? true;
      _tripReminder = prefs.getBool(_keyTrip) ?? true;
      _marketing = prefs.getBool(_keyMarketing) ?? false;
      _loading = false;
    });
  }

  Future<void> _set(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('알림 설정', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    title: const Text('전체 알림'),
                    subtitle: const Text('모든 알림을 받습니다'),
                    value: _all,
                    activeThumbColor: const Color(0xFF4F9D6E),
                    onChanged: (v) {
                      setState(() => _all = v);
                      _set(_keyAll, v);
                    },
                  ),
                ]),
                const SizedBox(height: 16),
                _SettingsCard(children: [
                  SwitchListTile(
                    title: const Text('커뮤니티 알림'),
                    subtitle: const Text('내 게시물·댓글에 대한 알림'),
                    value: _community,
                    activeThumbColor: const Color(0xFF4F9D6E),
                    onChanged: _all ? (v) { setState(() => _community = v); _set(_keyCommunity, v); } : null,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: const Text('여행 일정 알림'),
                    subtitle: const Text('출발 전 여행 일정 알림'),
                    value: _tripReminder,
                    activeThumbColor: const Color(0xFF4F9D6E),
                    onChanged: _all ? (v) { setState(() => _tripReminder = v); _set(_keyTrip, v); } : null,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: const Text('마케팅 정보 수신'),
                    subtitle: const Text('이벤트 및 혜택 알림'),
                    value: _marketing,
                    activeThumbColor: const Color(0xFF4F9D6E),
                    onChanged: _all ? (v) { setState(() => _marketing = v); _set(_keyMarketing, v); } : null,
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

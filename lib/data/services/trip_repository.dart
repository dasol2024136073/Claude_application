import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/trip_plan.dart';
import 'review_repository.dart';
import 'trip_events.dart';

class SavedTrip {
  final String id;
  final DateTime savedAt;
  final TripPlan plan;
  final String? savedWeatherCondition; // 저장 당시 날씨 (Clear, Rain 등)
  final bool visited;
  final DateTime? visitedAt;

  SavedTrip({
    required this.id,
    required this.savedAt,
    required this.plan,
    this.savedWeatherCondition,
    this.visited = false,
    this.visitedAt,
  });
}

class TripRepository {
  static const _key = 'saved_trips';

  static Future<String> save(TripPlan plan, {String? weatherCondition}) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAll();
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final allJson = [
      ...existing.map((t) => _toJson(t)),
      {
        'id': id,
        'savedAt': DateTime.now().toIso8601String(),
        'plan': plan.toJson(),
        'savedWeatherCondition': weatherCondition,
      },
    ];
    await prefs.setString(_key, jsonEncode(allJson));
    TripEvents.notify();
    return id;
  }

  static Future<List<SavedTrip>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    final trips = list
        .map((e) => SavedTrip(
              id: e['id'] as String,
              savedAt: DateTime.parse(e['savedAt'] as String),
              plan: TripPlan.fromJson(e['plan'] as Map<String, dynamic>),
              savedWeatherCondition: e['savedWeatherCondition'] as String?,
              visited: e['visited'] as bool? ?? false,
              visitedAt: e['visitedAt'] != null
                  ? DateTime.parse(e['visitedAt'] as String)
                  : null,
            ))
        .toList();
    trips.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return trips;
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final remaining = (await getAll()).where((t) => t.id != id).toList();
    await prefs.setString(_key, jsonEncode(remaining.map(_toJson).toList()));
    TripEvents.notify();
  }

  /// 경로와 함께 작성된 후기, 커뮤니티 게시물/댓글까지 모두 삭제
  static Future<void> deleteCascade(String id) async {
    await delete(id);
    await ReviewRepository.deleteWithCommunityPost(id);
  }

  static Future<void> setVisited(String id, bool visited) async {
    final prefs = await SharedPreferences.getInstance();
    final trips = await getAll();
    final updated = trips.map((t) {
      if (t.id != id) return t;
      return SavedTrip(
        id: t.id,
        savedAt: t.savedAt,
        plan: t.plan,
        savedWeatherCondition: t.savedWeatherCondition,
        visited: visited,
        visitedAt: visited ? DateTime.now() : null,
      );
    }).toList();
    await prefs.setString(_key, jsonEncode(updated.map(_toJson).toList()));
    TripEvents.notify();
  }

  static Map<String, dynamic> _toJson(SavedTrip t) => {
        'id': t.id,
        'savedAt': t.savedAt.toIso8601String(),
        'plan': t.plan.toJson(),
        if (t.savedWeatherCondition != null)
          'savedWeatherCondition': t.savedWeatherCondition,
        'visited': t.visited,
        if (t.visitedAt != null) 'visitedAt': t.visitedAt!.toIso8601String(),
      };
}

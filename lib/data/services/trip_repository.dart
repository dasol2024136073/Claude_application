import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/trip_plan.dart';

class SavedTrip {
  final String id;
  final DateTime savedAt;
  final TripPlan plan;

  SavedTrip({required this.id, required this.savedAt, required this.plan});
}

class TripRepository {
  static const _key = 'saved_trips';

  static Future<String> save(TripPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAll();
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final allJson = [
      ...existing.map((t) => _toJson(t)),
      {'id': id, 'savedAt': DateTime.now().toIso8601String(), 'plan': plan.toJson()},
    ];
    await prefs.setString(_key, jsonEncode(allJson));
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
            ))
        .toList();
    trips.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return trips;
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final remaining = (await getAll()).where((t) => t.id != id).toList();
    await prefs.setString(_key, jsonEncode(remaining.map(_toJson).toList()));
  }

  static Map<String, dynamic> _toJson(SavedTrip t) => {
        'id': t.id,
        'savedAt': t.savedAt.toIso8601String(),
        'plan': t.plan.toJson(),
      };
}

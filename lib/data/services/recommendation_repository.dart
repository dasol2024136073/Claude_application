import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/destination_recommendation.dart';
import 'gemini_service.dart';
import 'photo_service.dart';

class RecommendationRepository {
  static const _key = 'destination_recommendations';
  static const _timeKey = 'destination_recommendations_at';
  static const _refreshInterval = Duration(hours: 24);

  static const _fallback = [
    DestinationRecommendation(destination: '오사카, 일본', country: '일본', reason: '맛집과 쇼핑을 함께 즐길 수 있는 인기 여행지', days: 3, emoji: '🏯'),
    DestinationRecommendation(destination: '방콕, 태국', country: '태국', reason: '활기찬 시장과 다양한 길거리 음식', days: 4, emoji: '🛕'),
    DestinationRecommendation(destination: '파리, 프랑스', country: '프랑스', reason: '예술과 낭만이 가득한 도시', days: 5, emoji: '🗼'),
    DestinationRecommendation(destination: '발리, 인도네시아', country: '인도네시아', reason: '여유로운 휴양과 자연 경관', days: 4, emoji: '🏝️'),
    DestinationRecommendation(destination: '뉴욕, 미국', country: '미국', reason: '도시의 활기와 다채로운 문화', days: 5, emoji: '🗽'),
  ];

  /// 캐시된 추천이 유효하면 그대로 반환, 아니면 새로 생성해서 캐시 후 반환
  static Future<List<DestinationRecommendation>> getOrFetch({
    required List<String> travelStyles,
    required List<String> budgets,
    required List<String> companions,
    required List<String> regions,
    required List<String> intensities,
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = await _readCache(prefs);
      if (cached != null) return cached;
    }

    List<DestinationRecommendation> recommendations;
    try {
      recommendations = await GeminiService.recommendDestinations(
        travelStyles: travelStyles,
        budgets: budgets,
        companions: companions,
        regions: regions,
        intensities: intensities,
      );
    } catch (_) {
      recommendations = _fallback;
    }

    // 각 추천 항목의 사진을 병렬로 조회
    final withPhotos = await Future.wait(recommendations.map((r) async {
      final photoUrl = await PhotoService.fetchPhoto(r.destination);
      return r.copyWith(photoUrl: photoUrl);
    }));

    await _writeCache(prefs, withPhotos);
    return withPhotos;
  }

  static Future<List<DestinationRecommendation>?> _readCache(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    final timeRaw = prefs.getString(_timeKey);
    if (raw == null || timeRaw == null) return null;

    final savedAt = DateTime.tryParse(timeRaw);
    if (savedAt == null || DateTime.now().difference(savedAt) > _refreshInterval) return null;

    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => DestinationRecommendation.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> _writeCache(SharedPreferences prefs, List<DestinationRecommendation> list) async {
    await prefs.setString(_key, jsonEncode(list.map((r) => r.toJson()).toList()));
    await prefs.setString(_timeKey, DateTime.now().toIso8601String());
  }
}

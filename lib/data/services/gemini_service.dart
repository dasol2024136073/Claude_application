import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/config.dart';
import '../../domain/models/destination_recommendation.dart';
import '../../domain/models/trip_plan.dart';
import 'weather_service.dart';

class GeminiService {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  static Future<TripPlan> generateTripPlan(
    String destination,
    int days, {
    WeatherInfo? weather,
    String? arrivalTime,
    String? departureTime,
    String? accommodation,
    List<String>? travelStyles,
    List<String>? budgets,
    List<String>? companions,
    List<String>? regions,
    List<String>? intensities,
    String? indoorOutdoor,
    bool nearbyNow = false,
  }) async {
    const model = 'gemini-2.5-flash';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$geminiApiKey';

    final extraConditions = StringBuffer();
    if (arrivalTime != null) {
      extraConditions.writeln('- 입국(도착) 시간이 $arrivalTime이므로, 1일차(day 1) 일정은 $arrivalTime 이후부터 시작해줘. 그 이전 시간대 일정은 넣지 마.');
    }
    if (departureTime != null) {
      extraConditions.writeln('- 출국(공항 이동) 시간이 $departureTime이므로, 마지막 날(day ${days + 1}) 일정은 $departureTime 이전에 모두 끝나야 해. 공항 이동 여유 시간을 고려해줘.');
    }
    if (accommodation != null) {
      extraConditions.writeln('- 숙소 위치: $accommodation. 각 날짜의 장소들은 숙소를 기준으로 이동 동선이 효율적으로 묶이도록 구성해줘.');
    }
    if (nearbyNow) {
      extraConditions.writeln('- 사용자가 지금 당장 출발하는 당일 근교 코스야. 모든 장소는 $destination 또는 그 근교(대중교통/차량 30분 이내)에 있어야 해.');
      extraConditions.writeln('- 남은 시간을 고려해 무리하지 않게 장소 2~4개만 추천해줘. (장소 4개 조건보다 이 조건을 우선해)');
    }

    final preferenceLines = StringBuffer();
    if (travelStyles != null && travelStyles.isNotEmpty) preferenceLines.writeln('- 여행 스타일: ${travelStyles.join(', ')}');
    if (budgets != null && budgets.isNotEmpty) preferenceLines.writeln('- 예산 규모: ${budgets.join(', ')}');
    if (companions != null && companions.isNotEmpty) preferenceLines.writeln('- 동행 유형: ${companions.join(', ')}');
    if (regions != null && regions.isNotEmpty) preferenceLines.writeln('- 선호 지역: ${regions.join(', ')}');
    if (intensities != null && intensities.isNotEmpty) preferenceLines.writeln('- 여행 강도: ${intensities.join(', ')}');
    if (indoorOutdoor != null && indoorOutdoor != '상관없음') preferenceLines.writeln('- 실내·실외 선호: $indoorOutdoor (장소 카테고리를 이 선호에 맞춰 구성해줘)');
    if (preferenceLines.isNotEmpty) {
      extraConditions.writeln('- 다음 사용자 취향을 반영해 장소와 동선을 구성해줘:');
      extraConditions.write(preferenceLines);
    }

    final prompt = '''
여행 경로를 JSON으로 생성해줘.
여행지: $destination
기간: ${days.toString()}박 ${(days + 1).toString()}일

반드시 아래 JSON 형식으로만 응답해. 마크다운, 설명 텍스트 없이 JSON만:
{
  "destination": "$destination",
  "days": $days,
  "dayPlans": [
    {
      "day": 1,
      "places": [
        {
          "time": "09:00",
          "name": "장소명",
          "latitude": 35.6895,
          "longitude": 139.6917,
          "category": "카테고리",
          "description": "한 문장 설명"
        }
      ]
    }
  ]
}

조건:
- $days박 ${days + 1}일 일정이므로 dayPlans 배열 길이는 반드시 ${days + 1} (day 1부터 day ${days + 1}까지 모두 포함)
- 각 날짜마다 장소 4개
- category는 관광/맛집/쇼핑/자연/역사·문화/전망대/카페/시장 중 하나
- description은 한국어, 50자 이내
- 실제 존재하는 유명한 장소만
- latitude/longitude는 해당 장소의 실제 위경도 (소수점 4자리)
${weather != null ? '\n날씨 조건: ${weather.summary}\n${weather.geminiHint}' : ''}
$extraConditions''';

    final response = await _dio.post(url, data: {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 2048,
        'thinkingConfig': {'thinkingBudget': 0},
      },
    });

    final text =
        response.data['candidates'][0]['content']['parts'][0]['text'] as String;
    final jsonStr = _extractJson(text);
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return _parseTripPlan(map);
  }

  /// 사용자 취향을 바탕으로 추천 여행지 목록을 생성합니다.
  static Future<List<DestinationRecommendation>> recommendDestinations({
    required List<String> travelStyles,
    required List<String> budgets,
    required List<String> companions,
    required List<String> regions,
    required List<String> intensities,
  }) async {
    const model = 'gemini-2.5-flash';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$geminiApiKey';

    final preferenceLines = StringBuffer();
    if (travelStyles.isNotEmpty) preferenceLines.writeln('- 여행 스타일: ${travelStyles.join(', ')}');
    if (budgets.isNotEmpty) preferenceLines.writeln('- 예산 규모: ${budgets.join(', ')}');
    if (companions.isNotEmpty) preferenceLines.writeln('- 동행 유형: ${companions.join(', ')}');
    if (regions.isNotEmpty) preferenceLines.writeln('- 선호 지역: ${regions.join(', ')}');
    if (intensities.isNotEmpty) preferenceLines.writeln('- 여행 강도: ${intensities.join(', ')}');
    if (preferenceLines.isEmpty) preferenceLines.writeln('- 특별한 취향 정보 없음 (다양한 인기 여행지 추천)');

    final prompt = '''
다음 사용자 취향에 맞는 여행지를 추천해줘.

사용자 취향:
$preferenceLines

반드시 아래 JSON 형식으로만 응답해. 마크다운, 설명 텍스트 없이 JSON만:
{
  "recommendations": [
    {
      "destination": "도시, 국가",
      "country": "국가명",
      "reason": "이 여행지를 추천하는 이유 (한국어, 40자 이내)",
      "days": 3,
      "emoji": "🗼"
    }
  ]
}

조건:
- 서로 다른 나라의 여행지 5개를 추천
- 취향에 맞는 이유를 구체적으로 작성
- days는 추천 여행 기간(숙박일, 1~5 사이)
- emoji는 그 도시/국가를 대표하는 이모지 1개''';

    final response = await _dio.post(url, data: {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.8,
        'maxOutputTokens': 1024,
        'thinkingConfig': {'thinkingBudget': 0},
      },
    });

    final text =
        response.data['candidates'][0]['content']['parts'][0]['text'] as String;
    final jsonStr = _extractJson(text);
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final list = map['recommendations'] as List<dynamic>;
    return list
        .map((e) => DestinationRecommendation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String _extractJson(String text) {
    final clean =
        text.replaceAll(RegExp(r'```json\s*'), '').replaceAll('```', '').trim();
    final start = clean.indexOf('{');
    final end = clean.lastIndexOf('}');
    if (start == -1 || end == -1) throw Exception('JSON 파싱 실패: $clean');
    return clean.substring(start, end + 1);
  }

  static TripPlan _parseTripPlan(Map<String, dynamic> map) {
    final dayPlansJson = map['dayPlans'] as List<dynamic>;
    final dayPlans = dayPlansJson.map((d) {
      final places = (d['places'] as List<dynamic>).map((p) => PlaceItem(
            time: p['time'] as String,
            name: p['name'] as String,
            category: p['category'] as String,
            description: p['description'] as String,
            latitude: (p['latitude'] as num?)?.toDouble(),
            longitude: (p['longitude'] as num?)?.toDouble(),
          )).toList();
      return DayPlan(day: d['day'] as int, places: places);
    }).toList();

    return TripPlan(
      destination: map['destination'] as String,
      days: map['days'] as int,
      dayPlans: dayPlans,
    );
  }
}

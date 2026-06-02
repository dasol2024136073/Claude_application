import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/config.dart';
import '../../domain/models/trip_plan.dart';

class GeminiService {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  static Future<TripPlan> generateTripPlan(String destination, int days) async {
    const model = 'gemini-2.5-flash';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$geminiApiKey';

    final prompt = '''
여행 경로를 JSON으로 생성해줘.
여행지: $destination
기간: ${days}박 ${days + 1}일

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
          "category": "카테고리",
          "description": "한 문장 설명"
        }
      ]
    }
  ]
}

조건:
- 날짜 수: $days일 (dayPlans 배열 길이 = $days)
- 각 날짜마다 장소 4개
- category는 관광/맛집/쇼핑/자연/역사·문화/전망대/카페/시장 중 하나
- description은 한국어, 50자 이내
- 실제 존재하는 유명한 장소만
''';

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

import 'package:dio/dio.dart';
import '../../core/config.dart';

class WeatherInfo {
  final String condition;
  final String descriptionKo;
  final double temp;
  final String emoji;
  final String geminiHint; // Gemini 프롬프트에 추가할 지시문

  const WeatherInfo({
    required this.condition,
    required this.descriptionKo,
    required this.temp,
    required this.emoji,
    required this.geminiHint,
  });

  String get summary => '$emoji $descriptionKo ${temp.round()}°C';
}

class WeatherService {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // 한국어 도시명 → API용 영문명 매핑
  static const _cityMap = {
    '오사카': 'Osaka', '도쿄': 'Tokyo', '제주': 'Jeju', '제주도': 'Jeju',
    '파리': 'Paris', '방콕': 'Bangkok', '다낭': 'Da Nang', '서울': 'Seoul',
    '뉴욕': 'New York', '런던': 'London', '바르셀로나': 'Barcelona',
    '로마': 'Rome', '베이징': 'Beijing', '상하이': 'Shanghai',
    '싱가포르': 'Singapore', '홍콩': 'Hong Kong', '시드니': 'Sydney',
    '두바이': 'Dubai', '이스탄불': 'Istanbul', '프라하': 'Prague',
  };

  static Future<WeatherInfo?> fetch(String destination) async {
    final cityName = _cityMap[destination] ?? destination;
    try {
      final res = await _dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'q': cityName,
          'appid': openWeatherApiKey,
          'units': 'metric',
          'lang': 'kr',
        },
      );
      final main = res.data['weather'][0]['main'] as String;
      final desc = res.data['weather'][0]['description'] as String;
      final temp = (res.data['main']['temp'] as num).toDouble();
      return _buildInfo(main, desc, temp);
    } catch (_) {
      return null; // 날씨 조회 실패 시 그냥 기본 경로 생성
    }
  }

  static WeatherInfo _buildInfo(String main, String desc, double temp) {
    switch (main) {
      case 'Thunderstorm':
        return WeatherInfo(
          condition: main, descriptionKo: desc, temp: temp,
          emoji: '⛈️',
          geminiHint: '현재 폭풍/천둥번개 날씨입니다. 실내 전용 일정으로만 구성해줘. 박물관, 실내 쇼핑몰, 실내 체험관, 카페 등 야외 장소는 절대 포함하지 마세요.',
        );
      case 'Drizzle':
      case 'Rain':
        return WeatherInfo(
          condition: main, descriptionKo: desc, temp: temp,
          emoji: '🌧️',
          geminiHint: '현재 비가 오는 날씨입니다. 실내 위주 일정으로 구성해줘. 박물관, 실내 시장, 백화점, 카페, 수족관 등을 우선 배치하고 야외 장소는 최소화해줘.',
        );
      case 'Snow':
        return WeatherInfo(
          condition: main, descriptionKo: desc, temp: temp,
          emoji: '❄️',
          geminiHint: '현재 눈이 오는 날씨입니다. 실내 위주 일정으로 구성하되, 설경을 볼 수 있는 짧은 야외 스팟 1~2곳은 포함해도 됩니다.',
        );
      case 'Clear':
        return WeatherInfo(
          condition: main, descriptionKo: desc, temp: temp,
          emoji: '☀️',
          geminiHint: '현재 맑은 날씨입니다. 야외 명소, 공원, 전망대, 해변 등 야외 활동을 적극 포함해줘.',
        );
      case 'Clouds':
        return WeatherInfo(
          condition: main, descriptionKo: desc, temp: temp,
          emoji: '⛅',
          geminiHint: '현재 흐린 날씨입니다. 야외와 실내를 균형 있게 배치해줘.',
        );
      default:
        return WeatherInfo(
          condition: main, descriptionKo: desc, temp: temp,
          emoji: '🌤️',
          geminiHint: '날씨를 고려해 야외와 실내를 균형 있게 배치해줘.',
        );
    }
  }
}

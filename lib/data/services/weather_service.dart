import 'package:dio/dio.dart';
import '../../core/config.dart';

class WeatherInfo {
  final String condition;
  final String descriptionKo;
  final double temp;
  final String emoji;
  final String geminiHint;

  const WeatherInfo({
    required this.condition,
    required this.descriptionKo,
    required this.temp,
    required this.emoji,
    required this.geminiHint,
  });

  String get summary => '$emoji $descriptionKo ${temp.round()}°C';
}

class HourlyWeather {
  final DateTime time;
  final double temp;
  final String emoji;
  final String description;

  const HourlyWeather({
    required this.time,
    required this.temp,
    required this.emoji,
    required this.description,
  });
}

class DailyWeather {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String emoji;
  final String description;

  const DailyWeather({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.emoji,
    required this.description,
  });
}

class WeatherForecast {
  final String city;
  final WeatherInfo current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  const WeatherForecast({
    required this.city,
    required this.current,
    required this.hourly,
    required this.daily,
  });
}

class WeatherService {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static const _cityMap = {
    '오사카': 'Osaka', '도쿄': 'Tokyo', '제주': 'Jeju', '제주도': 'Jeju',
    '파리': 'Paris', '방콕': 'Bangkok', '다낭': 'Da Nang', '서울': 'Seoul',
    '뉴욕': 'New York', '런던': 'London', '바르셀로나': 'Barcelona',
    '로마': 'Rome', '베이징': 'Beijing', '상하이': 'Shanghai',
    '싱가포르': 'Singapore', '홍콩': 'Hong Kong', '시드니': 'Sydney',
    '두바이': 'Dubai', '이스탄불': 'Istanbul', '프라하': 'Prague',
  };

  // 현재 날씨 — 도시명
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
      return null;
    }
  }

  // 현재 날씨 — 좌표 → (WeatherInfo, 도시명)
  static Future<(WeatherInfo?, String)> fetchByCoords(double lat, double lon) async {
    try {
      final res = await _dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': lat, 'lon': lon,
          'appid': openWeatherApiKey,
          'units': 'metric',
          'lang': 'kr',
        },
      );
      final city = res.data['name'] as String;
      final main = res.data['weather'][0]['main'] as String;
      final desc = res.data['weather'][0]['description'] as String;
      final temp = (res.data['main']['temp'] as num).toDouble();
      return (_buildInfo(main, desc, temp), city);
    } catch (_) {
      return (null, '');
    }
  }

  // 시간별·일별 예보 — 좌표
  static Future<WeatherForecast?> fetchForecastByCoords(double lat, double lon) async {
    try {
      final (current, cityName) = await fetchByCoords(lat, lon);
      if (current == null) return null;

      final res = await _dio.get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: {
          'lat': lat, 'lon': lon,
          'appid': openWeatherApiKey,
          'units': 'metric',
          'lang': 'kr',
        },
      );
      return _parseForecast(res.data, current, cityName);
    } catch (_) {
      return null;
    }
  }

  // 시간별·일별 예보 — 도시명 (Geocoding API로 한국어·영어 모두 지원)
  static Future<WeatherForecast?> fetchForecastByCity(String city) async {
    try {
      // Geocoding API: 한국어 포함 어떤 언어든 좌표로 변환
      final geoRes = await _dio.get(
        'https://api.openweathermap.org/geo/1.0/direct',
        queryParameters: {'q': city, 'limit': 1, 'appid': openWeatherApiKey},
      );
      final geoList = geoRes.data as List;
      if (geoList.isEmpty) return null;

      final lat = (geoList[0]['lat'] as num).toDouble();
      final lon = (geoList[0]['lon'] as num).toDouble();
      final localNames = geoList[0]['local_names'] as Map<String, dynamic>?;
      final displayCity = localNames?['ko'] as String?
          ?? geoList[0]['name'] as String;

      // 좌표로 현재 날씨 + 예보 조회
      final (current, _) = await fetchByCoords(lat, lon);
      if (current == null) return null;

      final forecastRes = await _dio.get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: {
          'lat': lat, 'lon': lon,
          'appid': openWeatherApiKey,
          'units': 'metric',
          'lang': 'kr',
        },
      );
      return _parseForecast(forecastRes.data, current, displayCity);
    } catch (_) {
      return null;
    }
  }

  static WeatherForecast _parseForecast(
      dynamic data, WeatherInfo current, String cityName) {
    final list = data['list'] as List;

    // 시간별: 다음 24시간 (3시간 간격 × 8개)
    final hourly = list.take(8).map((item) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
          (item['dt'] as int) * 1000).toLocal();
      final temp = (item['main']['temp'] as num).toDouble();
      final cond = item['weather'][0]['main'] as String;
      final desc = item['weather'][0]['description'] as String;
      return HourlyWeather(
        time: dt, temp: temp,
        emoji: _conditionEmoji(cond), description: desc,
      );
    }).toList();

    // 일별: 날짜별 그룹핑 후 최저/최고
    final Map<String, List<dynamic>> byDay = {};
    for (final item in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
          (item['dt'] as int) * 1000).toLocal();
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      byDay.putIfAbsent(key, () => []).add(item);
    }

    final daily = byDay.entries.take(6).map((e) {
      final items = e.value;
      final dt = DateTime.fromMillisecondsSinceEpoch(
          (items[0]['dt'] as int) * 1000).toLocal();
      final minT = items
          .map<double>((i) => (i['main']['temp_min'] as num).toDouble())
          .reduce((a, b) => a < b ? a : b);
      final maxT = items
          .map<double>((i) => (i['main']['temp_max'] as num).toDouble())
          .reduce((a, b) => a > b ? a : b);
      final mid = items[items.length ~/ 2];
      final cond = mid['weather'][0]['main'] as String;
      final desc = mid['weather'][0]['description'] as String;
      return DailyWeather(
        date: dt, tempMin: minT, tempMax: maxT,
        emoji: _conditionEmoji(cond), description: desc,
      );
    }).toList();

    return WeatherForecast(
        city: cityName, current: current, hourly: hourly, daily: daily);
  }

  static String _conditionEmoji(String condition) {
    switch (condition) {
      case 'Thunderstorm': return '⛈️';
      case 'Drizzle': return '🌦️';
      case 'Rain': return '🌧️';
      case 'Snow': return '❄️';
      case 'Clear': return '☀️';
      case 'Clouds': return '⛅';
      default: return '🌤️';
    }
  }

  static WeatherInfo _buildInfo(String main, String desc, double temp) {
    switch (main) {
      case 'Thunderstorm':
        return WeatherInfo(
          condition: main, descriptionKo: desc, temp: temp, emoji: '⛈️',
          geminiHint: '현재 폭풍/천둥번개 날씨입니다. 실내 전용 일정으로만 구성해줘. 박물관, 실내 쇼핑몰, 실내 체험관, 카페 등 야외 장소는 절대 포함하지 마세요.',
        );
      case 'Drizzle':
      case 'Rain':
        return WeatherInfo(
          condition: main, descriptionKo: desc, temp: temp, emoji: '🌧️',
          geminiHint: '현재 비가 오는 날씨입니다. 실내 위주 일정으로 구성해줘. 박물관, 실내 시장, 백화점, 카페, 수족관 등을 우선 배치하고 야외 장소는 최소화해줘.',
        );
      case 'Snow':
        return WeatherInfo(
          condition: main, descriptionKo: desc, temp: temp, emoji: '❄️',
          geminiHint: '현재 눈이 오는 날씨입니다. 실내 위주 일정으로 구성하되, 설경을 볼 수 있는 짧은 야외 스팟 1~2곳은 포함해도 됩니다.',
        );
      case 'Clear':
        return WeatherInfo(
          condition: main, descriptionKo: desc, temp: temp, emoji: '☀️',
          geminiHint: '현재 맑은 날씨입니다. 야외 명소, 공원, 전망대, 해변 등 야외 활동을 적극 포함해줘.',
        );
      case 'Clouds':
        return WeatherInfo(
          condition: main, descriptionKo: desc, temp: temp, emoji: '⛅',
          geminiHint: '현재 흐린 날씨입니다. 야외와 실내를 균형 있게 배치해줘.',
        );
      default:
        return WeatherInfo(
          condition: main, descriptionKo: desc, temp: temp, emoji: '🌤️',
          geminiHint: '날씨를 고려해 야외와 실내를 균형 있게 배치해줘.',
        );
    }
  }
}

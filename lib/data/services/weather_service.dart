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
    // 해외
    '오사카': 'Osaka', '도쿄': 'Tokyo', '파리': 'Paris', '방콕': 'Bangkok',
    '다낭': 'Da Nang', '뉴욕': 'New York', '런던': 'London',
    '바르셀로나': 'Barcelona', '로마': 'Rome', '베이징': 'Beijing',
    '상하이': 'Shanghai', '싱가포르': 'Singapore', '홍콩': 'Hong Kong',
    '시드니': 'Sydney', '두바이': 'Dubai', '이스탄불': 'Istanbul',
    '프라하': 'Prague', '후쿠오카': 'Fukuoka', '삿포로': 'Sapporo',
    '나고야': 'Nagoya', '교토': 'Kyoto', '하노이': 'Hanoi',
    '호치민': 'Ho Chi Minh City', '발리': 'Denpasar', '세부': 'Cebu City',
    '마닐라': 'Manila', '쿠알라룸푸르': 'Kuala Lumpur', '자카르타': 'Jakarta',
    '뭄바이': 'Mumbai', '로스앤젤레스': 'Los Angeles', '시카고': 'Chicago',
    '마드리드': 'Madrid', '암스테르담': 'Amsterdam', '빈': 'Vienna',
    '취리히': 'Zurich', '아테네': 'Athens', '리스본': 'Lisbon',
    // 국내 (OWM 영문 도시명 기준)
    '서울': 'Seoul', '부산': 'Busan', '인천': 'Incheon', '대구': 'Daegu',
    '대전': 'Daejeon', '광주': 'Gwangju', '울산': 'Ulsan', '수원': 'Suwon',
    '제주': 'Jeju City', '제주도': 'Jeju City',
    '강릉': 'Gangneung', '속초': 'Sokcho', '춘천': 'Chuncheon',
    '경주': 'Gyeongju', '전주': 'Jeonju', '여수': 'Yeosu',
    '통영': 'Tongyeong', '안동': 'Andong', '포항': 'Pohang',
    '청주': 'Cheongju', '천안': 'Cheonan', '군산': 'Gunsan',
    '목포': 'Mokpo', '순천': 'Suncheon', '가평': 'Gapyeong',
    '남양주': 'Namyangju', '고양': 'Goyang', '성남': 'Seongnam',
    '용인': 'Yongin', '평택': 'Pyeongtaek', '창원': 'Changwon',
    '진주': 'Jinju', '거제': 'Geoje',
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

  static bool _hasKorean(String s) =>
      s.runes.any((r) => r >= 0xAC00 && r <= 0xD7A3);

  // 시간별·일별 예보 — 도시명
  static Future<WeatherForecast?> fetchForecastByCity(String city) async {
    try {
      // 한국어 도시명은 맵에서 영문명 변환, 없으면 그대로
      final apiName = _cityMap[city] ?? city;
      late double lat, lon;

      // 1차: Geocoding API (영문명 사용)
      bool resolved = false;
      try {
        final geoRes = await _dio.get(
          'https://api.openweathermap.org/geo/1.0/direct',
          queryParameters: {'q': apiName, 'limit': 1, 'appid': openWeatherApiKey},
        );
        final geoList = geoRes.data as List;
        if (geoList.isNotEmpty) {
          lat = (geoList[0]['lat'] as num).toDouble();
          lon = (geoList[0]['lon'] as num).toDouble();
          resolved = true;
        }
      } catch (_) {}

      // 2차 fallback: 날씨 API 직접 (coord 포함)
      if (!resolved) {
        final wRes = await _dio.get(
          'https://api.openweathermap.org/data/2.5/weather',
          queryParameters: {
            'q': apiName, 'appid': openWeatherApiKey,
            'units': 'metric', 'lang': 'kr',
          },
        );
        lat = (wRes.data['coord']['lat'] as num).toDouble();
        lon = (wRes.data['coord']['lon'] as num).toDouble();
      }

      final (current, _) = await fetchByCoords(lat, lon);
      if (current == null) return null;

      // 화면 표시명: 사용자가 입력한 원래 이름 사용
      final forecastRes = await _dio.get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: {
          'lat': lat, 'lon': lon,
          'appid': openWeatherApiKey, 'units': 'metric', 'lang': 'kr',
        },
      );
      return _parseForecast(forecastRes.data, current, city);
    } catch (_) {
      return null;
    }
  }

  static WeatherForecast _parseForecast(
      dynamic data, WeatherInfo current, String cityName) {
    final list = data['list'] as List;

    // 시간별: 다음 24시간 (3시간 간격 × 8개)
    final hourly = list.take(10).map((item) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
          (item['dt'] as int) * 1000).toLocal();
      final temp = (item['main']['temp'] as num).toDouble();
      final cond = item['weather'][0]['main'] as String;
      final desc = item['weather'][0]['description'] as String;
      return HourlyWeather(
        time: dt, temp: temp,
        emoji: _conditionEmoji(cond), description: _simplifyDesc(desc),
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
        emoji: _conditionEmoji(cond), description: _simplifyDesc(desc),
      );
    }).toList();

    return WeatherForecast(
        city: cityName, current: current, hourly: hourly, daily: daily);
  }

  static String _simplifyDesc(String desc) {
    const map = {
      '맑음': '맑음',
      '구름조금': '맑음',
      '튼구름': '흐림',
      '구름많음': '흐림',
      '온흐림': '흐림',
      '실비': '가랑비',
      '가벼운 강우': '가랑비',
      '강우': '비',
      '약한 비': '비',
      '비': '비',
      '강한 비': '폭우',
      '매우 강한 비': '폭우',
      '폭우': '폭우',
      '소나기': '소나기',
      '가벼운 소나기': '소나기',
      '가벼운 눈': '눈',
      '눈': '눈',
      '강한 눈': '폭설',
      '매우 강한 눈': '폭설',
      '눈보라': '폭설',
      '박무': '안개',
      '연무': '안개',
      '엷은 안개': '안개',
      '안개': '안개',
      '황사': '황사',
      '모래': '황사',
    };
    if (map.containsKey(desc)) return map[desc]!;
    if (desc.contains('뇌우') || desc.contains('천둥')) return '천둥번개';
    if (desc.contains('눈')) return '눈';
    if (desc.contains('소나기')) return '소나기';
    if (desc.contains('비') || desc.contains('강우')) return '비';
    if (desc.contains('안개') || desc.contains('박무') || desc.contains('연무')) return '안개';
    if (desc.contains('흐림') || desc.contains('구름')) return '흐림';
    if (desc.contains('맑')) return '맑음';
    return desc;
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
    final d = _simplifyDesc(desc);
    switch (main) {
      case 'Thunderstorm':
        return WeatherInfo(
          condition: main, descriptionKo: d, temp: temp, emoji: '⛈️',
          geminiHint: '현재 폭풍/천둥번개 날씨입니다. 실내 전용 일정으로만 구성해줘. 박물관, 실내 쇼핑몰, 실내 체험관, 카페 등 야외 장소는 절대 포함하지 마세요.',
        );
      case 'Drizzle':
      case 'Rain':
        return WeatherInfo(
          condition: main, descriptionKo: d, temp: temp, emoji: '🌧️',
          geminiHint: '현재 비가 오는 날씨입니다. 실내 위주 일정으로 구성해줘. 박물관, 실내 시장, 백화점, 카페, 수족관 등을 우선 배치하고 야외 장소는 최소화해줘.',
        );
      case 'Snow':
        return WeatherInfo(
          condition: main, descriptionKo: d, temp: temp, emoji: '❄️',
          geminiHint: '현재 눈이 오는 날씨입니다. 실내 위주 일정으로 구성하되, 설경을 볼 수 있는 짧은 야외 스팟 1~2곳은 포함해도 됩니다.',
        );
      case 'Clear':
        return WeatherInfo(
          condition: main, descriptionKo: d, temp: temp, emoji: '☀️',
          geminiHint: '현재 맑은 날씨입니다. 야외 명소, 공원, 전망대, 해변 등 야외 활동을 적극 포함해줘.',
        );
      case 'Clouds':
        return WeatherInfo(
          condition: main, descriptionKo: d, temp: temp, emoji: '⛅',
          geminiHint: '현재 흐린 날씨입니다. 야외와 실내를 균형 있게 배치해줘.',
        );
      default:
        return WeatherInfo(
          condition: main, descriptionKo: d, temp: temp, emoji: '🌤️',
          geminiHint: '날씨를 고려해 야외와 실내를 균형 있게 배치해줘.',
        );
    }
  }
}

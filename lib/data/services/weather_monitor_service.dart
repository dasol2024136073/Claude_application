import 'trip_repository.dart';
import 'weather_service.dart';

class WeatherAlert {
  final SavedTrip trip;
  final WeatherInfo newWeather;
  final String message;

  const WeatherAlert({
    required this.trip,
    required this.newWeather,
    required this.message,
  });
}

class WeatherMonitorService {
  // 날씨가 유의미하게 바뀌었는지 판단
  static bool isSignificantChange(String? original, String current) {
    if (original == null) return false;
    const outdoor = {'Clear'};
    const indoor = {'Rain', 'Drizzle', 'Thunderstorm', 'Snow'};
    final wasOutdoor = outdoor.contains(original);
    final isNowIndoor = indoor.contains(current);
    final wasIndoor = indoor.contains(original);
    final isNowOutdoor = outdoor.contains(current);
    return (wasOutdoor && isNowIndoor) || (wasIndoor && isNowOutdoor);
  }

  static String _buildMessage(String? original, WeatherInfo current) {
    const indoor = {'Rain', 'Drizzle', 'Thunderstorm', 'Snow'};
    if (indoor.contains(current.condition)) {
      return '${current.emoji} 비/악천후 예보! 실내 위주 경로로 바꿔드릴까요?';
    }
    return '${current.emoji} 날씨가 개었어요! 야외 명소 포함 경로로 바꿔드릴까요?';
  }

  // 저장된 모든 경로의 현재 날씨 확인
  static Future<List<WeatherAlert>> checkAll(List<SavedTrip> trips) async {
    final alerts = <WeatherAlert>[];
    for (final trip in trips) {
      if (trip.savedWeatherCondition == null) continue;
      final current = await WeatherService.fetch(trip.plan.destination);
      if (current == null) continue;
      if (isSignificantChange(trip.savedWeatherCondition, current.condition)) {
        alerts.add(WeatherAlert(
          trip: trip,
          newWeather: current,
          message: _buildMessage(trip.savedWeatherCondition, current),
        ));
      }
    }
    return alerts;
  }
}

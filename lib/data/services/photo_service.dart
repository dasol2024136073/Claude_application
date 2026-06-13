import 'package:dio/dio.dart';
import '../../core/config.dart';

class PhotoService {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Unsplash에서 검색어에 맞는 사진 URL을 가져옵니다.
  /// API 키가 없거나 요청에 실패하면 null을 반환합니다.
  static Future<String?> fetchPhoto(String query) async {
    if (unsplashApiKey.isEmpty) return null;

    try {
      final response = await _dio.get(
        'https://api.unsplash.com/search/photos',
        queryParameters: {
          'query': query,
          'per_page': 1,
          'orientation': 'landscape',
        },
        options: Options(headers: {
          'Authorization': 'Client-ID $unsplashApiKey',
        }),
      );

      final results = response.data['results'] as List<dynamic>;
      if (results.isEmpty) return null;
      return results.first['urls']['small'] as String?;
    } catch (_) {
      return null;
    }
  }
}

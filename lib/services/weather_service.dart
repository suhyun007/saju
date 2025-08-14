import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherInfo {
  final String locationName;
  final String fineDustLabel; // 미세먼지 상태 (좋음/보통/나쁨/매우나쁨)
  final int temperatureCelsius;
  final int weatherCode; // Open-Meteo weather code

  const WeatherInfo({
    required this.locationName,
    required this.fineDustLabel,
    required this.temperatureCelsius,
    required this.weatherCode,
  });
}

class WeatherService {
  // IP 기반 대략적 위치 조회 (API 키 불필요)
  static Future<({double lat, double lon, String city, String region})> _fetchApproxLocation() async {
    final uri = Uri.parse('https://ipapi.co/json');
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final latitude = (json['latitude'] as num?)?.toDouble() ?? 37.5665;
      final longitude = (json['longitude'] as num?)?.toDouble() ?? 126.9780;
      final city = (json['city'] as String?) ?? '서울특별시';
      final region = (json['region'] as String?) ?? '';
      return (lat: latitude, lon: longitude, city: city, region: region);
    }
    // 기본값: 서울
    return (lat: 37.5665, lon: 126.9780, city: '서울특별시', region: '');
  }

  static String _pm10ToLabel(double? pm10) {
    if (pm10 == null) return '정보 없음';
    if (pm10 <= 30) return '좋음';
    if (pm10 <= 80) return '보통';
    if (pm10 <= 150) return '나쁨';
    return '매우 나쁨';
  }

  static Future<WeatherInfo> fetchWeather() async {
    final loc = await _fetchApproxLocation();

    // 현재 기온/날씨코드
    final forecastUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${loc.lat}&longitude=${loc.lon}&current=temperature_2m,weather_code&timezone=auto');
    final forecastRes = await http.get(forecastUrl).timeout(const Duration(seconds: 8));
    int temperature = 0;
    int weatherCode = 0;
    if (forecastRes.statusCode == 200) {
      final map = jsonDecode(forecastRes.body) as Map<String, dynamic>;
      final current = (map['current'] as Map<String, dynamic>?);
      temperature = (current?['temperature_2m'] as num?)?.round() ?? 0;
      weatherCode = (current?['weather_code'] as num?)?.toInt() ?? 0;
    }

    // 미세먼지(pm10) 시간별 → 최신값 사용
    final airUrl = Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=${loc.lat}&longitude=${loc.lon}&hourly=pm10&timezone=auto');
    final airRes = await http.get(airUrl).timeout(const Duration(seconds: 8));
    String pm10Label = '정보 없음';
    if (airRes.statusCode == 200) {
      final map = jsonDecode(airRes.body) as Map<String, dynamic>;
      final hourly = (map['hourly'] as Map<String, dynamic>?);
      final pm10List = (hourly?['pm10'] as List?)?.cast<num>();
      if (pm10List != null && pm10List.isNotEmpty) {
        final latest = pm10List.last.toDouble();
        pm10Label = _pm10ToLabel(latest);
      }
    }

    final locationName = loc.region.isNotEmpty ? '${loc.region} ${loc.city}' : loc.city;

    return WeatherInfo(
      locationName: locationName,
      fineDustLabel: pm10Label,
      temperatureCelsius: temperature,
      weatherCode: weatherCode,
    );
  }
}



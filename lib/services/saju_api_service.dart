import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/saju_info.dart';

class SajuApiService {
  // 서버 베이스 URL (디버그는 로컬, 릴리즈는 Vercel)
  static String get _baseUrl => kDebugMode
      ? 'http://localhost:3000/api'
      : 'https://saju-server-j9ti.vercel.app/api';

  static Future<GuideResult> fetchGuide({
    required SajuInfo sajuInfo,
    required String language,
    bool forceNetwork = false,
  }) async {
    final currentDate = DateTime.now();
    final String currentDateStr =
        '${currentDate.year.toString().padLeft(4, '0')}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';

    final body = {
      'birthYear': sajuInfo.birthDate.year,
      'birthMonth': sajuInfo.birthDate.month,
      'birthDay': sajuInfo.birthDate.day,
      'birthHour': sajuInfo.birthHour,
      'birthMinute': sajuInfo.birthMinute,
      'gender': _normalizeGender(sajuInfo.gender),
      'location': sajuInfo.region,
      'loveStatus': _normalizeLoveStatus(sajuInfo.loveStatus),
      'currentDate': currentDateStr,
      'language': _normalizeLanguage(language),
    };
    
    print('🔍 Guide API 요청 데이터: ${jsonEncode(body)}');
    print('🔍 birthMinute 값: ${sajuInfo.birthMinute} (타입: ${sajuInfo.birthMinute.runtimeType})');

    if (kDebugMode && !forceNetwork) {
      // 간단한 더미 응답 (개발 중 서버 미연결 대비)
      return GuideResult(
        love: 'Dummy Love',
        wealth: 'Dummy Wealth',
        health: 'Dummy Health',
        study: 'Dummy Study',
        overall: 'Dummy Overall',
      );
    }

    final uri = Uri.parse('$_baseUrl/saju');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'SajuApp/1.0',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json; // 호환
      return GuideResult(
        love: data['love'] ?? '',
        wealth: data['wealth'] ?? '',
        health: data['health'] ?? '',
        study: data['study'] ?? '',
        overall: data['overall'] ?? '',
      );
    }

    throw Exception('Guide API error: ${response.statusCode} - ${response.body}');
  }

  static String _normalizeLanguage(String code) {
    switch (code) {
      case 'ko':
      case 'en':
      case 'ja':
      case 'zh':
        return code;
      default:
        return 'en';
    }
  }

  // moved to SajuService during save/load normalization
  static String _normalizeGender(String gender) => gender;
  static String? _normalizeLoveStatus(String? status) => status;
}

class GuideResult {
  final String love;
  final String wealth;
  final String health;
  final String study;
  final String overall;

  GuideResult({
    required this.love,
    required this.wealth,
    required this.health,
    required this.study,
    required this.overall,
  });
}



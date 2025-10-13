import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/saju_info.dart';

class SajuApiService {
  // 서버 베이스 URL (디버그는 로컬, 릴리즈는 Vercel)
  // NOTE:
  //  - 로컬 개발 시: 아래 _devBaseUrl 사용 (3000 포트에 sajuServer가 떠 있어야 함)
  //  - 디버그에서도 Vercel로 강제하려면 _baseUrl에서 kDebugMode 분기를 제거하고
  //    'https://saju-server-j9ti.vercel.app/api' 를 직접 반환하세요.
  static String get _devBaseUrl {
    // Android 에뮬레이터에서는 호스트의 localhost가 10.0.2.2로 매핑됩니다.
    // if (defaultTargetPlatform == TargetPlatform.android) {
    //   return 'http://10.0.2.2:3000/api';
    // }
    // iOS 시뮬레이터/데스크탑은 localhost 사용
    // return 'http://localhost:3000/api';
    // 디버그에서도 Vercel 고정 사용 (로컬 충돌 회피)
    return 'https://saju-server-j9ti.vercel.app/api';
  }
  // 서버 베이스 URL (디버그는 로컬, 릴리즈는 Vercel)
  // 디버그에서 localhost 충돌(다른 서버 점유 등) 시 아래처럼 Vercel 고정을 권장:
  // static String get _baseUrl => 'https://saju-server-j9ti.vercel.app/api';
  static String get _baseUrl => kDebugMode
      ? _devBaseUrl
      : 'https://saju-server-j9ti.vercel.app/api';

  // Fire-and-forget: record a visit on splash entry. Nation is resolved on server via geo headers.
  static Future<void> logVisit({required String language}) async {
    try {
      final uri = Uri.parse('$_baseUrl/visit');
      await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'SajuApp/1.0 ${Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Unknown'}',
          'x-client-os': Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'unknown',
        },
        // 서버가 geo 헤더로 nation을 계산하므로 최소 정보만 전달
        body: jsonEncode({
          'language': _normalizeLanguage(language),
          'event': 'splash_visit',
          'ts': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {
      // no-op: logging failure should not block app
    }
  }

  static Future<GuideResult> fetchGuide({
    required SajuInfo sajuInfo,
    required String language,
  }) async {
    final currentDate = DateTime.now();
    final String currentDateStr =
        '${currentDate.year.toString().padLeft(4, '0')}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';

    final body = {
      'birthYear': sajuInfo.birthDate.year,
      'birthMonth': sajuInfo.birthDate.month,
      'birthDay': sajuInfo.birthDate.day,
      'gender': _normalizeGender(sajuInfo.gender),
      'location': sajuInfo.region ?? '',
      'tone': _normalizetone(sajuInfo.tone) ?? '',
      'currentDate': currentDateStr,
      'language': _normalizeLanguage(language),
    };
    
    print('🔍 Guide API 요청 데이터: ${jsonEncode(body)}');

    final uri = Uri.parse('$_baseUrl/saju');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'SajuApp/1.0 ${Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Unknown'}',
        'x-client-os': Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'unknown',
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
        servedDate: (data['servedDate'] as String?)?.trim(),
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
  static String? _normalizetone(String? status) => status;
}

class GuideResult {
  final String love;
  final String wealth;
  final String health;
  final String study;
  final String overall;
  final String? servedDate; // YYYY-MM-DD from server

  GuideResult({
    required this.love,
    required this.wealth,
    required this.health,
    required this.study,
    required this.overall,
    this.servedDate,
  });
}



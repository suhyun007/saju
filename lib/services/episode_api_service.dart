import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/saju_info.dart';

class EpisodeApiService {
  // 서버 베이스 URL (디버그는 로컬, 릴리즈는 Vercel)
  static String get _devBaseUrl {
    // Android 에뮬레이터에서는 호스트의 localhost가 10.0.2.2로 매핑됩니다.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    // iOS 시뮬레이터/데스크탑은 localhost 사용
    return 'http://localhost:3000/api';
  }

  static String get _baseUrl => kDebugMode
      ? _devBaseUrl
      : 'https://saju-server-j9ti.vercel.app/api';

  static Future<EpisodeResult> fetchEpisode({
    required SajuInfo sajuInfo,
    String genre = 'daily',
    required String language,
  }) async {
    final currentDate = DateTime.now();
    final String currentDateStr =
        '${currentDate.year.toString().padLeft(4, '0')}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';

    final body = {
      'ageGroup': sajuInfo.ageGroup ?? '13',
      'gender': sajuInfo.gender,
      'world': sajuInfo.world ?? 'none',
      'loveStatus': sajuInfo.loveStatus ?? 'warm',
      'currentDate': currentDateStr,
      // 서버에서 장르/날씨/아이템/플롯을 결정
      'language': _normalizeLanguage(language),
    };

    final uri = Uri.parse('$_baseUrl/episode');
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
      return EpisodeResult(
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        contentLength: data['contentLength'] is int
            ? data['contentLength']
            : int.tryParse('${data['contentLength']}') ?? 0,
        summary: data['summary'] ?? '',
        tomorrowSummary: data['tomorrowSummary'] ?? '',
        servedDate: (data['servedDate'] as String?)?.trim(),
      );
    }

    throw Exception('Episode API error: ${response.statusCode} - ${response.body}');
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

class EpisodeResult {
  final String title;
  final String content;
  final int contentLength;
  final String summary;
  final String tomorrowSummary;
  final String? servedDate; // YYYY-MM-DD from server

  EpisodeResult({
    required this.title,
    required this.content,
    required this.contentLength,
    required this.summary,
    required this.tomorrowSummary,
    this.servedDate,
  });
}



import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/saju_info.dart';

class EpisodeApiService {
  // 서버 베이스 URL은 기존 사주 API와 동일
  static const String _baseUrl = 'https://saju-server-j9ti.vercel.app/api';

  static Future<EpisodeResult> fetchEpisode({
    required SajuInfo sajuInfo,
    String genre = 'daily',
    required String language,
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
      'gender': sajuInfo.gender,
      'location': sajuInfo.region,
      'loveStatus': sajuInfo.loveStatus,
      'currentDate': currentDateStr,
      'genre': genre,
      'language': _normalizeLanguage(language),
    };

    if (kDebugMode) {
      // 간단한 더미 응답 (개발 중 서버 미연결 대비)
      return EpisodeResult(
        title: 'Dummy Episode',
        content: 'This is a locally generated dummy episode for development mode.',
        contentLength: 64,
        summary: 'A short dummy summary',
        tomorrowSummary: 'Tomorrow will bring a brighter story.',
      );
    }

    final uri = Uri.parse('$_baseUrl/episode');
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
      return EpisodeResult(
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        contentLength: data['contentLength'] is int
            ? data['contentLength']
            : int.tryParse('${data['contentLength']}') ?? 0,
        summary: data['summary'] ?? '',
        tomorrowSummary: data['tomorrowSummary'] ?? '',
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
}

class EpisodeResult {
  final String title;
  final String content;
  final int contentLength;
  final String summary;
  final String tomorrowSummary;

  EpisodeResult({
    required this.title,
    required this.content,
    required this.contentLength,
    required this.summary,
    required this.tomorrowSummary,
  });
}



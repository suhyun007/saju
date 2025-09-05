import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/saju_info.dart';

class PoetryApiService {
  static const String _baseUrl = 'https://saju-server-j9ti.vercel.app/api';

  static Future<PoetryResult> fetchPoetry({
    required SajuInfo sajuInfo,
    required String language,
    String prompt = 'daily',
  }) async {
    final now = DateTime.now();
    final currentDate = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final body = {
      'birthYear': sajuInfo.birthDate.year,
      'birthMonth': sajuInfo.birthDate.month,
      'birthDay': sajuInfo.birthDate.day,
      'birthHour': sajuInfo.birthHour,
      'birthMinute': sajuInfo.birthMinute,
      'gender': sajuInfo.gender == 'male' ? 'male' : 'female', // 서버 현재 제약 대응
      'location': sajuInfo.region,
      'loveStatus': sajuInfo.loveStatus,
      'currentDate': currentDate,
      'prompt': prompt,
      'language': _normalizeLanguage(language),
    };

    if (kDebugMode) {
      return PoetryResult(
        content: '바람이 귓가에 건네준 오늘의 짧은 시\n\n작은 용기가\n하루의 문을 연다',
      );
    }

    final resp = await http.post(
      Uri.parse('$_baseUrl/poetry'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'SajuApp/1.0',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final content = (json['poetry'] ?? json['data']?['poetry'] ?? '').toString();
      return PoetryResult(content: content);
    }

    throw Exception('Poetry API error: ${resp.statusCode} - ${resp.body}');
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

class PoetryResult {
  final String content;
  PoetryResult({ required this.content });
}



import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/saju_info.dart';

class PoetryApiService {
  // 서버 베이스 URL (디버그는 로컬, 릴리즈는 Vercel)
  // NOTE:
  //  - 디버그에서 localhost 충돌 시 Vercel 고정을 고려하세요
  //    예) static String get _baseUrl => 'https://saju-server-j9ti.vercel.app/api';
  static String get _devBaseUrl {
    // 디버그에서도 Vercel 고정 사용 (로컬 3000 충돌 회피)
    return 'https://saju-server-j9ti.vercel.app/api';
  }

  static String get _baseUrl => kDebugMode
      ? _devBaseUrl
      : 'https://saju-server-j9ti.vercel.app/api';

  // 사물 아이템 (랜덤)
  static const List<String> _allowedItems = [
    'letter', 'oldPhoto', 'musicBox', 'umbrella', 'book', 'coffee', 'pendant', 'lantern', 'flower', 'watch',
    'Guiding lantern', 'Lucky charm', 'Healing crystal', 'Golden key', 'Treasure chest', 'Feather of hope', 
    'Enchanted harp', 'Friendship bracelet', 'Magic ink pen', 'Love letter', 'Eternal candle', 'Blossoming flower', 
    'Starlight pendant', 'Dreamcatcher', 'Rainbow shell', 'Angel’s feather', 'Music box', 'Sunstone', 'Healing herb pouch', 
    'Storybook', 'Sapphire ring', 'Festival mask', 'Dove feather', 'Fortune cookie', 'Secret diary', 'Warm blanket', 'Silver locket', 
    'Harmony flute', 'Memory photograph', 'Garden seed packet', 'Bright ribbon', 'Lantern of wishes', 'Guiding compass', 
    'Magical paintbrush', 'Lucky coin', 'Celebration crown', 'Bottle of fireflies', 'Shooting star charm', 'Happy balloon', 
    'Blooming wreath', 'Traveler’s map', 'Peace bell', 'Rainbow crystal', 'Dream journal', 'Songbird cage', 'Hope scroll', 
    'Candle of friendship', 'Healing potion', 'Birthday cake', 'Sunrise painting'
  ];

  static String _dailyItemFor(DateTime date) {
    final key = 'i-${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final idx = key.hashCode.abs() % _allowedItems.length;
    return _allowedItems[idx];
  }    

  static Future<PoetryResult> fetchPoetry({
    required SajuInfo sajuInfo,
    required String language,
    String prompt = 'daily',
  }) async {
    final currentDate = DateTime.now();
    final String currentDateStr =
        '${currentDate.year.toString().padLeft(4, '0')}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
    final body = {
      'ageGroup': sajuInfo.ageGroup ?? '13',
      'gender': sajuInfo.gender, // 서버 현재 제약 대응
      'world': sajuInfo.world ?? 'none',
      'tone': sajuInfo.tone ?? 'warm',
      'growthTheme': sajuInfo.growthTheme,
      'loveRelation': sajuInfo.loveRelation,
      'worldAction': sajuInfo.worldAction,
      'currentDate': currentDateStr,
      'prompt': prompt,
      'language': _normalizeLanguage(language),
    };

    print('🔍 Guide API 요청 데이터: ${jsonEncode(body)}');

    final resp = await http.post(
      Uri.parse('$_baseUrl/poetry'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'SajuApp/1.0 ${Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Unknown'}',
        'x-client-os': Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'unknown',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      final raw = jsonDecode(resp.body) as Map<String, dynamic>;
      final data = (raw['data'] is Map<String, dynamic>) ? raw['data'] as Map<String, dynamic> : raw;
      final title = (data['title'] ?? '').toString();
      final poem = (data['poem'] ?? data['poetry'] ?? data['content'] ?? '').toString();
      final summary = (data['summary'] ?? '').toString();
      final tomorrowHint = (data['tomorrowHint'] ?? data['tomorrowSummary'] ?? '').toString();
      return PoetryResult(
        title: title,
        content: poem,
        summary: summary,
        tomorrowHint: tomorrowHint,
        servedDate: (data['servedDate'] as String?)?.trim(),
      );
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
  final String title;
  final String content;
  final String summary;
  final String tomorrowHint;
  final String? servedDate; // YYYY-MM-DD from server

  PoetryResult({ required this.title, required this.content, required this.summary, required this.tomorrowHint, this.servedDate });
}



import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saju_info.dart';

class DailyFortune {
  final int score;
  final String message;
  final String advice;
  final String category;
  final DateTime date;

  DailyFortune({
    required this.score,
    required this.message,
    required this.advice,
    required this.category,
    required this.date,
  });

  factory DailyFortune.fromJson(Map<String, dynamic> json) {
    return DailyFortune(
      score: json['score'] ?? 0,
      message: json['message'] ?? '',
      advice: json['advice'] ?? '',
      category: json['category'] ?? 'general',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class DailyFortuneService {
  // Vercel API를 사용하므로 더미 데이터 생성 함수들은 제거
  // 실제 API 호출만 유지
  
  static const String _baseUrl = 'https://saju-server-j9ti.vercel.app/api';
  
  // 오늘의 운세를 API에서 가져오기
  static Future<DailyFortune> getTodayFortune(SajuInfo? sajuInfo) async {
    try {
      // Vercel API 호출
      final response = await http.post(
        Uri.parse('$_baseUrl/saju'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'birthYear': sajuInfo?.birthDate.year ?? DateTime.now().year,
          'birthMonth': sajuInfo?.birthDate.month ?? DateTime.now().month,
          'birthDay': sajuInfo?.birthDate.day ?? DateTime.now().day,
          'birthHour': sajuInfo?.birthHour ?? 12,
          'birthMinute': sajuInfo?.birthMinute ?? 0,
          'gender': sajuInfo?.gender == '남성' ? 'male' : 'female',
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final todayFortune = jsonData['data']['today_fortune'];
          return DailyFortune(
            score: 85, // 기본 점수
            message: todayFortune['overall'] ?? '오늘은 평온한 하루가 될 것입니다.',
            advice: todayFortune['advice'] ?? '차분한 마음으로 하루를 보내시기 바랍니다.',
            category: 'personalized',
            date: DateTime.now(),
          );
        } else {
          throw Exception('API 응답 오류: ${jsonData['error']}');
        }
      } else {
        throw Exception('API 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('운세 API 호출 실패: $e');
      // 기본 운세 반환
      return DailyFortune(
        score: 70,
        message: '오늘은 평온한 하루가 될 것입니다.',
        advice: '차분한 마음으로 하루를 보내시기 바랍니다.',
        category: 'general',
        date: DateTime.now(),
      );
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    // 디버그 모드에서는 더미 데이터 사용
    if (kDebugMode) {
      print('🔧 디버그 모드: 운세 API 호출 대신 더미 데이터 사용');
      return _getDummyTodayFortune(sajuInfo);
    }
    
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

  // 디버그 모드용 더미 운세 데이터 생성
  static Future<DailyFortune> _getDummyTodayFortune(SajuInfo? sajuInfo) async {
    print('🔧 더미 운세 데이터 생성 시작');
    
    // API 호출 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));
    
    final messages = [
      '오늘은 새로운 기회가 찾아올 수 있는 날입니다.',
      '조용하고 평온한 하루를 보낼 수 있을 것입니다.',
      '주변 사람들과의 소통이 중요한 날입니다.',
      '창의적인 아이디어가 떠오를 수 있는 날입니다.',
      '건강 관리에 신경 쓰면 좋은 하루가 될 것입니다.',
    ];
    
    final advices = [
      '긍정적인 마음가짐으로 하루를 보내시기 바랍니다.',
      '인내심을 가지고 상황을 바라보세요.',
      '주변 사람들의 조언을 귀담아들어보세요.',
      '새로운 도전을 해볼 좋은 기회입니다.',
      '자신의 감정을 솔직하게 표현해보세요.',
    ];
    
    // 사용자 정보를 기반으로 한 인덱스 생성
    final seed = (sajuInfo?.birthDate.year ?? DateTime.now().year) + 
                 (sajuInfo?.birthDate.month ?? DateTime.now().month) + 
                 (sajuInfo?.birthDate.day ?? DateTime.now().day) + 
                 (sajuInfo?.birthHour ?? 12);
    
    final result = DailyFortune(
      score: 75 + (seed % 20), // 75-94 점수 범위
      message: messages[seed % messages.length],
      advice: advices[seed % advices.length],
      category: 'personalized',
      date: DateTime.now(),
    );
    
    print('🔧 더미 운세 데이터 생성 완료');
    
    return result;
  }
}

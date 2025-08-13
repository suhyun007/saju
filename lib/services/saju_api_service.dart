import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saju_api_response.dart';
import '../models/saju_info.dart';

class SajuApiService {
  static const String _baseUrl = 'https://sajugpt.co.kr/api';
  
  // 사주 계산 API 호출
  static Future<SajuApiResponse> getSajuAnalysis(SajuInfo sajuInfo) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/saju/calculate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'birthDate': sajuInfo.birthDate.toIso8601String(),
          'birthHour': sajuInfo.birthHour,
          'birthMinute': sajuInfo.birthMinute,
          'gender': sajuInfo.gender,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SajuApiResponse.fromJson(jsonData);
      } else {
        return SajuApiResponse(
          success: false,
          message: 'API 호출 실패: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SajuApiResponse(
        success: false,
        message: '네트워크 오류: $e',
      );
    }
  }

  // 간단한 사주 정보 조회 (API가 없을 경우를 대비한 대체 메서드)
  static Future<SajuApiResponse> getSimpleSajuAnalysis(SajuInfo sajuInfo) async {
    // 실제 API가 없을 경우를 대비한 더미 데이터
    await Future.delayed(const Duration(seconds: 2)); // API 호출 시뮬레이션
    
    final dummyData = SajuData(
      yearSaju: _calculateSimpleSaju(sajuInfo.birthDate.year),
      monthSaju: _calculateSimpleSaju(sajuInfo.birthDate.month),
      daySaju: _calculateSimpleSaju(sajuInfo.birthDate.day),
      hourSaju: _calculateSimpleSaju(sajuInfo.birthHour),
      yearText: '${sajuInfo.birthDate.year}년',
      monthText: '${sajuInfo.birthDate.month}월',
      dayText: '${sajuInfo.birthDate.day}일',
      hourText: '${sajuInfo.birthHour.toString().padLeft(2, '0')}:${sajuInfo.birthMinute.toString().padLeft(2, '0')}',
      analysis: '당신의 사주를 분석한 결과, ${sajuInfo.gender == '남성' ? '남성' : '여성'}의 운세는 평온하고 안정적입니다. 인내심과 끈기가 당신의 큰 장점입니다.',
      fortune: '오늘은 새로운 시작에 좋은 날입니다. 용기를 가지고 도전해보세요.',
    );

    return SajuApiResponse(
      success: true,
      message: '사주 분석 완료',
      data: dummyData,
    );
  }

  static String _calculateSimpleSaju(int value) {
    final sajuList = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'];
    return sajuList[value % 10];
  }
}

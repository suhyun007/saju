import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saju_api_response.dart';
import '../models/saju_info.dart';

class SajuApiService {
  // Vercel에 배포된 새로운 사주 API URL
  static const String _baseUrl = 'https://saju-server-j9ti.vercel.app/api';
  
  // 사주 계산 API 호출
  static Future<SajuApiResponse> getSajuAnalysis(SajuInfo sajuInfo) async {
    try {
      print('사주 분석 API 호출 시작: ${sajuInfo.birthDate} ${sajuInfo.gender}');
      
      // 새로운 API 형식에 맞는 요청 데이터
      final requestBody = {
        'birthYear': sajuInfo.birthDate.year,
        'birthMonth': sajuInfo.birthDate.month,
        'birthDay': sajuInfo.birthDate.day,
        'birthHour': sajuInfo.birthHour,
        'birthMinute': sajuInfo.birthMinute,
        'gender': sajuInfo.gender == '남성' ? 'male' : 'female',
      };
      
      print('API 요청 데이터: ${jsonEncode(requestBody)}');
      print('API URL: $_baseUrl/saju');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/saju'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'SajuApp/1.0',
        },
        body: jsonEncode(requestBody),
      );

      print('API 응답 상태 코드: ${response.statusCode}');
      print('API 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final result = SajuApiResponse.fromJson(jsonData);
        print('API 호출 성공: ${result.success}');
        
        if (result.success) {
          print('사주 데이터: ${result.data?.saju}');
          print('오늘의 운세: ${result.data?.todayFortune?.overall}');
        } else {
          print('API 오류: ${result.error}');
        }
        
        return result;
      } else {
        print('API 호출 실패: ${response.statusCode} - ${response.body}');
        return SajuApiResponse(
          success: false,
          error: 'API 호출 실패: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('사주 분석 API 호출 중 오류: $e');
      return SajuApiResponse(
        success: false,
        error: '네트워크 오류: $e',
      );
    }
  }

  // 서버 상태 확인
  static Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/saju'),
        headers: {
          'User-Agent': 'SajuApp/1.0',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('서버 상태 확인 중 오류: $e');
      return false;
    }
  }

  // 간단한 사주 정보 조회 (API가 없을 경우를 대비한 대체 메서드)
  static Future<SajuApiResponse> getSimpleSajuAnalysis(SajuInfo sajuInfo) async {
    print('더미 데이터 사주 분석 시작: ${sajuInfo.birthDate} ${sajuInfo.gender}');
    
    // 실제 API가 없을 경우를 대비한 더미 데이터
    await Future.delayed(const Duration(seconds: 2)); // API 호출 시뮬레이션
    
    final dummyData = SajuData(
      saju: '庚午甲申',
      elements: SajuElements(
        year: '庚',
        month: '午',
        day: '甲',
        hour: '申',
      ),
      todayFortune: TodayFortune(
        overall: '오늘은 새로운 기회가 찾아올 수 있는 날입니다.',
        wealth: '재정적으로 안정적인 하루가 될 것입니다.',
        health: '건강에 특별한 문제는 없을 것입니다.',
        love: '연애운이 좋은 하루입니다.',
        advice: '긍정적인 마음가짐으로 하루를 보내시기 바랍니다.',
      ),
      // 기존 호환성을 위한 필드들
      yearSaju: '庚',
      monthSaju: '午',
      daySaju: '甲',
      hourSaju: '申',
      yearText: '${sajuInfo.birthDate.year}년',
      monthText: '${sajuInfo.birthDate.month}월',
      dayText: '${sajuInfo.birthDate.day}일',
      hourText: '${sajuInfo.birthHour.toString().padLeft(2, '0')}:${sajuInfo.birthMinute.toString().padLeft(2, '0')}',
      analysis: '당신의 사주를 분석한 결과, ${sajuInfo.gender == '남성' ? '남성' : '여성'}의 운세는 평온하고 안정적입니다. 인내심과 끈기가 당신의 큰 장점입니다.',
      fortune: '오늘은 새로운 시작에 좋은 날입니다. 용기를 가지고 도전해보세요.',
    );

    print('더미 데이터 생성 완료');
    
    return SajuApiResponse(
      success: true,
      message: '사주 분석 완료 (더미 데이터)',
      data: dummyData,
    );
  }

  static String _calculateSimpleSaju(int value) {
    final sajuList = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'];
    return sajuList[value % 10];
  }
}

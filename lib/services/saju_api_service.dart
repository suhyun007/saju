import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saju_api_response.dart';
import '../models/saju_info.dart';

class SajuApiService {
  static const String _baseUrl = 'https://sajugpt.co.kr/api';
  static const String _alternativeUrl = 'https://sajugpt.co.kr/api/v1';
  
  // 사주 계산 API 호출
  static Future<SajuApiResponse> getSajuAnalysis(SajuInfo sajuInfo) async {
    try {
      print('사주 분석 API 호출 시작: ${sajuInfo.birthDate} ${sajuInfo.gender}');
      
      final requestBody = {
        'birthDate': sajuInfo.birthDate.toIso8601String(),
        'birthHour': sajuInfo.birthHour,
        'birthMinute': sajuInfo.birthMinute,
        'gender': sajuInfo.gender,
      };
      
      print('API 요청 데이터: ${jsonEncode(requestBody)}');
      
      // 여러 URL 시도
      final urls = [
        '$_baseUrl/saju/calculate',
        '$_alternativeUrl/saju/calculate',
        '$_baseUrl/calculate',
        '$_alternativeUrl/calculate',
      ];
      
      // 리다이렉트를 허용하는 클라이언트 생성
      final client = http.Client();
      
      try {
        for (final url in urls) {
          try {
            print('API URL 시도: $url');
            
            final response = await client.post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'User-Agent': 'SajuApp/1.0',
              },
              body: jsonEncode(requestBody),
            );

            print('API 응답 상태 코드: ${response.statusCode}');
            print('API 응답 본문: ${response.body}');
            print('API 응답 헤더: ${response.headers}');

            if (response.statusCode == 200) {
              final jsonData = jsonDecode(response.body);
              final result = SajuApiResponse.fromJson(jsonData);
              print('API 호출 성공: ${result.success}');
              return result;
            } else if (response.statusCode == 308) {
              // 리다이렉트 처리
              final location = response.headers['location'];
              if (location != null) {
                print('리다이렉트 URL: $location');
                
                final redirectResponse = await client.post(
                  Uri.parse(location),
                  headers: {
                    'Content-Type': 'application/json',
                    'User-Agent': 'SajuApp/1.0',
                  },
                  body: jsonEncode(requestBody),
                );
                
                print('리다이렉트 후 응답 상태 코드: ${redirectResponse.statusCode}');
                print('리다이렉트 후 응답 본문: ${redirectResponse.body}');
                
                if (redirectResponse.statusCode == 200) {
                  final jsonData = jsonDecode(redirectResponse.body);
                  final result = SajuApiResponse.fromJson(jsonData);
                  print('리다이렉트 후 API 호출 성공: ${result.success}');
                  return result;
                }
              }
              
              print('리다이렉트 처리 실패, 다음 URL 시도');
              continue;
            } else {
              print('API 호출 실패: ${response.statusCode} - ${response.body}, 다음 URL 시도');
              continue;
            }
          } catch (urlError) {
            print('URL $url 호출 중 오류: $urlError, 다음 URL 시도');
            continue;
          }
        }
        
        // 모든 URL 시도 실패
        print('모든 API URL 시도 실패');
        return SajuApiResponse(
          success: false,
          message: '모든 API 엔드포인트 시도 실패',
        );
      } finally {
        client.close();
      }
    } catch (e) {
      print('사주 분석 API 호출 중 오류: $e');
      return SajuApiResponse(
        success: false,
        message: '네트워크 오류: $e',
      );
    }
  }

  // 간단한 사주 정보 조회 (API가 없을 경우를 대비한 대체 메서드)
  static Future<SajuApiResponse> getSimpleSajuAnalysis(SajuInfo sajuInfo) async {
    print('더미 데이터 사주 분석 시작: ${sajuInfo.birthDate} ${sajuInfo.gender}');
    
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

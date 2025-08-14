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
  static const String _baseUrl = 'https://sajugpt.co.kr/api';
  static const bool _useTestMode = true; // 테스트 모드 활성화
  
  // 오늘의 운세를 API에서 가져오기
  static Future<DailyFortune> getTodayFortune(SajuInfo? sajuInfo) async {
    // 테스트 모드일 때는 시뮬레이션된 API 응답 사용
    if (_useTestMode) {
      return _simulateApiResponse(sajuInfo);
    }
    
    try {
      // 실제 API 호출
      final response = await http.post(
        Uri.parse('$_baseUrl/fortune/daily'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'date': DateTime.now().toIso8601String(),
          if (sajuInfo != null) ...{
            'birthDate': sajuInfo.birthDate.toIso8601String(),
            'birthHour': sajuInfo.birthHour,
            'birthMinute': sajuInfo.birthMinute,
            'gender': sajuInfo.gender,
          }
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return DailyFortune.fromJson(jsonData);
      } else {
        throw Exception('API 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('운세 API 호출 실패: $e');
      rethrow; // 에러를 상위로 전파
    }
  }

  // 테스트용 API 응답 시뮬레이션
  static Future<DailyFortune> _simulateApiResponse(SajuInfo? sajuInfo) async {
    // API 호출 시뮬레이션 (2초 지연)
    await Future.delayed(const Duration(seconds: 2));
    
    final now = DateTime.now();
    final key = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final int score = (key % 101).toInt();
    
    // 사주 정보가 있으면 개인화된 운세, 없으면 일반 운세
    if (sajuInfo != null) {
      return _generatePersonalizedFortune(sajuInfo, key);
    } else {
      return _generateGeneralFortune(key);
    }
  }

  // 개인화된 운세 생성 (테스트용)
  static DailyFortune _generatePersonalizedFortune(SajuInfo sajuInfo, int key) {
    final int score = (key % 101).toInt();
    final int messageIndex = (key % 20).toInt();
    final int adviceIndex = (key % 15).toInt();
    
    final List<String> messages = [
      '${sajuInfo.gender == '남성' ? '남성' : '여성'}의 기운이 강한 날입니다. 자신감을 가지고 도전해보세요.',
      '생년월일시의 기운이 좋은 날입니다. 새로운 시작에 적합합니다.',
      '사주에서 보이는 인내심이 오늘 도움이 될 것입니다.',
      '당신의 사주가 가진 창의성이 발휘될 수 있는 날입니다.',
      '건강에 특별히 신경 쓰는 것이 좋겠습니다. 사주에서 보이는 약점을 보완하세요.',
      '금전적으로 안정적인 하루가 될 것입니다. 사주의 재물운이 좋습니다.',
      '학습과 성장에 도움이 되는 날입니다. 사주의 지혜로운 기운을 활용하세요.',
      '가족과의 소통이 더욱 깊어질 것입니다. 사주의 가족운이 좋습니다.',
      '직장에서 인정받는 날이 될 것입니다. 사주의 관운이 좋습니다.',
      '새로운 사람을 만날 수 있는 기회가 있습니다. 사주의 인연운이 좋습니다.',
      '여행이나 외출이 행운을 가져올 것입니다. 사주의 이동운이 좋습니다.',
      '예술적 감각이 예민해지는 날입니다. 사주의 예술운을 활용하세요.',
      '정신적 평화를 찾을 수 있는 하루입니다. 사주의 평온한 기운을 느껴보세요.',
      '도전적인 일에 성공할 가능성이 높습니다. 사주의 용기운이 좋습니다.',
      '사랑과 로맨스에 좋은 기운이 감지됩니다. 사주의 연애운이 좋습니다.',
      '지혜로운 결정을 내릴 수 있는 날입니다. 사주의 지혜운을 활용하세요.',
      '친구들과의 만남이 특별한 의미를 가질 것입니다. 사주의 인연운이 좋습니다.',
      '자신의 꿈을 향해 한 걸음 나아갈 수 있습니다. 사주의 목표운이 좋습니다.',
      '자연과의 교감이 마음을 치유할 것입니다. 사주의 자연운을 활용하세요.',
      '과거의 노력이 인정받는 날이 될 것입니다. 사주의 성취운이 좋습니다.',
      '${sajuInfo.birthDate.year}년생의 특별한 기운이 오늘 발휘될 것입니다.',
    ];
    
    final List<String> advices = [
      '💡 새로운 도전을 시작해보세요. 사주의 용기운이 도와줄 것입니다.',
      '🌱 건강한 습관을 만들어보세요. 사주의 건강운을 보완하세요.',
      '💝 사랑하는 사람에게 마음을 표현해보세요. 사주의 연애운이 좋습니다.',
      '📚 새로운 지식을 습득해보세요. 사주의 학업운을 활용하세요.',
      '🎨 창의적인 활동에 시간을 투자해보세요. 사주의 예술운이 좋습니다.',
      '🏃‍♂️ 운동으로 활력을 되찾아보세요. 사주의 건강운을 보완하세요.',
      '🍀 행운을 부르는 색깔을 입어보세요. 사주의 행운운을 강화하세요.',
      '🌅 일찍 일어나서 아침을 만끽해보세요. 사주의 새벽운이 좋습니다.',
      '🎵 좋아하는 음악을 들으며 휴식을 취해보세요. 사주의 평온운을 활용하세요.',
      '📝 감사한 일들을 적어보세요. 사주의 감사운을 강화하세요.',
      '🌿 자연 속에서 힐링 시간을 가져보세요. 사주의 자연운을 활용하세요.',
      '🤝 새로운 사람들과 대화해보세요. 사주의 인연운이 좋습니다.',
      '🎯 목표를 다시 한번 점검해보세요. 사주의 목표운을 강화하세요.',
      '💪 자신에게 긍정적인 말을 해보세요. 사주의 자신감운을 강화하세요.',
      '🌟 작은 성취를 축하해보세요. 사주의 성취운을 활용하세요.',
    ];
    
    return DailyFortune(
      score: score,
      message: messages[messageIndex],
      advice: advices[adviceIndex],
      category: 'personalized',
      date: DateTime.now(),
    );
  }

  // 일반적인 운세 생성 (테스트용)
  static DailyFortune _generateGeneralFortune(int key) {
    final int score = (key % 101).toInt();
    final int messageIndex = (key % 20).toInt();
    final int adviceIndex = (key % 15).toInt();
    
    final List<String> messages = [
      '오늘은 새로운 시작에 좋은 날입니다.',
      '행운이 당신을 찾아올 것입니다.',
      '인간관계에서 좋은 소식이 있을 것입니다.',
      '창의적인 아이디어가 떠오를 것입니다.',
      '건강에 특별히 신경 쓰는 것이 좋겠습니다.',
      '금전적으로 안정적인 하루가 될 것입니다.',
      '학습과 성장에 도움이 되는 날입니다.',
      '가족과의 소통이 더욱 깊어질 것입니다.',
      '직장에서 인정받는 날이 될 것입니다.',
      '새로운 사람을 만날 수 있는 기회가 있습니다.',
      '여행이나 외출이 행운을 가져올 것입니다.',
      '예술적 감각이 예민해지는 날입니다.',
      '정신적 평화를 찾을 수 있는 하루입니다.',
      '도전적인 일에 성공할 가능성이 높습니다.',
      '사랑과 로맨스에 좋은 기운이 감지됩니다.',
      '지혜로운 결정을 내릴 수 있는 날입니다.',
      '친구들과의 만남이 특별한 의미를 가질 것입니다.',
      '자신의 꿈을 향해 한 걸음 나아갈 수 있습니다.',
      '자연과의 교감이 마음을 치유할 것입니다.',
      '과거의 노력이 인정받는 날이 될 것입니다.',
    ];
    
    final List<String> advices = [
      '💡 새로운 도전을 시작해보세요.',
      '🌱 건강한 습관을 만들어보세요.',
      '💝 사랑하는 사람에게 마음을 표현해보세요.',
      '📚 새로운 지식을 습득해보세요.',
      '🎨 창의적인 활동에 시간을 투자해보세요.',
      '🏃‍♂️ 운동으로 활력을 되찾아보세요.',
      '🍀 행운을 부르는 색깔을 입어보세요.',
      '🌅 일찍 일어나서 아침을 만끽해보세요.',
      '🎵 좋아하는 음악을 들으며 휴식을 취해보세요.',
      '📝 감사한 일들을 적어보세요.',
      '🌿 자연 속에서 힐링 시간을 가져보세요.',
      '🤝 새로운 사람들과 대화해보세요.',
      '🎯 목표를 다시 한번 점검해보세요.',
      '💪 자신에게 긍정적인 말을 해보세요.',
      '🌟 작은 성취를 축하해보세요.',
    ];
    
    return DailyFortune(
      score: score,
      message: messages[messageIndex],
      advice: advices[adviceIndex],
      category: 'general',
      date: DateTime.now(),
    );
  }
}

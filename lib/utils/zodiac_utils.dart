class ZodiacUtils {
  // 별자리 정보
  static const Map<String, List<int>> zodiacDates = {
    '양자리': [3, 21, 4, 19],
    '황소자리': [4, 20, 5, 20],
    '쌍둥이자리': [5, 21, 6, 21],
    '게자리': [6, 22, 7, 22],
    '사자자리': [7, 23, 8, 22],
    '처녀자리': [8, 23, 9, 22],
    '천칭자리': [9, 23, 10, 22],
    '전갈자리': [10, 23, 11, 22],
    '사수자리': [11, 23, 12, 21],
    '염소자리': [12, 22, 1, 19],
    '물병자리': [1, 20, 2, 18],
    '물고기자리': [2, 19, 3, 20],
  };

  /// 생년월일을 기반으로 별자리를 계산합니다.
  static String getZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    // 각 별자리의 시작일과 종료일을 확인
    for (final entry in zodiacDates.entries) {
      final zodiacName = entry.key;
      final dates = entry.value;
      
      if (_isInZodiacPeriod(month, day, dates)) {
        return zodiacName;
      }
    }

    // 기본값 (이론적으로는 도달하지 않아야 함)
    return '알 수 없음';
  }

  /// 특정 월/일이 별자리 기간에 속하는지 확인합니다.
  static bool _isInZodiacPeriod(int month, int day, List<int> dates) {
    final startMonth = dates[0];
    final startDay = dates[1];
    final endMonth = dates[2];
    final endDay = dates[3];

    // 염소자리 (12월 22일 ~ 1월 19일)는 연도가 바뀌는 특별한 경우
    if (startMonth == 12 && endMonth == 1) {
      return (month == 12 && day >= startDay) || (month == 1 && day <= endDay);
    }

    // 일반적인 경우
    if (startMonth == endMonth) {
      // 같은 월 내에서의 기간
      return month == startMonth && day >= startDay && day <= endDay;
    } else {
      // 월이 바뀌는 기간
      return (month == startMonth && day >= startDay) || 
             (month == endMonth && day <= endDay);
    }
  }

  /// 별자리 이름을 영어로 변환합니다.
  static String getZodiacEnglishName(String koreanName) {
    const Map<String, String> englishNames = {
      '양자리': 'Aries',
      '황소자리': 'Taurus',
      '쌍둥이자리': 'Gemini',
      '게자리': 'Cancer',
      '사자자리': 'Leo',
      '처녀자리': 'Virgo',
      '천칭자리': 'Libra',
      '전갈자리': 'Scorpio',
      '사수자리': 'Sagittarius',
      '염소자리': 'Capricorn',
      '물병자리': 'Aquarius',
      '물고기자리': 'Pisces',
    };
    
    return englishNames[koreanName] ?? koreanName;
  }

  /// 별자리 기간을 문자열로 반환합니다.
  static String getZodiacPeriod(String zodiacName) {
    final dates = zodiacDates[zodiacName];
    if (dates == null) return '';
    
    final startMonth = dates[0];
    final startDay = dates[1];
    final endMonth = dates[2];
    final endDay = dates[3];
    
    return '$startMonth월 $startDay일 ~ $endMonth월 $endDay일';
  }

  /// 별자리 이미지 경로를 반환합니다.
  static String getZodiacImagePath(String zodiacName) {
    const Map<String, String> imagePaths = {
      '양자리': 'assets/design/zodiac_aries.svg',
      '황소자리': 'assets/design/zodiac_taurus.svg',
      '쌍둥이자리': 'assets/design/zodiac_gemini.svg',
      '게자리': 'assets/design/zodiac_cancer.svg',
      '사자자리': 'assets/design/zodiac_leo.svg',
      '처녀자리': 'assets/design/zodiac_virgo.svg',
      '천칭자리': 'assets/design/zodiac_libra.svg',
      '전갈자리': 'assets/design/zodiac_scorpio.svg',
      '사수자리': 'assets/design/zodiac_sagittarius.svg',
      '염소자리': 'assets/design/zodiac_capricorn.svg',
      '물병자리': 'assets/design/zodiac_aquarius.svg',
      '물고기자리': 'assets/design/zodiac_pisces.svg',
    };
    
    return imagePaths[zodiacName] ?? 'assets/design/zodiac_aries.svg';
  }
}

class SajuInfo {
  final String name;
  final DateTime birthDate;
  final int birthHour;
  final int birthMinute;
  final String gender;
  final String region;
  final String? loveStatus;
  final String? zodiacSign;
  final DateTime createdAt;

  SajuInfo({
    required this.name,
    required this.birthDate,
    required this.birthHour,
    required this.birthMinute,
    required this.gender,
    required this.region,
    this.loveStatus,
    this.zodiacSign,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 텍스트 형태의 날짜/시간 getter들
  String get yearText => '${birthDate.year}년';
  String get monthText => '${birthDate.month}월';
  String get dayText => '${birthDate.day}일';
  String get timeText => '${birthHour.toString().padLeft(2, '0')}:${birthMinute.toString().padLeft(2, '0')}';

  // 현재 날짜 형식 getter들
  String get currentTodayDate => '${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}';
  String get currentMonthDate => '${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}';
  String get currentYearDate => '${DateTime.now().year}';

  // 서버 요청에 사용되는 사용자 출생정보의 지문값
  // 시간(birthHour/minute)은 비교에서 제외하여 시간만 바뀌면 서버 재호출하지 않음
  String get currentRequestFingerprint => [
    birthDate.toIso8601String(),
    gender,
    region,
    loveStatus ?? ''
  ].join('|');

  // 날짜 비교 메서드들
  bool get isTodayFortuneExpired {
    final lastDate = todayFortune['lastFortuneDate'] ?? '';
    final lastFp = todayFortune['lastRequestFingerprint'] ?? '';
    return lastDate != currentTodayDate || lastFp != currentRequestFingerprint;
  }

  // 언어 포함 만료 체크 (가이드)
  bool isTodayFortuneExpiredFor(String languageCode) {
    final lastDate = todayFortune['lastFortuneDate'] ?? '';
    final lastFp = todayFortune['lastRequestFingerprint'] ?? '';
    final lastLang = todayFortune['lastLanguage'] ?? '';
    return lastDate != currentTodayDate || lastFp != currentRequestFingerprint || lastLang != languageCode;
  }

  // 에피소드/시 낭독 날짜 비교
  bool get isEpisodeExpired {
    final lastDate = episode['lastEpisodeDate'] ?? '';
    final lastFp = episode['lastRequestFingerprint'] ?? '';
    return lastDate != currentTodayDate || lastFp != currentRequestFingerprint;
  }

  // 언어 포함 만료 체크 (에피소드)
  bool isEpisodeExpiredFor(String languageCode) {
    final lastDate = episode['lastEpisodeDate'] ?? '';
    final lastFp = episode['lastRequestFingerprint'] ?? '';
    final lastLang = episode['lastLanguage'] ?? '';
    return lastDate != currentTodayDate || lastFp != currentRequestFingerprint || lastLang != languageCode;
  }

  bool get isPoetryExpired {
    final lastDate = poetry['lastPoetryDate'] ?? '';
    final lastFp = poetry['lastRequestFingerprint'] ?? '';
    return lastDate != currentTodayDate || lastFp != currentRequestFingerprint;
  }

  // 언어 포함 만료 체크 (시 낭독)
  bool isPoetryExpiredFor(String languageCode) {
    final lastDate = poetry['lastPoetryDate'] ?? '';
    final lastFp = poetry['lastRequestFingerprint'] ?? '';
    final lastLang = poetry['lastLanguage'] ?? '';
    return lastDate != currentTodayDate || lastFp != currentRequestFingerprint || lastLang != languageCode;
  }

  bool get isMonthFortuneExpired {
    final lastDate = monthFortune['lastFortuneDate'] ?? '';
    return lastDate != currentMonthDate;
  }

  bool get isYearFortuneExpired {
    final lastDate = yearFortune['lastFortuneDate'] ?? '';
    return lastDate != currentYearDate;
  }

  // JSON 직렬화를 위한 메서드
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'birthHour': birthHour,
      'birthMinute': birthMinute,
      'gender': gender,
      'region': region,
      'loveStatus': loveStatus,
      'zodiacSign': zodiacSign,
      'createdAt': createdAt.toIso8601String(),
      'todayFortune': todayFortune,
      'monthFortune': monthFortune,
      'yearFortune': yearFortune,
      'episode': episode,
      'poetry': poetry,
    };
  }

  // JSON에서 객체 생성
  factory SajuInfo.fromJson(Map<String, dynamic> json) {
    final sajuInfo = SajuInfo(
      name: json['name'] ?? '',
      birthDate: DateTime.parse(json['birthDate']),
      birthHour: json['birthHour'],
      birthMinute: json['birthMinute'],
      gender: json['gender'],
      region: json['region'] ?? '',
      loveStatus: json['loveStatus'] ?? json['status'],
      zodiacSign: json['zodiacSign'],
      createdAt: DateTime.parse(json['createdAt']),
    );
    
    // 운세 데이터 로드
    if (json['todayFortune'] != null) {
      sajuInfo.todayFortune = Map<String, dynamic>.from(json['todayFortune']);
    }
    if (json['monthFortune'] != null) {
      sajuInfo.monthFortune = Map<String, dynamic>.from(json['monthFortune']);
    }
    if (json['yearFortune'] != null) {
      sajuInfo.yearFortune = Map<String, dynamic>.from(json['yearFortune']);
    }

    // 에피소드/시 낭독 데이터 로드
    if (json['episode'] != null) {
      sajuInfo.episode = Map<String, dynamic>.from(json['episode']);
    }
    if (json['poetry'] != null) {
      sajuInfo.poetry = Map<String, dynamic>.from(json['poetry']);
    }
    
    return sajuInfo;
  }

  // 오늘의 운세
  Map<String, dynamic> todayFortune = {
    'overall': '', // 전체운
    'love': '', // 애정운
    'health': '', // 건강운
    'study': '', // 학업운
    'wealth': '', // 재물운
    'business': '', // 사업운
    'advice': '', // 조언
    'luckyItem': '', // 행운의 아이템
    'overallScore': '',//오늘의 총운 점수
    'studyCore': '',//오늘의 학업/직장 점수
    'healthScore': '',//오늘의 건강운 점수  
    'loveScore': '',//오늘의 애정운 점수
    'wealthScore': '',//오늘의 재물운 점수
    'serverResponse': '', // 서버 결과값
    'lastFortuneDate': '', // 20250101 형식
    'lastRequestFingerprint': '', // 출생정보 변경 감지용
    'lastLanguage': '', // 요청 당시 언어
  };

  // 오늘의 에피소드 (서버 결과 캐시 및 날짜 비교용)
  Map<String, dynamic> episode = {
    'title': '',
    'content': '',
    'tomorrowSummary': '',
    'serverResponse': '',
    'lastEpisodeDate': '', // 20250101 형식
    'lastRequestFingerprint': '', // 출생정보 변경 감지용
    'lastLanguage': '', // 요청 당시 언어
  };
  // 이달의 운세
  Map<String, dynamic> monthFortune = {
    'overall': '', // 전체운
    'love': '', // 애정운
    'health': '', // 건강운
    'study': '', // 학업운
    'wealth': '', // 재물운
    'business': '', // 사업운
    'advice': '', // 조언
    'luckyItem': '', // 행운의 아이템
    'serverResponse': '', // 서버 결과값
    'lastFortuneDate': '', // 202501 형식
  };

  // 올해의 운세
  Map<String, dynamic> yearFortune = {
    'overall': '', // 전체운
    'love': '', // 애정운
    'health': '', // 건강운
    'study': '', // 학업운
    'wealth': '', // 재물운
    'business': '', // 사업운
    'advice': '', // 조언
    'luckyItem': '', // 행운의 아이템
    'serverResponse': '', // 서버 결과값
    'lastFortuneDate': '', // 2025 형식
  };

  // 오늘의 시 낭독 (서버 결과 캐시 및 날짜 비교용)
  Map<String, dynamic> poetry = {
    'title': '',
    'content': '',
    'serverResponse': '',
    'lastPoetryDate': '', // 20250101 형식
    'lastRequestFingerprint': '', // 출생정보 변경 감지용
    'lastLanguage': '', // 요청 당시 언어
  };
}

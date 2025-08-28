class SajuInfo {
  final String name;
  final DateTime birthDate;
  final int birthHour;
  final int birthMinute;
  final String gender;
  final String region;
  final String? status;
  final String? zodiacSign;
  final DateTime createdAt;

  SajuInfo({
    required this.name,
    required this.birthDate,
    required this.birthHour,
    required this.birthMinute,
    required this.gender,
    required this.region,
    this.status,
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

  // 날짜 비교 메서드들
  bool get isTodayFortuneExpired {
    final lastDate = todayFortune['lastFortuneDate'] ?? '';
    return lastDate != currentTodayDate;
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
      'status': status,
      'zodiacSign': zodiacSign,
      'createdAt': createdAt.toIso8601String(),
      'todayFortune': todayFortune,
      'monthFortune': monthFortune,
      'yearFortune': yearFortune,
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
      status: json['status'],
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
}

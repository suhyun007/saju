class SajuInfo {
  final String name;
  final DateTime birthDate;
  final int birthHour;
  final int birthMinute;
  final String gender;
  final String region;
  final String? tone;
  final String? zodiacSign;
  final DateTime createdAt;
  final String? world;     // Character's World (country)
  final String? era;       // Character's Era (not persisted)
  final String? ageGroup;  // Character Age group
  final String? growthTheme;  // 성장 테마 (영어 키값)
  final String? loveRelation; // 사랑/관계 (영어 키값)
  final String? worldAction;  // 세상/행동 (영어 키값)

  SajuInfo({
    required this.name,
    required this.birthDate,
    required this.birthHour,
    required this.birthMinute,
    required this.gender,
    required this.region,
    this.tone,
    this.zodiacSign,
    this.world,
    this.era,
    this.ageGroup,
    this.growthTheme,
    this.loveRelation,
    this.worldAction,
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

  // 서버 요청에 사용되는 사용자 출생정보의 지문값 (이름/성별 제외)
  // 시간(birthHour/minute)은 비교에서 제외하여 시간만 바뀌면 서버 재호출하지 않음
  String get currentRequestFingerprint => [
    tone ?? '',
    world ?? '',
    ageGroup ?? '',
    growthTheme ?? '',
    loveRelation ?? '',
    worldAction ?? '',
  ].join('|');

  // 날짜 비교 메서드들
  bool get isTodayFortuneExpired {
    final lastDate = guide['lastFortuneDate'] ?? '';
    final lastFp = guide['lastRequestFingerprint'] ?? '';
    return lastDate != currentTodayDate || lastFp != currentRequestFingerprint;
  }

  // 언어 포함 만료 체크 (가이드)
  bool isTodayFortuneExpiredFor(String languageCode) {
    final lastDate = guide['lastFortuneDate'] ?? '';
    final lastFp = guide['lastRequestFingerprint'] ?? '';
    final lastLang = guide['lastLanguage'] ?? '';
    // 조합 지문과 비교: tone|world|ageGroup|growthTheme|loveRelation|worldAction|servedDate
    final todayYmd = currentTodayDate;
    final expectedComposite = [currentRequestFingerprint, lastDate].join('|');
    return lastDate != todayYmd || lastFp != expectedComposite || lastLang != languageCode;
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
    // 조합 지문과 비교: tone|world|ageGroup|growthTheme|loveRelation|worldAction|servedDate
    final todayYmd = currentTodayDate;
    final expectedComposite = [currentRequestFingerprint, todayYmd].join('|');
    return lastDate != todayYmd || lastFp != expectedComposite || lastLang != languageCode;
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
    // 조합 지문과 비교: tone|world|ageGroup|growthTheme|loveRelation|worldAction|servedDate
    final todayYmd = currentTodayDate;
    final expectedComposite = [currentRequestFingerprint, todayYmd].join('|');
    return lastDate != todayYmd || lastFp != expectedComposite || lastLang != languageCode;
  }

  // JSON 직렬화를 위한 메서드
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      // region removed from persisted payload
      'tone': tone,
      'world': world,
      // 'era': era, // no longer persisted
      'ageGroup': ageGroup,
      'growthTheme': growthTheme,
      'loveRelation': loveRelation,
      'worldAction': worldAction,
      'createdAt': createdAt.toIso8601String(),
      'guide': guide,
      'episode': episode,
      'poetry': poetry,
    };
  }

  // JSON에서 객체 생성
  factory SajuInfo.fromJson(Map<String, dynamic> json) {
    final sajuInfo = SajuInfo(
      name: json['name'] ?? '',
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : DateTime(1970,1,1),
      birthHour: json['birthHour'] ?? 12,
      birthMinute: json['birthMinute'] ?? 0,
      gender: json['gender'] ?? '',
      region: '',
      tone: json['tone'] ?? json['status'],
      zodiacSign: json['zodiacSign'],
      world: json['world'],
      era: json['era'],
      ageGroup: json['ageGroup'],
      growthTheme: json['growthTheme'],
      loveRelation: json['loveRelation'],
      worldAction: json['worldAction'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
    
    // 가이드 데이터 로드
    if (json['guide'] != null) {
      sajuInfo.guide = Map<String, dynamic>.from(json['guide']);
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
  Map<String, dynamic> guide = {
    'overall': '', // 전체운
    'love': '', // 애정운
    'health': '', // 건강운
    'study': '', // 학업운
    'wealth': '', // 재물운
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

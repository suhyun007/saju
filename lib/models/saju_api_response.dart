class SajuApiResponse {
  final bool success;
  final String? message;
  final SajuData? data;
  final String? error;

  SajuApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory SajuApiResponse.fromJson(Map<String, dynamic> json) {
    return SajuApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      error: json['error'],
      data: json['data'] != null ? SajuData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'error': error,
      'data': data?.toJson(),
    };
  }
}

class SajuData {
  final String? saju;
  final SajuElements? elements;
  final TodayFortune? todayFortune;
  final MonthFortune? monthFortune;
  final YearFortune? yearFortune;
  
  // 기존 호환성을 위한 필드들
  final String? yearSaju;
  final String? monthSaju;
  final String? daySaju;
  final String? hourSaju;
  final String? yearText;
  final String? monthText;
  final String? dayText;
  final String? hourText;
  final String? analysis;
  final String? fortune;

  SajuData({
    this.saju,
    this.elements,
    this.todayFortune,
    this.monthFortune,
    this.yearFortune,
    this.yearSaju,
    this.monthSaju,
    this.daySaju,
    this.hourSaju,
    this.yearText,
    this.monthText,
    this.dayText,
    this.hourText,
    this.analysis,
    this.fortune,
  });

  factory SajuData.fromJson(Map<String, dynamic> json) {
    return SajuData(
      saju: json['saju'],
      elements: json['elements'] != null ? SajuElements.fromJson(json['elements']) : null,
      todayFortune: json['today_fortune'] != null ? TodayFortune.fromJson(json['today_fortune']) : null,
      monthFortune: json['month_fortune'] != null ? MonthFortune.fromJson(json['month_fortune']) : null,
      yearFortune: json['year_fortune'] != null ? YearFortune.fromJson(json['year_fortune']) : null,
      // 기존 호환성을 위한 매핑
      yearSaju: json['elements']?['year'] ?? json['yearSaju'],
      monthSaju: json['elements']?['month'] ?? json['monthSaju'],
      daySaju: json['elements']?['day'] ?? json['daySaju'],
      hourSaju: json['elements']?['hour'] ?? json['hourSaju'],
      yearText: json['yearText'],
      monthText: json['monthText'],
      dayText: json['dayText'],
      hourText: json['hourText'],
      analysis: json['today_fortune']?['overall'] ?? json['analysis'],
      fortune: json['today_fortune']?['advice'] ?? json['fortune'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saju': saju,
      'elements': elements?.toJson(),
      'today_fortune': todayFortune?.toJson(),
      'month_fortune': monthFortune?.toJson(),
      'year_fortune': yearFortune?.toJson(),
      'yearSaju': yearSaju,
      'monthSaju': monthSaju,
      'daySaju': daySaju,
      'hourSaju': hourSaju,
      'yearText': yearText,
      'monthText': monthText,
      'dayText': dayText,
      'hourText': hourText,
      'analysis': analysis,
      'fortune': fortune,
    };
  }
}

class SajuElements {
  final String? year;
  final String? month;
  final String? day;
  final String? hour;

  SajuElements({
    this.year,
    this.month,
    this.day,
    this.hour,
  });

  factory SajuElements.fromJson(Map<String, dynamic> json) {
    return SajuElements(
      year: json['year'],
      month: json['month'],
      day: json['day'],
      hour: json['hour'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
    };
  }
}

class TodayFortune {
  final String? overall;
  final String? wealth;
  final String? health;
  final String? love;
  final String? advice;
  final String? study;
  final String? luckyItem;
  final String? todayOutfit;
  final int? overallScore;
  final int? studyCore;
  final int? healthScore;
  final int? loveScore;
  final int? wealthScore;

  TodayFortune({
    this.overall,
    this.wealth,
    this.health,
    this.love,
    this.advice,
    this.study,
    this.luckyItem,
    this.todayOutfit,
    this.overallScore,
    this.studyCore,
    this.healthScore,
    this.loveScore,
    this.wealthScore,
  });

  factory TodayFortune.fromJson(Map<String, dynamic> json) {
    return TodayFortune(
      overall: json['overall'],
      wealth: json['wealth'],
      health: json['health'],
      love: json['love'],
      advice: json['advice'],
      study: json['study'],
      luckyItem: json['luckyItem'],
      todayOutfit: json['todayOutfit'],
      overallScore: json['overallScore'],
      studyCore: json['studyCore'],
      healthScore: json['healthScore'],
      loveScore: json['loveScore'],
      wealthScore: json['wealthScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'wealth': wealth,
      'health': health,
      'love': love,
      'advice': advice,
      'study': study,
      'luckyItem': luckyItem,
      'todayOutfit': todayOutfit,
      'overallScore': overallScore,
      'studyCore': studyCore,
      'healthScore': healthScore,
      'loveScore': loveScore,
      'wealthScore': wealthScore,
    };
  }
}

class MonthFortune {
  final String? overall;
  final String? wealth;
  final String? health;
  final String? love;
  final String? advice;
  final String? study;
  final String? luckyItem;
  final String? monthOutfit;

  MonthFortune({
    this.overall,
    this.wealth,
    this.health,
    this.love,
    this.advice,
    this.study,
    this.luckyItem,
    this.monthOutfit,
  });

  factory MonthFortune.fromJson(Map<String, dynamic> json) {
    return MonthFortune(
      overall: json['overall'],
      wealth: json['wealth'],
      health: json['health'],
      love: json['love'],
      advice: json['advice'],
      study: json['study'],
      luckyItem: json['luckyItem'],
      monthOutfit: json['monthOutfit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'wealth': wealth,
      'health': health,
      'love': love,
      'advice': advice,
      'study': study,
      'luckyItem': luckyItem,
      'monthOutfit': monthOutfit,
    };
  }
}

class YearFortune {
  final String? overall;
  final String? wealth;
  final String? health;
  final String? love;
  final String? advice;
  final String? study;
  final String? luckyItem;
  final String? yearOutfit;

  YearFortune({
    this.overall,
    this.wealth,
    this.health,
    this.love,
    this.advice,
    this.study,
    this.luckyItem,
    this.yearOutfit,
  });

  factory YearFortune.fromJson(Map<String, dynamic> json) {
    return YearFortune(
      overall: json['overall'],
      wealth: json['wealth'],
      health: json['health'],
      love: json['love'],
      advice: json['advice'],
      study: json['study'],
      luckyItem: json['luckyItem'],
      yearOutfit: json['yearOutfit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'wealth': wealth,
      'health': health,
      'love': love,
      'advice': advice,
      'study': study,
      'luckyItem': luckyItem,
      'yearOutfit': yearOutfit,
    };
  }
}

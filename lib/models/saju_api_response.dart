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
}

class SajuData {
  final String? saju;
  final SajuElements? elements;
  final TodayFortune? todayFortune;
  
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
}

class TodayFortune {
  final String? overall;
  final String? wealth;
  final String? health;
  final String? love;
  final String? advice;

  TodayFortune({
    this.overall,
    this.wealth,
    this.health,
    this.love,
    this.advice,
  });

  factory TodayFortune.fromJson(Map<String, dynamic> json) {
    return TodayFortune(
      overall: json['overall'],
      wealth: json['wealth'],
      health: json['health'],
      love: json['love'],
      advice: json['advice'],
    );
  }
}

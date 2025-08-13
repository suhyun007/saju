class SajuApiResponse {
  final bool success;
  final String? message;
  final SajuData? data;

  SajuApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory SajuApiResponse.fromJson(Map<String, dynamic> json) {
    return SajuApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? SajuData.fromJson(json['data']) : null,
    );
  }
}

class SajuData {
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
      yearSaju: json['yearSaju'],
      monthSaju: json['monthSaju'],
      daySaju: json['daySaju'],
      hourSaju: json['hourSaju'],
      yearText: json['yearText'],
      monthText: json['monthText'],
      dayText: json['dayText'],
      hourText: json['hourText'],
      analysis: json['analysis'],
      fortune: json['fortune'],
    );
  }
}

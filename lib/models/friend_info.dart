class FriendInfo {
  final String name;
  final DateTime birthDate;
  final int birthHour;
  final int birthMinute;
  final String gender;
  final String region;
  final String? status;
  final String? zodiacSign;
  final DateTime createdAt;

  FriendInfo({
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
    };
  }

  // JSON에서 객체 생성
  factory FriendInfo.fromJson(Map<String, dynamic> json) {
    return FriendInfo(
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
  }

  // 사주 계산을 위한 간단한 메서드들
  String get yearText => '${birthDate.year}년';
  String get monthText => '${birthDate.month}월';
  String get dayText => '${birthDate.day}일';
  String get timeText => '${birthHour.toString().padLeft(2, '0')}:${birthMinute.toString().padLeft(2, '0')}';
  
  // 간단한 출생 정보 (실제로는 더 복잡한 계산이 필요)
  String get yearSaju => _calculateSaju(birthDate.year);
  String get monthSaju => _calculateSaju(birthDate.month);
  String get daySaju => _calculateSaju(birthDate.day);
  String get hourSaju => _calculateSaju(birthHour);

  // 간단한 사주 계산 (실제로는 음력 변환과 천간지지 계산이 필요)
  String _calculateSaju(int value) {
    final sajuList = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'];
    return sajuList[value % 10];
  }
}

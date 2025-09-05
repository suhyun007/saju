import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saju_info.dart';

class SajuService {
  static const String _sajuKey = 'saju_info';

  static const Set<String> _allowedGenders = {'female','male','nonBinary'};
  static const Set<String> _allowedLove = {'married','inRelationship','wantRelationship','noInterest'};

  static String _normalizeGender(String gender) {
    switch (gender) {
      case 'female':
      case 'male':
      case 'nonBinary':
        return gender;
      case '여성':
      case '女':
      case '女性':
        return 'female';
      case '남성':
      case '男':
      case '男性':
        return 'male';
      case '논바이너리':
      case 'ノンバイナリー':
      case '非二元':
        return 'nonBinary';
      default:
        return 'female';
    }
  }

  static String? _normalizeLoveStatus(String? status) {
    if (status == null) return null;
    switch (status) {
      case 'married':
      case 'inRelationship':
      case 'wantRelationship':
      case 'noInterest':
        return status;
      // English UI variants
      case 'Married':
        return 'married';
      case 'In a Relationship':
        return 'inRelationship';
      case 'Want a Relationship':
        return 'wantRelationship';
      case 'No Interest':
        return 'noInterest';
      // Korean
      case '결혼':
        return 'married';
      case '연애중':
        return 'inRelationship';
      case '연애하고 싶음':
      case '연애하고싶음':
        return 'wantRelationship';
      case '관심없음':
        return 'noInterest';
      // Japanese
      case '既婚':
        return 'married';
      case '恋愛中':
        return 'inRelationship';
      case '恋愛希望':
        return 'wantRelationship';
      case '興味なし':
        return 'noInterest';
      // Chinese
      case '已婚':
        return 'married';
      case '恋爱中':
      case '戀愛中':
        return 'inRelationship';
      case '希望恋爱':
      case '希望戀愛':
        return 'wantRelationship';
      case '不感兴趣':
      case '不感興趣':
      case '沒有興趣':
        return 'noInterest';
      default:
        return status;
    }
  }

  // 출생 정보 저장
  static Future<bool> saveSajuInfo(SajuInfo sajuInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonMap = sajuInfo.toJson();
      jsonMap['gender'] = _normalizeGender(jsonMap['gender'] as String);
      jsonMap['loveStatus'] = _normalizeLoveStatus(jsonMap['loveStatus'] as String?);
      final jsonString = jsonEncode(jsonMap);
      return await prefs.setString(_sajuKey, jsonString);
    } catch (e) {
      print('출생 정보 저장 실패: $e');
      return false;
    }
  }

  // 출생 정보 불러오기
  static Future<SajuInfo?> loadSajuInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_sajuKey);
      
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        // normalize on load if legacy values exist
        if (json['gender'] != null && !_allowedGenders.contains(json['gender'])) {
          json['gender'] = _normalizeGender(json['gender']);
        }
        if (json['loveStatus'] != null && !_allowedLove.contains(json['loveStatus'])) {
          json['loveStatus'] = _normalizeLoveStatus(json['loveStatus']);
        }
        final info = SajuInfo.fromJson(json);
        // write-back once if normalized
        await saveSajuInfo(info);
        return info;
      }
      return null;
    } catch (e) {
      print('출생 정보 불러오기 실패: $e');
      return null;
    }
  }

  // 출생 정보 삭제
  static Future<bool> deleteSajuInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_sajuKey);
    } catch (e) {
      print('출생 정보 삭제 실패: $e');
      return false;
    }
  }

  // 출생 정보 존재 여부 확인
  static Future<bool> hasSajuInfo() async {
    final sajuInfo = await loadSajuInfo();
    return sajuInfo != null;
  }

  // 오늘의 운세 데이터 업데이트
  static Future<bool> updateTodayFortune(Map<String, dynamic> fortuneData) async {
    try {
      final sajuInfo = await loadSajuInfo();
      if (sajuInfo == null) return false;
      
      sajuInfo.todayFortune.addAll(fortuneData);
      sajuInfo.todayFortune['lastFortuneDate'] = sajuInfo.currentTodayDate;
      
      return await saveSajuInfo(sajuInfo);
    } catch (e) {
      print('오늘의 운세 업데이트 실패: $e');
      return false;
    }
  }

  // 이달의 운세 데이터 업데이트
  static Future<bool> updateMonthFortune(Map<String, dynamic> fortuneData) async {
    try {
      final sajuInfo = await loadSajuInfo();
      if (sajuInfo == null) return false;
      
      sajuInfo.monthFortune.addAll(fortuneData);
      sajuInfo.monthFortune['lastFortuneDate'] = sajuInfo.currentMonthDate;
      
      return await saveSajuInfo(sajuInfo);
    } catch (e) {
      print('이달의 운세 업데이트 실패: $e');
      return false;
    }
  }

  // 올해의 운세 데이터 업데이트
  static Future<bool> updateYearFortune(Map<String, dynamic> fortuneData) async {
    try {
      final sajuInfo = await loadSajuInfo();
      if (sajuInfo == null) return false;
      
      sajuInfo.yearFortune.addAll(fortuneData);
      sajuInfo.yearFortune['lastFortuneDate'] = sajuInfo.currentYearDate;
      
      return await saveSajuInfo(sajuInfo);
    } catch (e) {
      print('올해의 운세 업데이트 실패: $e');
      return false;
    }
  }
}

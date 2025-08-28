import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saju_info.dart';

class SajuService {
  static const String _sajuKey = 'saju_info';

  // 출생 정보 저장
  static Future<bool> saveSajuInfo(SajuInfo sajuInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(sajuInfo.toJson());
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
        return SajuInfo.fromJson(json);
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

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saju_info.dart';

class SajuService {
  static const String _sajuKey = 'saju_info';

  // 사주 정보 저장
  static Future<bool> saveSajuInfo(SajuInfo sajuInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(sajuInfo.toJson());
      return await prefs.setString(_sajuKey, jsonString);
    } catch (e) {
      print('사주 정보 저장 실패: $e');
      return false;
    }
  }

  // 사주 정보 불러오기
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
      print('사주 정보 불러오기 실패: $e');
      return null;
    }
  }

  // 사주 정보 삭제
  static Future<bool> deleteSajuInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_sajuKey);
    } catch (e) {
      print('사주 정보 삭제 실패: $e');
      return false;
    }
  }

  // 사주 정보 존재 여부 확인
  static Future<bool> hasSajuInfo() async {
    final sajuInfo = await loadSajuInfo();
    return sajuInfo != null;
  }
}

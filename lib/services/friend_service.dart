import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend_info.dart';

class FriendService {
  static const String _friendInfoKey = 'friend_info';

  // 친구 정보 저장
  static Future<bool> saveFriendInfo(FriendInfo friendInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(friendInfo.toJson());
      return await prefs.setString(_friendInfoKey, jsonString);
    } catch (e) {
      print('친구 정보 저장 실패: $e');
      return false;
    }
  }

  // 친구 정보 로드
  static Future<FriendInfo?> loadFriendInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_friendInfoKey);
      
      if (jsonString == null) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FriendInfo.fromJson(json);
    } catch (e) {
      print('친구 정보 로드 실패: $e');
      return null;
    }
  }

  // 친구 정보 삭제
  static Future<bool> deleteFriendInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_friendInfoKey);
    } catch (e) {
      print('친구 정보 삭제 실패: $e');
      return false;
    }
  }

  // 친구 정보가 있는지 확인
  static Future<bool> hasFriendInfo() async {
    final friendInfo = await loadFriendInfo();
    return friendInfo != null;
  }
}

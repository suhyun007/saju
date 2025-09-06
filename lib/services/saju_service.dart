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
      
      // 기존 정보와 비교하여 시간 정보만 변경된 경우 캐시 유지
      final existingJsonString = prefs.getString(_sajuKey);
      if (existingJsonString != null) {
        final existingJson = jsonDecode(existingJsonString) as Map<String, dynamic>;
        final existingSajuInfo = SajuInfo.fromJson(existingJson);
        
        // 완전히 동일한 경우 저장하지 않음
        if (existingSajuInfo.birthDate == sajuInfo.birthDate &&
            existingSajuInfo.birthHour == sajuInfo.birthHour &&
            existingSajuInfo.birthMinute == sajuInfo.birthMinute &&
            existingSajuInfo.gender == sajuInfo.gender &&
            existingSajuInfo.region == sajuInfo.region &&
            existingSajuInfo.loveStatus == sajuInfo.loveStatus) {
          print('출생정보 변경 없음 - 저장하지 않음');
          return true; // 성공으로 처리
        }
        
        // fingerprint 비교 (시간 정보 제외)
        if (existingSajuInfo.currentRequestFingerprint == sajuInfo.currentRequestFingerprint) {
          // 시간 정보만 변경된 경우 - 기존 캐시 데이터 유지
          print('시간 정보만 변경됨 - 기존 캐시 데이터 유지');
          final jsonMap = sajuInfo.toJson();
          jsonMap['gender'] = _normalizeGender(jsonMap['gender'] as String);
          jsonMap['loveStatus'] = _normalizeLoveStatus(jsonMap['loveStatus'] as String?);
          
          // 기존 캐시 데이터 복사
          jsonMap['episode'] = existingJson['episode'] ?? {};
          jsonMap['poetry'] = existingJson['poetry'] ?? {};
          jsonMap['guide'] = existingJson['guide'] ?? {};
          
          final jsonString = jsonEncode(jsonMap);
          return await prefs.setString(_sajuKey, jsonString);
        }
      }
      
      // 다른 정보가 변경된 경우 - 정상 저장
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

  // 콘텐츠/캐시 저장용: 현재 sajuInfo 상태를 그대로 저장 (캐시 보존 로직 우회)
  static Future<bool> saveSajuInfoContent(SajuInfo sajuInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonMap = sajuInfo.toJson();
      jsonMap['gender'] = _normalizeGender(jsonMap['gender'] as String);
      jsonMap['loveStatus'] = _normalizeLoveStatus(jsonMap['loveStatus'] as String?);
      final jsonString = jsonEncode(jsonMap);
      return await prefs.setString(_sajuKey, jsonString);
    } catch (e) {
      print('출생 정보/콘텐츠 저장 실패(saveSajuInfoContent): $e');
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
        bool needsSave = false;
        
        // normalize on load if legacy values exist
        if (json['gender'] != null && !_allowedGenders.contains(json['gender'])) {
          json['gender'] = _normalizeGender(json['gender']);
          needsSave = true;
        }
        if (json['loveStatus'] != null && !_allowedLove.contains(json['loveStatus'])) {
          json['loveStatus'] = _normalizeLoveStatus(json['loveStatus']);
          needsSave = true;
        }
        
        final info = SajuInfo.fromJson(json);

        // Migrate legacy fingerprints to YYYYMMDD|gender|loveStatus|servedDate format
        try {
          final birthYmd = '${info.birthDate.year.toString().padLeft(4, '0')}'
              '${info.birthDate.month.toString().padLeft(2, '0')}'
              '${info.birthDate.day.toString().padLeft(2, '0')}';

          // Episode
          final epDate = (info.episode['lastEpisodeDate'] ?? '').toString();
          if (epDate.isNotEmpty) {
            final expectedEpFp = '$birthYmd|${info.gender}|${info.loveStatus ?? ''}|$epDate';
            final currentEpFp = (info.episode['lastRequestFingerprint'] ?? '').toString();
            if (currentEpFp != expectedEpFp) {
              info.episode['lastRequestFingerprint'] = expectedEpFp;
              needsSave = true;
            }
          }

          // Poetry
          final pyDate = (info.poetry['lastPoetryDate'] ?? '').toString();
          if (pyDate.isNotEmpty) {
            final expectedPyFp = '$birthYmd|${info.gender}|${info.loveStatus ?? ''}|$pyDate';
            final currentPyFp = (info.poetry['lastRequestFingerprint'] ?? '').toString();
            if (currentPyFp != expectedPyFp) {
              info.poetry['lastRequestFingerprint'] = expectedPyFp;
              needsSave = true;
            }
          }

          // Guide
          final gdDate = (info.guide['lastFortuneDate'] ?? '').toString();
          if (gdDate.isNotEmpty) {
            final expectedGdFp = '$birthYmd|${info.gender}|${info.loveStatus ?? ''}|$gdDate';
            final currentGdFp = (info.guide['lastRequestFingerprint'] ?? '').toString();
            if (currentGdFp != expectedGdFp) {
              info.guide['lastRequestFingerprint'] = expectedGdFp;
              needsSave = true;
            }
          }
        } catch (_) {}
        
        // 정규화가 필요한 경우에만 저장
        if (needsSave) {
          await saveSajuInfoContent(info);
        }
        
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
      
      sajuInfo.guide.addAll(fortuneData);
      sajuInfo.guide['lastFortuneDate'] = sajuInfo.currentTodayDate;
      
      return await saveSajuInfo(sajuInfo);
    } catch (e) {
      print('오늘의 운세 업데이트 실패: $e');
      return false;
    }
  }
}

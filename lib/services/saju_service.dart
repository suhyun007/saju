import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saju_info.dart';

class SajuService {
  static const String _sajuKey = 'saju_info';
  static const String _guestIdKey = 'guest_id';
  static const String _experienceKey = 'experience_mode';

  static const Set<String> _allowedGenders = {'female','male','nonBinary'};
  // Character Tone keys (new)
  static const Set<String> _allowedLove = {
    'warm','calm','lovely','urban','positive','funny','emotional','hopeful','passionate','futureOriented',
    // legacy values kept for compatibility
    'married','inRelationship','wantRelationship','noInterest'
  };

  // Age group keys (english-only)
  static const Set<String> _allowedAgeGroups = {
    'teens','20s','30s','40s','50s','60s','70s','80plus'
  };

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
        // 비어있거나 매칭되지 않으면 그대로 둔다 (기본값 강제 없음)
        return gender;
    }
  }

  static String? _normalizetone(String? status) {
    if (status == null) return null;
    switch (status) {
      // new keys
      case 'warm':
      case 'calm':
      case 'lovely':
      case 'urban':
      case 'positive':
      case 'funny':
      case 'emotional':
      case 'hopeful':
      case 'passionate':
      case 'futureOriented':
      // legacy
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
      // Korean (new)
      case '따뜻한':
        return 'warm';
      case '차분한':
        return 'calm';
      case '사랑스러운':
        return 'lovely';
      case '도시적인':
        return 'urban';
      case '긍정적인':
        return 'positive';
      case '재미있는':
        return 'funny';
      case '감성적인':
        return 'emotional';
      case '희망적인':
        return 'hopeful';
      case '열정적인':
        return 'passionate';
      case '미래지향적':
        return 'futureOriented';
      // Korean (legacy)
      case '결혼':
        return 'married';
      case '연애중':
        return 'inRelationship';
      case '연애하고 싶음':
      case '연애하고싶음':
        return 'wantRelationship';
      case '관심없음':
        return 'noInterest';
      // Japanese (new)
      case '暖かい':
        return 'warm';
      case '落ち着いた':
        return 'calm';
      case '愛らしい':
        return 'lovely';
      case '都会的':
        return 'urban';
      case 'ポジティブ':
        return 'positive';
      case '面白い':
        return 'funny';
      case '感性的':
        return 'emotional';
      case '希望に満ちた':
        return 'hopeful';
      case '情熱的':
        return 'passionate';
      case '未来志向':
        return 'futureOriented';
      // Japanese (legacy)
      case '既婚':
        return 'married';
      case '恋愛中':
        return 'inRelationship';
      case '恋愛希望':
        return 'wantRelationship';
      case '興味なし':
        return 'noInterest';
      // Chinese (new)
      case '温暖的':
        return 'warm';
      case '冷静的':
        return 'calm';
      case '可爱的':
        return 'lovely';
      case '都市感的':
        return 'urban';
      case '积极的':
        return 'positive';
      case '有趣的':
        return 'funny';
      case '充满希望的':
        return 'hopeful';
      case '热情的':
        return 'passionate';
      case '面向未来':
        return 'futureOriented';
      // Chinese (legacy)
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

  // Normalize age group to english key
  static String? _normalizeAgeGroup(String? v) {
    if (v == null) return null;
    switch (v.trim()) {
      // none
      case '선택 안함':
      case '選択しない':
      case '不选择':
      case 'None':
      case 'Prefer not to say':
        return null;
      // teens
      case '10대':
      case '10代':
      case 'Teens':
      case 'Teens (13–19)':
        return 'teens';
      // 20s
      case '20대':
      case '20代':
      case '20s':
        return '20s';
      // 30s
      case '30대':
      case '30代':
      case '30s':
        return '30s';
      // 40s
      case '40대':
      case '40代':
      case '40s':
        return '40s';
      // 50s
      case '50대':
      case '50代':
      case '50s':
        return '50s';
      // 60s
      case '60대':
      case '60代':
      case '60s':
        return '60s';
      // 70s
      case '70대':
      case '70代':
      case '70s':
        return '70s';
      // 80+
      case '80대 이상':
      case '80代以上':
      case '80岁以上':
      case '80+':
        return '80plus';
      default:
        // already english key?
        return _allowedAgeGroups.contains(v) ? v : v;
    }
  }

  // Normalize world (country) to English name where possible
  static String? _normalizeWorld(String? w) {
    if (w == null) return null;
    final t = w.trim();
    if (t.isEmpty) return null;
    // none keywords
    const noneLabels = {'선택 안함','選択しない','不选择','None'};
    if (noneLabels.contains(t)) return null;

    // Mapping from localized to English
    const Map<String, String> m = {
      // Korean → English
      '대한민국':'South Korea','미국':'United States','일본':'Japan','중국':'China','영국':'United Kingdom','캐나다':'Canada','독일':'Germany','프랑스':'France','인도':'India','호주':'Australia','스페인':'Spain','이탈리아':'Italy','러시아':'Russia','브라질':'Brazil','멕시코':'Mexico','터키':'Turkey','인도네시아':'Indonesia','필리핀':'Philippines','베트남':'Vietnam','태국':'Thailand','싱가포르':'Singapore','말레이시아':'Malaysia','대만':'Taiwan','홍콩':'Hong Kong','아랍에미리트':'United Arab Emirates','사우디아라비아':'Saudi Arabia','이집트':'Egypt','남아프리카공화국':'South Africa','아르헨티나':'Argentina','칠레':'Chile','네덜란드':'Netherlands','스웨덴':'Sweden','노르웨이':'Norway','덴마크':'Denmark','핀란드':'Finland','폴란드':'Poland','포르투갈':'Portugal','이스라엘':'Israel','스위스':'Switzerland','두바이':'Dubai (UAE)','뉴질랜드':'New Zealand','파키스탄':'Pakistan','방글라데시':'Bangladesh',
      // Japanese → English
      '韓国':'South Korea','アメリカ':'United States','日本':'Japan','中国':'China','イギリス':'United Kingdom','カナダ':'Canada','ドイツ':'Germany','フランス':'France','インド':'India','オーストラリア':'Australia','スペイン':'Spain','イタリア':'Italy','ロシア':'Russia','ブラジル':'Brazil','メキシコ':'Mexico','トルコ':'Turkey','インドネシア':'Indonesia','フィリピン':'Philippines','ベトナム':'Vietnam','タイ':'Thailand','シンガポール':'Singapore','マレーシア':'Malaysia','台湾':'Taiwan','香港':'Hong Kong','アラブ首長国連邦':'United Arab Emirates','サウジアラビア':'Saudi Arabia','エジプト':'Egypt','南アフリカ':'South Africa','アルゼンチン':'Argentina','チリ':'Chile','オランダ':'Netherlands','スウェーデン':'Sweden','ノルウェー':'Norway','デンマーク':'Denmark','フィンランド':'Finland','ポーランド':'Poland','ポルトガル':'Portugal','イスラエル':'Israel','スイス':'Switzerland','ドバイ':'Dubai (UAE)','ニュージーランド':'New Zealand','パキスタン':'Pakistan','バングラデシュ':'Bangladesh',
      // Chinese → English
      '韩国':'South Korea','美国':'United States','英国':'United Kingdom','加拿大':'Canada','德国':'Germany','法国':'France','印度':'India','澳大利亚':'Australia','西班牙':'Spain','意大利':'Italy','俄罗斯':'Russia','巴西':'Brazil','墨西哥':'Mexico','土耳其':'Turkey','印度尼西亚':'Indonesia','菲律宾':'Philippines','越南':'Vietnam','泰国':'Thailand','新加坡':'Singapore','马来西亚':'Malaysia','阿联酋':'United Arab Emirates','沙特阿拉伯':'Saudi Arabia','埃及':'Egypt','南非':'South Africa','阿根廷':'Argentina','智利':'Chile','荷兰':'Netherlands','瑞典':'Sweden','挪威':'Norway','丹麦':'Denmark','芬兰':'Finland','波兰':'Poland','葡萄牙':'Portugal','以色列':'Israel','瑞士':'Switzerland','迪拜':'Dubai (UAE)','新西兰':'New Zealand','巴基斯坦':'Pakistan','孟加拉国':'Bangladesh',
    };

    // If already english-looking, keep as is
    final ascii = RegExp(r'^[A-Za-z0-9 \-()]+$');
    if (ascii.hasMatch(t)) return t;
    return m[t] ?? t;
  }

  // 출생 정보 저장
  static Future<bool> saveSajuInfo(SajuInfo sajuInfo) async {  
    try {
      final prefs = await SharedPreferences.getInstance();
      // 체험 모드 해제: 실제 정보 저장 시
      await prefs.remove(_experienceKey);
      
      // 기존 정보와 비교하여 시간 정보만 변경된 경우 캐시 유지
      final existingJsonString = prefs.getString(_sajuKey);
      if (existingJsonString != null) {
        final existingJson = jsonDecode(existingJsonString) as Map<String, dynamic>;
        final existingSajuInfo = SajuInfo.fromJson(existingJson);
        
        // 완전히 동일한 경우 저장하지 않음
        if (existingSajuInfo.name == sajuInfo.name &&
            existingSajuInfo.gender == sajuInfo.gender &&
            existingSajuInfo.tone == sajuInfo.tone &&
            (existingSajuInfo.world ?? '') == (sajuInfo.world ?? '') &&
            (existingSajuInfo.ageGroup ?? '') == (sajuInfo.ageGroup ?? '')) {
          print('출생정보 변경 없음 - 저장하지 않음');
          return true; // 성공으로 처리
        }
        
        // fingerprint 비교 (시간 정보 제외)
        if (existingSajuInfo.currentRequestFingerprint == sajuInfo.currentRequestFingerprint) {
          // 시간 정보만 변경된 경우 - 기존 캐시 데이터 유지
          print('시간 정보만 변경됨 - 기존 캐시 데이터 유지');
          final jsonMap = sajuInfo.toJson();
          jsonMap['gender'] = _normalizeGender(jsonMap['gender'] as String);
          jsonMap['tone'] = _normalizetone(jsonMap['tone'] as String?);
          
          // 기존 캐시 데이터 복사 (fingerprint는 새로운 것으로 업데이트)
          final episodeCache = Map<String, dynamic>.from(existingJson['episode'] ?? {});
          final poetryCache = Map<String, dynamic>.from(existingJson['poetry'] ?? {});
          final guideCache = Map<String, dynamic>.from(existingJson['guide'] ?? {});
          
          // 새로운 fingerprint로 업데이트
          episodeCache['lastRequestFingerprint'] = sajuInfo.currentRequestFingerprint;
          poetryCache['lastRequestFingerprint'] = sajuInfo.currentRequestFingerprint;
          guideCache['lastRequestFingerprint'] = sajuInfo.currentRequestFingerprint;
          
          jsonMap['episode'] = episodeCache;
          jsonMap['poetry'] = poetryCache;
          jsonMap['guide'] = guideCache;
          
          final jsonString = jsonEncode(jsonMap);
          return await prefs.setString(_sajuKey, jsonString);
        }
      }
      
      // 다른 정보가 변경된 경우 - 정상 저장
      final jsonMap = sajuInfo.toJson();
      jsonMap['gender'] = _normalizeGender(jsonMap['gender'] as String);
      jsonMap['tone'] = _normalizetone(jsonMap['tone'] as String?);
      jsonMap['ageGroup'] = _normalizeAgeGroup(jsonMap['ageGroup'] as String?);
      jsonMap['world'] = _normalizeWorld(jsonMap['world'] as String?);
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
      jsonMap['tone'] = _normalizetone(jsonMap['tone'] as String?);
      jsonMap['ageGroup'] = _normalizeAgeGroup(jsonMap['ageGroup'] as String?);
      jsonMap['world'] = _normalizeWorld(jsonMap['world'] as String?);
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
        if (json['tone'] != null && !_allowedLove.contains(json['tone'])) {
          json['tone'] = _normalizetone(json['tone']);
          needsSave = true;
        }
        if (json['ageGroup'] != null && !_allowedAgeGroups.contains(json['ageGroup'])) {
          json['ageGroup'] = _normalizeAgeGroup(json['ageGroup']);
          needsSave = true;
        }
        if (json['world'] != null) {
          final w = _normalizeWorld(json['world']);
          if (w != json['world']) { json['world'] = w; needsSave = true; }
        }
        
        final info = SajuInfo.fromJson(json);

        // Migrate legacy fingerprints to new composite: tone|world|ageGroup|growthTheme|loveRelation|worldAction|YYYYMMDD
        try {
          // Episode
          final epDate = (info.episode['lastEpisodeDate'] ?? '').toString();
          if (epDate.isNotEmpty) {
            final expectedEpFp = [
              info.tone ?? '',
              info.world ?? '',
              info.ageGroup ?? '',
              info.growthTheme ?? '',
              info.loveRelation ?? '',
              info.worldAction ?? '',
              epDate,
            ].join('|');
            final currentEpFp = (info.episode['lastRequestFingerprint'] ?? '').toString();
            if (currentEpFp != expectedEpFp) {
              info.episode['lastRequestFingerprint'] = expectedEpFp;
              needsSave = true;
            }
          }

          // Poetry
          final pyDate = (info.poetry['lastPoetryDate'] ?? '').toString();
          if (pyDate.isNotEmpty) {
            final expectedPyFp = [
              info.tone ?? '',
              info.world ?? '',
              info.ageGroup ?? '',
              info.growthTheme ?? '',
              info.loveRelation ?? '',
              info.worldAction ?? '',
              pyDate,
            ].join('|');
            final currentPyFp = (info.poetry['lastRequestFingerprint'] ?? '').toString();
            if (currentPyFp != expectedPyFp) {
              info.poetry['lastRequestFingerprint'] = expectedPyFp;
              needsSave = true;
            }
          }

          // Guide
          final gdDate = (info.guide['lastFortuneDate'] ?? '').toString();
          if (gdDate.isNotEmpty) {
            final expectedGdFp = [
              info.tone ?? '',
              info.world ?? '',
              info.ageGroup ?? '',
              info.growthTheme ?? '',
              info.loveRelation ?? '',
              info.worldAction ?? '',
              gdDate,
            ].join('|');
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

  // Guest ID 관리
  static Future<String> getGuestId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? guestId = prefs.getString(_guestIdKey);
      if (guestId == null) {
        // 새로운 guest ID 생성
        guestId = DateTime.now().millisecondsSinceEpoch.toString();
        await prefs.setString(_guestIdKey, guestId);
      }
      return guestId;
    } catch (e) {
      print('Guest ID 조회 실패: $e');
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  static Future<void> clearGuestId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestIdKey);
    } catch (e) {
      print('Guest ID 삭제 실패: $e');
    }
  }

  // ===== 체험 모드 관리 =====
  static Future<void> enableExperienceMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_experienceKey, true);
  }

  static Future<void> disableExperienceMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_experienceKey);
  }

  static Future<bool> isExperienceMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_experienceKey) == true;
  }
}

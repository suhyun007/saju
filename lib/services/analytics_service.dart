import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'supabase_service.dart';

class AnalyticsService {
  static const String _visitLogKey = 'first_visit_logged';
  static const String _guestIdKey = 'guest_id';
  static const String _sessionIdKey = 'session_id';
  static const String _visitDateKey = 'last_visit_date'; // YYYYMMDD 기준 하루 1회 기록
  
  // 서버 베이스 URL
  static String get _baseUrl {
    if (kDebugMode) {
      // 개발 환경
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api';
      }
      return 'http://localhost:3000/api';
    }
    // 프로덕션 환경
    return 'https://saju-server-j9ti.vercel.app/api';
  }

  // 기존 방문 여부 확인 (guestId 기준)
  static Future<bool> isReturningUser() async {
    try {
      final guestId = await _getOrCreateGuestId();
      final uri = Uri.parse('$_baseUrl/analytics/visit?guestId=$guestId&existsOnly=1');
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('exists')) return data['exists'] == true;
        final dynamic list = data['data'];
        if (list is List) return list.isNotEmpty; // 하위호환
      } else {
        print('isReturningUser - GET failed: ${response.statusCode}');
      }
    } catch (e) {
      print('isReturningUser - error: $e');
    }
    // 실패 시 신규 사용자로 간주
    return false;
  }

  // 앱 첫 실행/스플래시 진입 시 방문 로그 기록 (하루 1회)
  static Future<void> logFirstVisit() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 오늘 날짜(로컬) YYYYMMDD
      final now = DateTime.now();
      final today = '${now.year.toString().padLeft(4,'0')}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}';

      // 디바이스 정보 수집
      final deviceInfo = await _getDeviceInfo();
      final guestId = await _getOrCreateGuestId();
      final sessionId = await _getOrCreateSessionId();
      final userId = SupabaseService.client.auth.currentUser?.id;
      final nation = _getCountryFromLocale();
      
      print('AnalyticsService - guestId: $guestId');
      print('AnalyticsService - sessionId: $sessionId');
      print('AnalyticsService - userId: $userId');
      print('AnalyticsService - nation: $nation');

      // 서버에 방문 로그 전송
      final success = await _sendVisitLog(
        guestId: guestId,
        deviceInfo: deviceInfo,
        sessionId: sessionId,
        userId: userId,
        nation: nation,
      );

      if (success) {
        // 성공 시 오늘 날짜 저장 (통계용, 제한 없음)
        await prefs.setString(_visitDateKey, today);
        await prefs.setBool(_visitLogKey, true); // 구키 유지(호환)
        print('방문 로그가 성공적으로 기록되었습니다. (매 진입 기록)');
      } else {
        print('방문 로그 기록에 실패했습니다.');
      }

    } catch (e) {
      print('방문 로그 기록 중 오류 발생: $e');
    }
  }

  // 디바이스 정보 수집
  static Future<String> _getDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final osName = Platform.operatingSystem;
      final osVersion = Platform.operatingSystemVersion;
      
      return '$osName $osVersion - App v${packageInfo.version}';
    } catch (e) {
      print('디바이스 정보 수집 오류: $e');
      return 'Unknown Device';
    }
  }

  // Guest ID 가져오기 또는 생성
  static Future<String> _getOrCreateGuestId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? guestId = prefs.getString(_guestIdKey);
      
      if (guestId == null) {
        // 새로운 Guest ID 생성
        guestId = const Uuid().v4();
        await prefs.setString(_guestIdKey, guestId);
      }
      
      return guestId;
    } catch (e) {
      print('Guest ID 생성 오류: $e');
      return const Uuid().v4();
    }
  }

  // Session ID 가져오기 또는 생성
  static Future<String> _getOrCreateSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString(_sessionIdKey);
      
      if (sessionId == null) {
        // 새로운 Session ID 생성
        sessionId = const Uuid().v4();
        await prefs.setString(_sessionIdKey, sessionId);
      }
      
      return sessionId;
    } catch (e) {
      print('Session ID 생성 오류: $e');
      return const Uuid().v4();
    }
  }

  // 나라 정보 가져오기 (Locale 기반)
  static String _getCountryFromLocale() {
    try {
      final locale = ui.PlatformDispatcher.instance.locale;
      print('AnalyticsService - Locale: ${locale.toString()}');
      print('AnalyticsService - Country Code: ${locale.countryCode}');
      print('AnalyticsService - Language Code: ${locale.languageCode}');
      
      final countryCode = locale.countryCode;
      if (countryCode != null && countryCode.isNotEmpty) {
        return countryCode;
      } else {
        print('AnalyticsService - Country code is null or empty, using language code');
        return locale.languageCode;
      }
    } catch (e) {
      print('나라 정보 가져오기 오류: $e');
      return 'Unknown';
    }
  }

  // 서버에 방문 로그 전송
  static Future<bool> _sendVisitLog({
    required String guestId,
    required String deviceInfo,
    String? sessionId,
    String? userId,
    required String nation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analytics/visit'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'guestId': guestId,
          'deviceInfo': deviceInfo,
          'sessionId': sessionId,
          'userId': userId,
          'nation': nation,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('방문 로그 응답: $data');
        return data['success'] == true;
      } else {
        print('방문 로그 전송 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('방문 로그 전송 오류: $e');
      return false;
    }
  }

  // 메뉴 클릭 로그 기록
  static Future<void> logMenuClick(String menuType, {String? sessionId, String? userId}) async {
    try {
      final guestId = await _getOrCreateGuestId();
      final currentSessionId = sessionId ?? await _getOrCreateSessionId();
      final currentUserId = userId ?? SupabaseService.client.auth.currentUser?.id;
      
      print('logMenuClick - guestId: $guestId');
      print('logMenuClick - sessionId: $currentSessionId');
      print('logMenuClick - userId: $currentUserId');
      print('logMenuClick - menuType: $menuType');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/analytics/menu-click'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'guestId': guestId,
          'userId': currentUserId,
          'sessionId': currentSessionId,
          'menuType': menuType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('메뉴 클릭 로그 응답: $data');
      } else {
        print('메뉴 클릭 로그 전송 실패: ${response.statusCode}');
        print('응답 내용: ${response.body}');
      }
    } catch (e) {
      print('메뉴 클릭 로그 전송 오류: $e');
    }
  }

  // 서버 API 호출 로그 기록
  static Future<void> logServerCall({
    required String menuType,
    String? inputText,
    String? outputText,
    required int statusCode,
    required int latencyMs,
    String? errorMsg,
  }) async {
    try {
      final guestId = await _getOrCreateGuestId();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/analytics/server-call'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'guestId': guestId,
          'menuType': menuType,
          'inputText': inputText,
          'outputText': outputText,
          'statusCode': statusCode,
          'latencyMs': latencyMs,
          'errorMsg': errorMsg,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('서버 호출 로그 응답: $data');
      } else {
        print('서버 호출 로그 전송 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('서버 호출 로그 전송 오류: $e');
    }
  }
}

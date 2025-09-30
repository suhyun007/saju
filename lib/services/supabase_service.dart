import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  // Supabase 초기화
  static Future<void> initialize() async {
    print('SupabaseService 초기화 시작...');
    
    try {
      // 로컬 서버 연결 테스트
      bool isLocalHost = await _checkLocalServer();
      
      if (isLocalHost) {
        print('SupabaseService: 로컬 환경 감지 - Supabase 초기화 건너뛰기');
        return;
      }
      
      // 서버에서 Supabase 설정 가져오기
      final config = await _getSupabaseConfig();
      
      await Supabase.initialize(
        url: config['supabase_url']!,
        anonKey: config['supabase_anon_key']!,
      );
      
      print('Supabase 초기화 완료');
      
      // 익명 로그인으로 user_id 생성
      print('익명 로그인 시도...');
      await _signInAnonymously();
      print('익명 로그인 시도 완료');
    } catch (e) {
      print('Supabase 초기화 실패: $e');
      // 로컬 환경에서는 에러를 던지지 않음
      if (!await _checkLocalServer()) {
        throw Exception('Supabase 초기화에 실패했습니다. 서버 설정을 확인해주세요.');
      }
    }
  }
  
  // 로컬 서버 연결 테스트
  static Future<bool> _checkLocalServer() async {
    try {
      final testResponse = await http.get(
        Uri.parse('http://localhost:3000/api/config/supabase'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 2));
      
      return testResponse.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // 서버에서 Supabase 설정 가져오기
  static Future<Map<String, String>> _getSupabaseConfig() async {
    final String baseUrl = 'https://saju-server-j9ti.vercel.app';
    
    print('SupabaseService: 사용 중인 URL: $baseUrl');
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/config/supabase'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'supabase_url': data['supabase_url'],
        'supabase_anon_key': data['supabase_anon_key'],
      };
    } else {
      throw Exception('서버에서 설정을 가져올 수 없습니다: ${response.statusCode}');
    }
  }

  // 익명 로그인
  static Future<void> _signInAnonymously() async {
    try {
      final response = await client.auth.signInAnonymously();
      if (response.user != null) {
        print('익명 로그인 성공: ${response.user!.id}');
      } else {
        print('익명 로그인 실패: 사용자 정보 없음');
      }
    } catch (e) {
      print('익명 로그인 실패: $e');
      // 익명 로그인 실패해도 앱은 계속 작동
    }
  }
  
  // 사용자 인증 관련
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  static User? get currentUser => client.auth.currentUser;
  
  // 데이터베이스 작업
  static Future<List<Map<String, dynamic>>> getData({
    required String table,
    String? select,
    Map<String, dynamic>? filters,
  }) async {
    var query = client.from(table).select(select ?? '*');
    
    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }
    
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }
  
  static Future<Map<String, dynamic>?> insertData({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final response = await client.from(table).insert(data).select().single();
    return response;
  }
  
  static Future<Map<String, dynamic>?> updateData({
    required String table,
    required Map<String, dynamic> data,
    required String column,
    required dynamic value,
  }) async {
    final response = await client
        .from(table)
        .update(data)
        .eq(column, value)
        .select()
        .single();
    return response;
  }
  
  static Future<void> deleteData({
    required String table,
    required String column,
    required dynamic value,
  }) async {
    await client.from(table).delete().eq(column, value);
  }
  
  // 알림 메시지 조회
  static Future<List<Map<String, dynamic>>> getNotificationMessages() async {
    try {
      // 로컬 환경에서는 빈 배열 반환
      if (await _checkLocalServer()) {
        print('SupabaseService: 로컬 환경 - 알림 메시지 조회 건너뛰기');
        return [];
      }
      
      final response = await client
          .from('notification_messages')
          .select('ko_msg, en_msg, ja_msg, zh_msg')
          .order('noti_id');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Supabase 알림 메시지 조회 오류: $e');
      return [];
    }
  }
  
  // 언어별 메시지 배열로 변환
  static List<String> parseMessages(String? messages) {
    if (messages == null || messages.isEmpty) return [];
    return messages.split(',').map((msg) => msg.trim()).toList();
  }
}

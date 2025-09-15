import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  // Supabase 초기화
  static Future<void> initialize() async {
    print('SupabaseService 초기화 시작...');
    
    await Supabase.initialize(
      url: 'https://dxgsejmqfywvskgvtevm.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR4Z3Nlam1xZnl3dnNrZ3Z0ZXZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwMDQ3MzMsImV4cCI6MjA3MDU4MDczM30.IXMQF3HyTgFXaHNeCXpkeX6wOSUiLWIiL3lpkdMEDLY',
    );
    
    print('Supabase 초기화 완료');
    
    // 익명 로그인으로 user_id 생성
    print('익명 로그인 시도...');
    await _signInAnonymously();
    print('익명 로그인 시도 완료');
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
}

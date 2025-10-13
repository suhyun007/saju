import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  static UserModel? _currentUser;
  static final List<Function(UserModel?)> _authStateListeners = [];
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // 현재 사용자 스트림 (시뮬레이션)
  static Stream<UserModel?> get authStateChanges {
    return Stream.fromFuture(Future.value(_currentUser));
  }
  
  // 현재 사용자
  static UserModel? get currentUser => _currentUser;

  // Google Sign-In
  static Future<UserModel?> signInWithGoogle() async {
    try {
      // Google Sign-In 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // 사용자가 취소함
      }

      // UserModel 생성
      final userModel = UserModel(
        id: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName ?? '',
        photoURL: googleUser.photoUrl,
        provider: 'google',
      );

      // Supabase users_kpop 테이블에 사용자 정보 저장 또는 업데이트
      await _saveUserToSupabase(userModel);

      // 로컬에 사용자 정보 저장
      await _saveUserToLocal(userModel);
      
      // 현재 사용자 설정
      _currentUser = userModel;
      
      // 리스너들에게 알림
      _notifyAuthStateListeners();
      
      return userModel;
    } catch (e) {
      print('Google Sign-In 오류: $e');
      return null;
    }
  }

  // 로그아웃
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _removeUserFromLocal();
      _currentUser = null;
      _notifyAuthStateListeners();
    } catch (e) {
      print('로그아웃 오류: $e');
    }
  }

  // 계정 탈퇴 (is_active를 false로 업데이트)
  static Future<bool> deleteAccount() async {
    try {
      if (_currentUser == null) {
        print('탈퇴 실패: 로그인된 사용자가 없습니다.');
        return false;
      }

      // Supabase users_kpop 테이블에서 is_active를 false로 업데이트
      await SupabaseService.client
          .from('users_kpop')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('email', _currentUser!.email);

      print('계정 탈퇴 완료: ${_currentUser!.email} (is_active = false)');

      // 로그아웃 처리
      await signOut();
      
      return true;
    } catch (e) {
      print('계정 탈퇴 오류: $e');
      return false;
    }
  }

  // 인증 상태 리스너 추가
  static void addAuthStateListener(Function(UserModel?) listener) {
    _authStateListeners.add(listener);
  }

  // 인증 상태 리스너 제거
  static void removeAuthStateListener(Function(UserModel?) listener) {
    _authStateListeners.remove(listener);
  }

  // 리스너들에게 알림
  static void _notifyAuthStateListeners() {
    for (final listener in _authStateListeners) {
      listener(_currentUser);
    }
  }

  // Supabase users_kpop 테이블에 사용자 정보 저장
  static Future<void> _saveUserToSupabase(UserModel user) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final userData = {
        'email': user.email,
        'provider': user.provider ?? 'google',
        'provider_id': user.id,  // Google ID
        'name': user.displayName,
        'is_active': true,
        'last_login_at': now,
        'updated_at': now,
      };

      // users_kpop 테이블에 upsert (email 기준으로 있으면 업데이트, 없으면 삽입)
      await SupabaseService.client
          .from('users_kpop')
          .upsert(userData, onConflict: 'email');
      
      print('Supabase users_kpop 테이블에 사용자 정보 저장 완료: ${user.email}');
    } catch (e) {
      print('Supabase 사용자 정보 저장 오류: $e');
      print('오류 상세: $e');
      // Supabase 저장 실패해도 앱은 계속 작동
    }
  }

  // 로컬에 사용자 정보 저장
  static Future<void> _saveUserToLocal(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
    } catch (e) {
      print('사용자 정보 저장 오류: $e');
    }
  }

  // 로컬에서 사용자 정보 가져오기
  static Future<UserModel?> getUserFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      
      return null;
    } catch (e) {
      print('사용자 정보 로드 오류: $e');
      return null;
    }
  }

  // 로컬에서 사용자 정보 삭제
  static Future<void> _removeUserFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
    } catch (e) {
      print('사용자 정보 삭제 오류: $e');
    }
  }

  // 사용자 정보 업데이트
  static Future<void> updateUserInfo(UserModel user) async {
    await _saveUserToLocal(user);
  }
}

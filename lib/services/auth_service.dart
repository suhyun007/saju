import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

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

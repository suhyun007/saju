import 'package:flutter/material.dart';
import 'dart:io';

class LanguageService extends ChangeNotifier {
  Locale _currentLocale = const Locale('ko'); // 기본값은 한국어
  
  Locale get currentLocale => _currentLocale;
  
  // 지원하는 언어 목록
  static const List<Locale> supportedLocales = [
    Locale('ko'), // 한국어
    Locale('en'), // 영어
    Locale('zh'), // 중국어
    Locale('ja'), // 일본어
  ];
  
  LanguageService() {
    _initializeWithSystemLanguage();
  }
  
  // 시스템의 선호하는 언어 감지 (더 정확한 방법)
  Locale getSystemLocale() {
    print('=== 시스템 언어 감지 시작 ===');
    
    // 방법 1: WidgetsBinding.instance.window.locales (선호하는 언어 순서)
    if (WidgetsBinding.instance.window.locales.isNotEmpty) {
      final preferredLocales = WidgetsBinding.instance.window.locales;
      print('=== 선호하는 언어 목록: ${preferredLocales.map((l) => '${l.languageCode}_${l.countryCode}').join(', ')} ===');
      
      // 첫 번째 선호 언어가 지원하는 언어인지 확인
      for (final locale in preferredLocales) {
        if (supportedLocales.any((supported) => supported.languageCode == locale.languageCode)) {
          print('=== 선호하는 언어에서 지원 언어 발견: ${locale.languageCode} ===');
          return locale;
        }
      }
    }
    
    // 방법 2: Platform.localeName (시스템 로케일)
    try {
      final platformLocale = Platform.localeName;
      print('=== Platform.localeName: $platformLocale ===');
      
      // localeName에서 언어 코드 추출 (예: "en_US" -> "en")
      final languageCode = platformLocale.split('_')[0];
      if (supportedLocales.any((locale) => locale.languageCode == languageCode)) {
        print('=== Platform에서 지원 언어 발견: $languageCode ===');
        return Locale(languageCode);
      }
    } catch (e) {
      print('=== Platform.localeName 오류: $e ===');
    }
    
    // 방법 3: WidgetsBinding.instance.window.locale (기존 방법)
    final fallbackLocale = WidgetsBinding.instance.window.locale;
    print('=== fallback locale: ${fallbackLocale.languageCode} ===');
    
    if (supportedLocales.any((locale) => locale.languageCode == fallbackLocale.languageCode)) {
      print('=== fallback에서 지원 언어 발견: ${fallbackLocale.languageCode} ===');
      return fallbackLocale;
    }
    
    // 지원하지 않는 언어인 경우 기본값 반환
    print('=== 지원하지 않는 언어, 기본값 한국어 반환 ===');
    return const Locale('ko');
  }
  
  // 앱 시작 시 시스템 언어로 초기화
  Future<void> _initializeWithSystemLanguage() async {
    final systemLocale = getSystemLocale();
    _currentLocale = systemLocale;
    notifyListeners();
    print('=== 시스템 언어로 초기화 완료: ${systemLocale.languageCode} ===');
  }
  
  // 시스템 언어 변경 감지 및 자동 업데이트
  Future<void> checkAndUpdateSystemLanguage() async {
    print('=== 시스템 언어 변경 감지 시작 ===');
    final systemLocale = getSystemLocale();
    
    if (_currentLocale.languageCode != systemLocale.languageCode) {
      // 시스템 언어가 변경되었으면 자동으로 업데이트
      print('=== 언어 변경 감지: ${_currentLocale.languageCode} → ${systemLocale.languageCode} ===');
      _currentLocale = systemLocale;
      notifyListeners();
      print('=== 언어 변경 완료: ${_currentLocale.languageCode} ===');
    } else {
      print('=== 언어 변경 없음: ${_currentLocale.languageCode} ===');
    }
  }
}

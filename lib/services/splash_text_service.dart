import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class SplashTextService {
  static Map<String, dynamic>? _splashTexts;
  
  static Future<void> loadSplashTexts() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/splash_texts.json');
      _splashTexts = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('스플래시 텍스트 로드 실패: $e');
      // 기본값 설정
      _splashTexts = {
        "app_name": "LunaVerse",
        "subtitle": "별자리의 신비로움을 통해 운세를 알아보세요",
        "button_text": "시작하기",
        "loading_text": "로딩 중...",
      };
    }
  }
  
  static String getAppName() {
    return _splashTexts?['app_name'] ?? 'LunaVerse';
  }
  
  static String getSubtitle() {
    final List<dynamic>? subtitles = _splashTexts?['subtitle'];
    if (subtitles != null && subtitles.isNotEmpty) {
      final random = Random();
      final randomIndex = random.nextInt(subtitles.length);
      return subtitles[randomIndex] as String;
    }
    return '별자리의 신비로움을 통해 운세를 알아보세요';
  }
  
  static String getButtonText() {
    return _splashTexts?['button_text'] ?? '시작하기';
  }
  
  static String getLoadingText() {
    return _splashTexts?['loading_text'] ?? '로딩 중...';
  }
  
  static List<String> getBackgroundGradient() {
    final List<dynamic>? gradient = _splashTexts?['themes']?['background_gradient'];
    if (gradient != null) {
      return gradient.cast<String>();
    }
    return ['#1a1a2e', '#16213e', '#0f3460'];
  }
  
  static Map<String, dynamic> getAnimations() {
    return _splashTexts?['animations'] ?? {
      "fade_duration": 2000,
      "scale_duration": 2000,
      "button_scale": 1.1
    };
  }
}

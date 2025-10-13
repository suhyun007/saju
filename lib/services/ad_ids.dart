import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AdIds {
  // 운영/개발 분리 스위치
  // 플랫폼 별 테스트 모드 스위치 (kDebugMode와 무관하게 수동 전환)
  // iOS 는 운영 유지, Android 만 테스트 광고 사용
  static const bool isIosTestMode = false;
  static const bool isAndroidTestMode = true;

  // iOS 운영용 단위 ID
  static const String iosBannerProd = 'ca-app-pub-8911842959624418/5167207632';
  static const String iosInterstitialProd = 'ca-app-pub-8911842959624418/7290808092';
  static const String iosNativeProd = 'ca-app-pub-8911842959624418/5299069573';
  static const String iosFavoriteBannerProd = 'ca-app-pub-8911842959624418/7474108094';

  // Android 운영용 단위 ID
  static const String androidNativeProd = 'ca-app-pub-8911842959624418/7190218829';
  static const String androidBannerProd = 'ca-app-pub-8911842959624418/5981078933';
  static const String androidFavoriteBannerProd = 'ca-app-pub-8911842959624418/4305035187';
  static const String androidInterstitialProd = 'ca-app-pub-8911842959624418/9816382166';

  // Google 공식 테스트 단위 ID
  static const String iosBannerTest = 'ca-app-pub-3940256099942544/2934735716';
  static const String iosInterstitialTest = 'ca-app-pub-3940256099942544/4411468910';
  static const String iosNativeTest = 'ca-app-pub-3940256099942544/3986624511';
  static const String androidNativeTest = 'ca-app-pub-3940256099942544/2247696110';
  static const String androidBannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const String androidInterstitialTest = 'ca-app-pub-3940256099942544/1033173712';

  // Getter: 현재 모드에 맞는 ID 제공
  static String get iosBanner => isIosTestMode ? iosBannerTest : iosBannerProd;
  static String get iosInterstitial => isIosTestMode ? iosInterstitialTest : iosInterstitialProd;
  static String get iosNative => isIosTestMode ? iosNativeTest : iosNativeProd;
  static String get iosFavoriteBanner => isIosTestMode ? iosBannerTest : iosFavoriteBannerProd;
  static String get androidNative => isAndroidTestMode ? androidNativeTest : androidNativeProd;
  static String get androidBanner => isAndroidTestMode ? androidBannerTest : androidBannerProd;
  static String get androidFavoriteBanner => isAndroidTestMode ? androidBannerTest : androidFavoriteBannerProd;
  static String get androidInterstitial => isAndroidTestMode ? androidInterstitialTest : androidInterstitialProd;

  // Cross-platform getter for Native ad unit
  static String get native {
    if (kIsWeb) return iosNativeTest; // Fallback when running on web
    return Platform.isAndroid ? androidNative : iosNative;
  }

  // Cross-platform getter for Banner ad unit
  static String get banner {
    if (kIsWeb) return iosBannerTest;
    return Platform.isAndroid ? androidBanner : iosBanner;
  }

  static String get favoriteBanner {
    if (kIsWeb) return iosBannerTest;
    return Platform.isAndroid ? androidFavoriteBanner : iosFavoriteBanner;
  }

  static String get interstitial {
    if (kIsWeb) return iosInterstitialTest;
    return Platform.isAndroid ? androidInterstitial : iosInterstitial;
  }

  // (옵션) 디버그 모드에서 자동 테스트 전환을 원하면 아래처럼 사용
  // static String get iosBanner => kDebugMode ? iosBannerTest : iosBannerProd;
}



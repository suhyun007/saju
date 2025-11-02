import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AdIds {

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
  // 안드로이드/iOS 동일: 프로덕션 빌드가 아닐 때(디버그/프로파일/애뮬레이터)는 무조건 테스트 광고 사용
  static String get iosBanner => !kReleaseMode ? iosBannerTest : iosBannerProd;
  static String get iosInterstitial => !kReleaseMode ? iosInterstitialTest : iosInterstitialProd;
  static String get iosNative => !kReleaseMode ? iosNativeTest : iosNativeProd;
  static String get iosFavoriteBanner => !kReleaseMode ? iosBannerTest : iosFavoriteBannerProd;
  static String get androidNative => !kReleaseMode ? androidNativeTest : androidNativeProd;
  static String get androidBanner => !kReleaseMode ? androidBannerTest : androidBannerProd;
  static String get androidFavoriteBanner => !kReleaseMode ? androidBannerTest : androidFavoriteBannerProd;
  static String get androidInterstitial => !kReleaseMode ? androidInterstitialTest : androidInterstitialProd;

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

  // 운영 버전이 아닐 때(디버그/프로파일/애뮬레이터)는 무조건 테스트 광고 ID 사용
  // 안드로이드와 iOS 모두 동일하게 kReleaseMode로 판단
}



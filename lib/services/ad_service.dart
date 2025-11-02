import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

class AdService {
  static InterstitialAd? _interstitial;
  static int _lastShownMs = 0;
  // Deprecated: previously used for per-session limits
  // static int _shownCount = 0;
  static NativeAd? _preloadedNative;
  static bool _preloadedNativeLoaded = false;

  // 정책: 최소 4분 간격 반복 허용
  static const int _minIntervalMs = 240000;
  

  static void preloadInterstitial() {
    if (_interstitial != null) return;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint('Interstitial load failed: $error');
          }
          _interstitial = null;
        },
      ),
    );
  }

  // Preload a single NativeAd for faster first paint
  static void preloadNative() {
    if (_preloadedNative != null) return;
    _preloadedNativeLoaded = false;
    final native = NativeAd(
      adUnitId: AdIds.native,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _preloadedNativeLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _preloadedNative = null;
          _preloadedNativeLoaded = false;
        },
      ),
    );
    _preloadedNative = native;
    native.load();
  }

  // Take and clear the preloaded native ad only if it's ready
  static NativeAd? takeReadyNative() {
    if (_preloadedNative != null && _preloadedNativeLoaded) {
      final ad = _preloadedNative;
      _preloadedNative = null;
      _preloadedNativeLoaded = false;
      return ad;
    }
    return null;
  }

  static Future<void> maybeShowInterstitial(BuildContext context) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    // 2분 쿨다운만 적용
    if (now - _lastShownMs < _minIntervalMs) return;
    final ad = _interstitial;
    if (ad == null) {
      preloadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitial = null;
        if (kDebugMode) {
          debugPrint('Interstitial show failed: $error');
        }
        preloadInterstitial();
      },
    );
    try {
      await ad.show();
      _lastShownMs = now;
      _interstitial = null;
      preloadInterstitial();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Interstitial show error: $e');
      }
    }
  }

  // 서버 호출과 별개로 4분 쿨다운 체크 후 자동 표시
  static Future<void> checkAndShowAutoInterstitial(BuildContext context) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    // 4분 쿨다운 체크
    if (now - _lastShownMs < _minIntervalMs) return;
    
    final ad = _interstitial;
    if (ad == null) {
      preloadInterstitial();
      return;
    }
    
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitial = null;
        if (kDebugMode) {
          debugPrint('Auto interstitial show failed: $error');
        }
        preloadInterstitial();
      },
    );
    
    try {
      await ad.show();
      _lastShownMs = now;
      _interstitial = null;
      preloadInterstitial();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Auto interstitial show error: $e');
      }
    }
  }

  // 쿨다운 무시하고 즉시 노출 (서버 호출 확정 시 사용)
  static Future<void> forceShowInterstitial(BuildContext context) async {
    final ad = _interstitial;
    if (ad == null) {
      preloadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitial = null;
        if (kDebugMode) {
          debugPrint('Interstitial show failed: $error');
        }
        preloadInterstitial();
      },
    );
    try {
      await ad.show();
      _lastShownMs = DateTime.now().millisecondsSinceEpoch;
      _interstitial = null;
      preloadInterstitial();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Interstitial show error: $e');
      }
    }
  }
}



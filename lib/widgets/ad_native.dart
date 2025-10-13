import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_ids.dart';
import '../services/ad_service.dart';

class AdNative extends StatefulWidget {
  const AdNative({super.key});

  @override
  State<AdNative> createState() => _AdNativeState();
}

class _AdNativeState extends State<AdNative> {
  NativeAd? _nativeAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // Use preloaded if available; otherwise create and load
    final pre = AdService.takeReadyNative();
    if (pre != null) {
      _nativeAd = pre;
      _loaded = true;
      // Trigger next preload for subsequent uses
      AdService.preloadNative();
    } else {
      _nativeAd = NativeAd(
        adUnitId: AdIds.native,
        factoryId: 'listTile',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            if (!mounted) return;
            setState(() { _loaded = true; });
            AdService.preloadNative();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            AdService.preloadNative();
          },
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: _loaded && _nativeAd != null
          ? AdWidget(ad: _nativeAd!)
          : const SizedBox.shrink(),
    );
  }
}



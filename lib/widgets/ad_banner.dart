import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  /// ✅ Official Google TEST Banner IDs
  static const String _androidTestBannerId =
      'ca-app-pub-3940256099942544/9214589741';
  static const String _iosTestBannerId =
      'ca-app-pub-3940256099942544/2934735716';

  String get _adUnitId {
    if (Platform.isAndroid) return _androidTestBannerId;
    if (Platform.isIOS) return _iosTestBannerId;
    throw UnsupportedError('Unsupported platform');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    if (_bannerAd != null) return;

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      debugPrint('❌ Failed to get adaptive banner size');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Banner Ad Loaded');
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
              '❌ Banner Ad Failed: ${error.code} - ${error.message}');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );

    await _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

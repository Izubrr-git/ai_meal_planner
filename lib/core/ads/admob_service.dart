import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

import '../analytics/analytics_config.dart';
import '../analytics/appsflyer_service.dart';
import '../analytics/firebase_analytics_service.dart';

class AdMobService {
  static AdMobService? _instance;
  bool _initialized = false;

  // Рекламные блоки
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;
  NativeAd? _nativeAd;

  AdMobService._private();

  factory AdMobService() {
    _instance ??= AdMobService._private();
    return _instance!;
  }

  Future<void> initialize() async {
    try {
      if (_initialized) return;

      await MobileAds.instance.initialize();

      // Настраиваем запрос на рекламу
      final request = AdRequest(
        keywords: ['food', 'nutrition', 'health', 'fitness'],
        contentUrl: 'https://aimealplanner.com',
      );

      _initialized = true;
      debugPrint('✅ AdMob initialized successfully');

      // Предзагружаем рекламу
      _preloadAds();
    } catch (e) {
      debugPrint('❌ AdMob initialization error: $e');
    }
  }

  void _preloadAds() {
    _loadInterstitialAd();
    _loadRewardedAd();
    _loadAppOpenAd();
  }

  Future<void> _loadInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: AnalyticsConfig.admobInterstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;

            // Устанавливаем обработчики событий
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                _logAdImpression('interstitial');
              },
              onAdClicked: (ad) {
                _logAdClick('interstitial');
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _loadInterstitialAd(); // Загружаем следующий
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _loadInterstitialAd();
              },
            );

            debugPrint('✅ Interstitial ad loaded');
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ Interstitial ad failed to load: $error');
            Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Error loading interstitial ad: $e');
    }
  }

  Future<void> _loadRewardedAd() async {
    try {
      await RewardedAd.load(
        adUnitId: AnalyticsConfig.admobRewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                _logAdImpression('rewarded');
              },
              onAdClicked: (ad) {
                _logAdClick('rewarded');
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _loadRewardedAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _loadRewardedAd();
              },
            );

            debugPrint('✅ Rewarded ad loaded');
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ Rewarded ad failed to load: $error');
            Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Error loading rewarded ad: $e');
    }
  }

  Future<void> _loadAppOpenAd() async {
    try {
      await AppOpenAd.load(
        adUnitId: AnalyticsConfig.admobAppOpenId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                _logAdImpression('app_open');
              },
              onAdClicked: (ad) {
                _logAdClick('app_open');
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _loadAppOpenAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _loadAppOpenAd();
              },
            );

            debugPrint('✅ App Open ad loaded');
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ App Open ad failed to load: $error');
            Future.delayed(const Duration(seconds: 30), _loadAppOpenAd);
          },
        ),
        // Параметр orientation был удален в новой версии API
      );
    } catch (e) {
      debugPrint('❌ Error loading app open ad: $e');
    }
  }

  void _logAdImpression(String adType) {
    // Логируем в аналитику
    AppsFlyerService().logEvent(AnalyticsConfig.eventAdImpression, {
      'ad_type': adType,
      'timestamp': DateTime.now().toIso8601String(),
    });

    FirebaseAnalyticsService().logEvent(
      name: AnalyticsConfig.eventAdImpression,
      parameters: {'ad_type': adType},
    );
  }

  void _logAdClick(String adType) {
    AppsFlyerService().logEvent(AnalyticsConfig.eventAdClicked, {
      'ad_type': adType,
      'timestamp': DateTime.now().toIso8601String(),
    });

    FirebaseAnalyticsService().logEvent(
      name: AnalyticsConfig.eventAdClicked,
      parameters: {'ad_type': adType},
    );
  }

  // Методы для показа рекламы
  Future<bool> showInterstitialAd() async {
    try {
      if (_interstitialAd == null) {
        await _loadInterstitialAd();
        return false;
      }

      await _interstitialAd?.show();
      return true;
    } catch (e) {
      debugPrint('❌ Error showing interstitial ad: $e');
      return false;
    }
  }

  Future<bool> showRewardedAd() async {
    try {
      if (_rewardedAd == null) {
        await _loadRewardedAd();
        return false;
      }

      await _rewardedAd?.show(onUserEarnedReward: (ad, reward) {
        debugPrint('🎁 User earned reward: ${reward.amount} ${reward.type}');
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error showing rewarded ad: $e');
      return false;
    }
  }

  Future<bool> showAppOpenAd() async {
    try {
      if (_appOpenAd == null) {
        await _loadAppOpenAd();
        return false;
      }

      await _appOpenAd?.show();
      return true;
    } catch (e) {
      debugPrint('❌ Error showing app open ad: $e');
      return false;
    }
  }

  Widget getBannerAd() {
    _bannerAd ??= BannerAd(
        adUnitId: AnalyticsConfig.admobBannerId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _logAdImpression('banner');
          },
          onAdClicked: (ad) {
            _logAdClick('banner');
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('❌ Banner ad failed to load: $error');
            ad.dispose();
            Future.delayed(const Duration(seconds: 30), () {
              _bannerAd = null;
            });
          },
        ),
      )..load();

    return Container(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
    _nativeAd?.dispose();
  }
}
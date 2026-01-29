import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'analytics_config.dart';
import 'appsflyer_service.dart';
import 'firebase_analytics_service.dart';
import '../ads/admob_service.dart';

class AnalyticsManager {
  static AnalyticsManager? _instance;
  final AppsFlyerService _appsFlyerService;
  final FirebaseAnalyticsService _firebaseAnalyticsService;
  final AdMobService _adMobService;

  AnalyticsManager._private()
      : _appsFlyerService = AppsFlyerService(),
        _firebaseAnalyticsService = FirebaseAnalyticsService(),
        _adMobService = AdMobService();

  factory AnalyticsManager() {
    _instance ??= AnalyticsManager._private();
    return _instance!;
  }

  Future<void> initialize() async {
    debugPrint('🚀 Initializing analytics and ads...');

    try {
      // ✅ Инициализируем AppsFlyer без ожидания
      unawaited(_appsFlyerService.initialize().catchError((e) {
        debugPrint('⚠️ AppsFlyer error: $e');
      }));

      await _firebaseAnalyticsService.initialize();
      await _adMobService.initialize();

      debugPrint('✅ All analytics services initialized');
    } catch (e) {
      debugPrint('❌ Error initializing analytics: $e');
    }
  }

  // AppsFlyer методы
  Future<void> logAppsFlyerEvent(String eventName, [Map<String, dynamic>? params]) async {
    try {
      await _appsFlyerService.logEvent(eventName, params);
    } catch (e) {
      debugPrint('❌ Error logging AppsFlyer event: $e');
    }
  }

  // Firebase Analytics методы
  Future<void> logFirebaseEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _firebaseAnalyticsService.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('❌ Error logging Firebase event: $e');
    }
  }

  Future<void> logScreenView(String screenName) async {
    try {
      await _firebaseAnalyticsService.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('❌ Error logging screen view: $e');
    }
  }

  // AdMob методы
  Future<bool> showInterstitialAd() async {
    try {
      return await _adMobService.showInterstitialAd();
    } catch (e) {
      debugPrint('❌ Error showing interstitial ad: $e');
      return false;
    }
  }

  Future<bool> showRewardedAd() async {
    try {
      return await _adMobService.showRewardedAd();
    } catch (e) {
      debugPrint('❌ Error showing rewarded ad: $e');
      return false;
    }
  }

  Future<bool> showAppOpenAd() async {
    try {
      return await _adMobService.showAppOpenAd();
    } catch (e) {
      debugPrint('❌ Error showing app open ad: $e');
      return false;
    }
  }

  Widget getBannerAd() {
    try {
      return _adMobService.getBannerAd();
    } catch (e) {
      debugPrint('❌ Error getting banner ad: $e');
      return Container(); // Возвращаем пустой контейнер при ошибке
    }
  }

  // Комбинированные методы для логирования событий
  Future<void> logPlanGenerated({
    required String goal,
    required int days,
    int? calories,
    required List<String> restrictions,
    required List<String> allergies,
  }) async {
    final eventData = {
      'goal': goal,
      'days': days,
      'calories': calories,
      'restrictions': restrictions.join(', '),
      'allergies': allergies.join(', '),
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      // Запускаем оба лога параллельно
      unawaited(_appsFlyerService.logEvent(AnalyticsConfig.eventPlanGenerated, eventData));
      unawaited(_firebaseAnalyticsService.logEvent(
        name: AnalyticsConfig.eventPlanGenerated,
        parameters: eventData,
      ));
    } catch (e) {
      debugPrint('⚠️ Error logging plan generated event: $e');
    }
  }

  Future<void> logPlanShared({
    required String shareType,
    required int days,
    required String goal,
  }) async {
    final eventData = {
      'share_type': shareType,
      'days': days,
      'goal': goal,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      // Запускаем оба лога параллельно
      unawaited(_appsFlyerService.logEvent(AnalyticsConfig.eventPlanShared, eventData));
      unawaited(_firebaseAnalyticsService.logEvent(
        name: AnalyticsConfig.eventPlanShared,
        parameters: eventData,
      ));
    } catch (e) {
      debugPrint('⚠️ Error logging plan shared event: $e');
    }
  }

  void dispose() {
    _adMobService.dispose();
  }
}
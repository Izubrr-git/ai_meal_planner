import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../ads/ad_cooldown_manager.dart';
import '../ads/ad_manager.dart';
import '../ads/unity_levelplay_service.dart';
import 'analytics_config.dart';
import 'appsflyer_service.dart';
import 'firebase_analytics_service.dart';
import '../ads/admob_service.dart';

class AnalyticsManager {
  static AnalyticsManager? _instance;
  final AppsFlyerService _appsFlyerService;
  final FirebaseAnalyticsService _firebaseAnalyticsService;
  final AdMobService _adMobService;

  // 🔥 Добавляем защиту
  bool _isProcessingAd = false;
  DateTime? _lastAdShownTime;
  static const Duration _minAdInterval = Duration(seconds: 5);

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

  Future<void> initializeAdMob() async {
    try {
      await _adMobService.initialize();
    } catch (e) {
      debugPrint('❌ Error initializing AdMob: $e');
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
      // 🔥 MEDIATION WATERFALL 🔥

      // 1. Сначала пробуем Unity LevelPlay (бывший ironSource)
      try {
        final unityService = UnityLevelPlayService();
        if (await unityService.isInterstitialReady()) {
          debugPrint('🎮 Using Unity LevelPlay interstitial');
          final result = await unityService.showInterstitial();
          if (result) return true;
        }
      } catch (e) {
        debugPrint('⚠️ Unity LevelPlay failed: $e');
      }

      // 2. Fallback на AdMob
      debugPrint('🔄 Falling back to AdMob interstitial');
      return await _adMobService.showInterstitialAd();

    } catch (e) {
      debugPrint('❌ All interstitial networks failed: $e');
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
      // Логируем в аналитику
      unawaited(_appsFlyerService.logEvent(AnalyticsConfig.eventPlanGenerated, eventData));
      unawaited(_firebaseAnalyticsService.logEvent(
        name: AnalyticsConfig.eventPlanGenerated,
        parameters: eventData,
      ));

      // Показываем интерстишиал (без ожидания)
      unawaited(showInterstitialWithCooldown());

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

  final AdCooldownManager _adCooldownManager = AdCooldownManager();

  Future<bool> showInterstitialWithCooldown() async {
    // Защита от одновременных вызовов
    if (_isProcessingAd) {
      debugPrint('⚠️ Ad is already being processed');
      return false;
    }

    // Проверяем минимальный интервал
    if (_lastAdShownTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShownTime!);
      if (timeSinceLastAd < _minAdInterval) {
        debugPrint('⏳ Too soon since last ad: ${timeSinceLastAd.inSeconds}s');
        return false;
      }
    }

    _isProcessingAd = true;

    try {
      final shown = await showInterstitialAd();

      if (shown) {
        _lastAdShownTime = DateTime.now();
        _adCooldownManager.endAdShow();
      }

      return shown;
    } finally {
      _isProcessingAd = false;
    }
  }

  void dispose() {
    _adMobService.dispose();
  }
}
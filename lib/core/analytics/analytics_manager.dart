import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'analytics_config.dart';
import 'appsflyer_service.dart';
import 'firebase_analytics_service.dart';
import 'appmetrica_service.dart'; // Добавлено
import '../ads/admob_service.dart';
import '../ads/unity_levelplay_service.dart'; // Добавлено

class AnalyticsManager {
  static AnalyticsManager? _instance;
  final AppsFlyerService _appsFlyerService;
  final FirebaseAnalyticsService _firebaseAnalyticsService;
  final AppMetricaService _appMetricaService; // Добавлено
  final AdMobService _adMobService;
  final UnityLevelPlayService _unityLevelPlayService; // Добавлено

  AnalyticsManager._private()
      : _appsFlyerService = AppsFlyerService(),
        _firebaseAnalyticsService = FirebaseAnalyticsService(),
        _appMetricaService = AppMetricaService(), // Добавлено
        _adMobService = AdMobService(),
        _unityLevelPlayService = UnityLevelPlayService(); // Добавлено

  factory AnalyticsManager() {
    _instance ??= AnalyticsManager._private();
    return _instance!;
  }

  Future<void> initialize() async {
    debugPrint('🚀 Initializing all analytics and ad services...');

    try {
      // Инициализируем все сервисы параллельно для скорости
      await Future.wait([
        _appsFlyerService.initialize(),
        _firebaseAnalyticsService.initialize(),
        _appMetricaService.initialize(), // Добавлено
        _adMobService.initialize(),
        _unityLevelPlayService.initialize(), // Добавлено
      ], eagerError: false).catchError((error) {
        debugPrint('⚠️ Some services failed: $error');
      });

      debugPrint('✅ All services initialized successfully');
    } catch (e, stack) {
      debugPrint('❌ Error initializing services: $e\n$stack');
    }
  }

  // Обновленные методы логирования событий
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
      'calories': calories?.toString() ?? 'not_set',
      'restrictions': restrictions.join(', '),
      'allergies': allergies.join(', '),
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Запускаем логирование во всех системах параллельно
    try {
      await Future.wait([
        _appsFlyerService.logEvent(AnalyticsConfig.eventPlanGenerated, eventData),
        _firebaseAnalyticsService.logEvent(
          name: AnalyticsConfig.eventPlanGenerated,
          parameters: eventData,
        ),
        _appMetricaService.logEvent(AnalyticsConfig.eventPlanGenerated, eventData), // Добавлено
      ], eagerError: false);

      // Показываем рекламу после генерации плана (ротация между сетями)
      await _showAdAfterPlanGeneration();
    } catch (e) {
      debugPrint('⚠️ Error logging plan generated event: $e');
    }
  }

  Future<void> _showAdAfterPlanGeneration() async {
    // Простая логика ротации: 70% AdMob, 30% Unity LevelPlay
    final random = Random().nextDouble();

    if (random < 0.7) {
      debugPrint('🔄 Showing AdMob interstitial');
      await _adMobService.showInterstitialAd();
    } else {
      debugPrint('🔄 Showing Unity LevelPlay interstitial');
      await _unityLevelPlayService.showInterstitial();
    }
  }

  // Методы для работы с рекламой разных сетей
  Future<bool> showInterstitialAd() async {
    // Можно реализовать более сложную логику медиации
    final admobAvailable = await _adMobService.showInterstitialAd();
    if (!admobAvailable) {
      return await _unityLevelPlayService.showInterstitial();
    }
    return admobAvailable;
  }

  Future<bool> showRewardedAd() async {
    // Сначала пробуем Unity LevelPlay
    if (await _unityLevelPlayService.isRewardedVideoAvailable()) {
      // Здесь нужна своя реализация показа rewarded
      debugPrint('🎁 Unity LevelPlay rewarded available');
      return true;
    }
    // Fallback на AdMob
    return await _adMobService.showRewardedAd();
  }

  // Получить баннер из AdMob (основной) или Unity (fallback)
  Widget getBannerAd() {
    return _adMobService.getBannerAd();
    // Или можно реализовать ротацию:
    // return _unityLevelPlayService.createBanner(size: BannerSize.standard);
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
      // Логируем во все системы аналитики
      await _appsFlyerService.logEvent(AnalyticsConfig.eventPlanShared, eventData);
      await _firebaseAnalyticsService.logEvent(
        name: AnalyticsConfig.eventPlanShared,
        parameters: eventData,
      );
      await _appMetricaService.logEvent(AnalyticsConfig.eventPlanShared, eventData);

      debugPrint('📤 Plan shared event logged: $shareType');
    } catch (e) {
      debugPrint('⚠️ Error logging plan shared event: $e');
    }
  }

  Future<bool> showAppOpenAd() async {
    try {
      debugPrint('🚀 Trying to show app open ad...');
      // Пробуем AdMob, так как Unity LevelPlay пока не поддерживает app open ads
      final success = await _adMobService.showAppOpenAd();
      if (!success) {
        debugPrint('⚠️ App open ad not available from AdMob');
        // Здесь можно добавить fallback на другую сеть при необходимости
      }
      return success;
    } catch (e) {
      debugPrint('❌ Error showing app open ad: $e');
      return false;
    }
  }

  void dispose() {
    _adMobService.dispose();
    _unityLevelPlayService.dispose();
  }
}
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

import '../analytics/analytics_config.dart';

// 1. Класс-обработчик событий инициализации
class _MyLevelPlayInitListener implements LevelPlayInitListener {
  final Function(LevelPlayConfiguration)? onInitialized;
  final Function(LevelPlayInitError)? onInitializationFailed;

  const _MyLevelPlayInitListener({this.onInitialized, this.onInitializationFailed});

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    debugPrint('✅ LevelPlay SDK initialized successfully');
    // FIXED: removed appKey and userId access - these properties don't exist
    debugPrint('   - Configuration: $configuration');
    onInitialized?.call(configuration);
  }

  @override
  void onInitFailed(LevelPlayInitError error) {
    debugPrint('❌ LevelPlay SDK initialization failed');
    // FIXED: Using errorCode and errorMessage instead of code and message
    debugPrint('   - Code: ${error.errorCode}');
    debugPrint('   - Message: ${error.errorMessage}');
    onInitializationFailed?.call(error);
  }
}

// 2. Класс-обработчик событий Interstitial рекламы
class _MyInterstitialListener implements LevelPlayInterstitialAdListener {
  final VoidCallback? onAdShownCallback;
  final VoidCallback? onAdClickedCallback;
  final VoidCallback? onAdClosedCallback;

  const _MyInterstitialListener({
    this.onAdShownCallback,
    this.onAdClickedCallback,
    this.onAdClosedCallback,
  });

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    debugPrint('🟢 Interstitial loaded: ${adInfo.adUnitId}');
    // FIXED: Using adNetwork instead of networkName
    debugPrint('   - Network: ${adInfo.adNetwork}');
    debugPrint('   - Instance: ${adInfo.instanceName}');
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    debugPrint('🔴 Interstitial load failed');
    debugPrint('   - Code: ${error.errorCode}');
    debugPrint('   - Message: ${error.errorMessage}');
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    debugPrint('👁️ Interstitial displayed');
    // FIXED: Using placementName instead of placement
    debugPrint('   - Placement: ${adInfo.placementName}');
    onAdShownCallback?.call();
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    debugPrint('❌ Interstitial display failed');
    debugPrint('   - Code: ${error.errorCode}');
    debugPrint('   - Message: ${error.errorMessage}');
    debugPrint('   - Ad Unit: ${adInfo.adUnitId}');
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {
    debugPrint('ℹ️ Interstitial ad info changed');
    debugPrint('   - Ad Unit: ${adInfo.adUnitId}');
    // FIXED: Using placementName instead of placement
    debugPrint('   - Placement: ${adInfo.placementName}');
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    debugPrint('👆 Interstitial clicked');
    debugPrint('   - Ad Unit: ${adInfo.adUnitId}');
    onAdClickedCallback?.call();
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    debugPrint('🔒 Interstitial closed');
    debugPrint('   - Ad Unit: ${adInfo.adUnitId}');
    onAdClosedCallback?.call();
  }

  @override
  void onAdOpened(LevelPlayAdInfo adInfo) {
    debugPrint('🚪 Interstitial opened');
    debugPrint('   - Ad Unit: ${adInfo.adUnitId}');
  }

  @override
  void onAdShowFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    debugPrint('⚠️ Interstitial show failed');
    debugPrint('   - Code: ${error.errorCode}');
    debugPrint('   - Message: ${error.errorMessage}');
    debugPrint('   - Ad Unit: ${adInfo.adUnitId}');
  }
}

// 3. Основной сервис Unity LevelPlay
class UnityLevelPlayService {
  static UnityLevelPlayService? _instance;
  bool _initialized = false;
  bool _isInitializing = false;
  bool _isShowingAd = false;
  final Completer<void> _initCompleter = Completer<void>();

  // Рекламные блоки и слушатели
  late LevelPlayInterstitialAd _interstitialAd;
  late _MyInterstitialListener _interstitialListener;

  // Коллбэки для аналитики
  VoidCallback? onInterstitialShown;
  VoidCallback? onInterstitialClicked;
  VoidCallback? onInterstitialClosed;

  // Конфигурация после инициализации
  LevelPlayConfiguration? _configuration;

  UnityLevelPlayService._private();

  factory UnityLevelPlayService() {
    _instance ??= UnityLevelPlayService._private();
    return _instance!;
  }

  /// Инициализация SDK Unity LevelPlay
  Future<void> initialize() async {
    if (_initialized) return;
    if (_isInitializing) return _initCompleter.future;

    _isInitializing = true;
    debugPrint('🔄 Initializing Unity LevelPlay SDK...');

    try {
      final initRequest = LevelPlayInitRequest.builder(AnalyticsConfig.unityLevelPlayAppKey)
          .withUserId(_generateUserId())
          .build();

      final initListener = _MyLevelPlayInitListener(
        onInitialized: (config) {
          debugPrint('✅ Unity LevelPlay SDK initialization complete');
          _configuration = config;
          _setupAdUnits();
          _initialized = true;
          _isInitializing = false;
          _initCompleter.complete();
        },
        onInitializationFailed: (error) {
          debugPrint('❌ Unity LevelPlay SDK initialization failed');
          _isInitializing = false;
          // FIXED: Using errorCode and errorMessage in Exception
          _initCompleter.completeError(
              Exception('Unity LevelPlay init failed: ${error.errorCode} - ${error.errorMessage}')
          );
        },
      );

      await LevelPlay.init(initRequest: initRequest, initListener: initListener);
      await _initCompleter.future;
    } catch (e, stack) {
      _isInitializing = false;
      debugPrint('❌ Error during LevelPlay.init: $e\n$stack');
      _initCompleter.completeError(e);
    }
  }

  /// Генерация User ID для отслеживания пользователя
  String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000000).toString().padLeft(6, '0');
    return 'user_$random';
  }

  /// Настройка рекламных блоков
  void _setupAdUnits() {
    debugPrint('⚙️ Setting up ad units...');

    _interstitialListener = _MyInterstitialListener(
      onAdShownCallback: () {
        debugPrint('📊 Interstitial shown - triggering analytics');
        onInterstitialShown?.call();
      },
      onAdClickedCallback: () {
        debugPrint('📊 Interstitial clicked - triggering analytics');
        onInterstitialClicked?.call();
      },
      onAdClosedCallback: () {
        debugPrint('📊 Interstitial closed - reloading');
        onInterstitialClosed?.call();
        Future.delayed(const Duration(seconds: 1), _loadInterstitialAd);
      },
    );

    _interstitialAd = LevelPlayInterstitialAd(adUnitId: '64wm5l5tsspp40x2');
    _interstitialAd.setListener(_interstitialListener);

    _loadInterstitialAd();
  }

  /// Загрузка Interstitial рекламы
  Future<void> _loadInterstitialAd() async {
    try {
      debugPrint('📥 Loading interstitial ad...');
      await _interstitialAd.loadAd();
      debugPrint('✅ Interstitial ad load initiated');
    } catch (e, stack) {
      debugPrint('❌ Error loading interstitial: $e\n$stack');
      Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
    }
  }

  /// Показать Interstitial рекламу
  Future<bool> showInterstitial({String? placementName}) async {
    try {
      if (_isShowingAd) {
        debugPrint('⚠️ Unity LevelPlay: Already showing an ad');
        return false;
      }

      if (!_initialized) {
        debugPrint('⚠️ Unity LevelPlay not initialized, initializing now...');
        await initialize();
      }

      final isReady = await _interstitialAd.isAdReady();
      if (!isReady) {
        debugPrint('⏳ Unity LevelPlay: Interstitial not ready yet');
        unawaited(_loadInterstitialAd());
        return false;
      }

      debugPrint('🎬 Unity LevelPlay: Showing interstitial ad...');
      _isShowingAd = true;
      await _interstitialAd.showAd(placementName: placementName);
      _isShowingAd = false;
      return true;
    } catch (e, stack) {
      _isShowingAd = false;
      debugPrint('❌ Unity LevelPlay: Error showing interstitial: $e\n$stack');
      return false;
    }
  }

  /// Проверить доступность Interstitial
  Future<bool> isInterstitialReady() async {
    if (!_initialized) {
      return false;
    }
    try {
      return await _interstitialAd.isAdReady();
    } catch (e) {
      debugPrint('❌ Error checking interstitial readiness: $e');
      return false;
    }
  }

  /// Получить конфигурацию SDK
  LevelPlayConfiguration? get configuration => _configuration;

  /// Получить статус инициализации
  bool get isInitialized => _initialized;

  // Простая заглушка для rewarded video (можно развить позже)
  Future<bool> isRewardedVideoAvailable() async {
    // Пока возвращаем false, так как не реализовали rewarded video
    debugPrint('⚠️ Rewarded video not implemented yet');
    return false;
  }

  /// Освобождение ресурсов
  void dispose() {
    debugPrint('♻️ Disposing UnityLevelPlayService resources');
  }
}
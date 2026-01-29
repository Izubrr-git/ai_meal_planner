import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

import '../analytics/analytics_config.dart';

class _MyLevelPlayInitListener implements LevelPlayInitListener {
  final Function(LevelPlayConfiguration)? onInitialized;
  final Function(LevelPlayInitError)? onInitializationFailed;

  const _MyLevelPlayInitListener({this.onInitialized, this.onInitializationFailed});

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    debugPrint('✅ LevelPlay SDK initialized successfully');
    debugPrint('   - Configuration: $configuration');
    onInitialized?.call(configuration);
  }

  @override
  void onInitFailed(LevelPlayInitError error) {
    debugPrint('❌ LevelPlay SDK initialization failed');
    debugPrint('   - Code: ${error.errorCode}');
    debugPrint('   - Message: ${error.errorMessage}');
    onInitializationFailed?.call(error);
  }
}

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

  void onAdOpened(LevelPlayAdInfo adInfo) {
    debugPrint('🚪 Interstitial opened');
    debugPrint('   - Ad Unit: ${adInfo.adUnitId}');
  }

  void onAdShowFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    debugPrint('⚠️ Interstitial show failed');
    debugPrint('   - Code: ${error.errorCode}');
    debugPrint('   - Message: ${error.errorMessage}');
    debugPrint('   - Ad Unit: ${adInfo.adUnitId}');
  }
}

class UnityLevelPlayService {
  static UnityLevelPlayService? _instance;
  bool _initialized = false;
  bool _isInitializing = false;
  bool _isShowingAd = false;
  final Completer<void> _initCompleter = Completer<void>();
  late LevelPlayInterstitialAd _interstitialAd;
  late _MyInterstitialListener _interstitialListener;
  VoidCallback? onInterstitialShown;
  VoidCallback? onInterstitialClicked;
  VoidCallback? onInterstitialClosed;
  LevelPlayConfiguration? _configuration;
  UnityLevelPlayService._private();

  factory UnityLevelPlayService() {
    _instance ??= UnityLevelPlayService._private();
    return _instance!;
  }

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

  String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000000).toString().padLeft(6, '0');
    return 'user_$random';
  }

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

  LevelPlayConfiguration? get configuration => _configuration;
  bool get isInitialized => _initialized;

  Future<bool> isRewardedVideoAvailable() async {
    debugPrint('⚠️ Rewarded video not implemented yet');
    return false;
  }

  void dispose() {
    debugPrint('♻️ Disposing UnityLevelPlayService resources');
  }
}
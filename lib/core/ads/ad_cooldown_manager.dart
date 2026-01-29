import 'package:flutter/foundation.dart';

class AdCooldownManager {
  static final AdCooldownManager _instance = AdCooldownManager._internal();
  factory AdCooldownManager() => _instance;

  static const Duration interstitialCooldown = Duration(seconds: 30);
  DateTime? _lastInterstitialShown;
  bool _isShowingAd = false;

  AdCooldownManager._internal();

  Future<bool> canShowInterstitial() async {
    if (_isShowingAd) {
      debugPrint('⏳ Ad is already being shown, skipping');
      return false;
    }

    if (_lastInterstitialShown != null) {
      final now = DateTime.now();
      final timeSinceLastAd = now.difference(_lastInterstitialShown!);

      if (timeSinceLastAd < interstitialCooldown) {
        final remaining = interstitialCooldown - timeSinceLastAd;
        debugPrint('⏳ Interstitial cooldown: ${remaining.inSeconds}s remaining');
        return false;
      }
    }

    return true;
  }

  void startAdShow() {
    _isShowingAd = true;
  }

  void endAdShow() {
    _lastInterstitialShown = DateTime.now();
    _isShowingAd = false;
    debugPrint('✅ Interstitial shown, cooldown started');
  }

  void reset() {
    _lastInterstitialShown = null;
    _isShowingAd = false;
  }
}
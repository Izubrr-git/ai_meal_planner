import 'package:flutter/foundation.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;

  static const Duration interstitialCooldown = Duration(seconds: 30);
  DateTime? _lastInterstitialShown;

  AdManager._internal();

  bool get canShowInterstitial {
    if (_lastInterstitialShown == null) return true;

    final now = DateTime.now();
    final timeSinceLastAd = now.difference(_lastInterstitialShown!);

    return timeSinceLastAd >= interstitialCooldown;
  }

  Duration? get timeUntilNextInterstitial {
    if (_lastInterstitialShown == null) return null;

    final now = DateTime.now();
    final timeSinceLastAd = now.difference(_lastInterstitialShown!);

    if (timeSinceLastAd >= interstitialCooldown) {
      return Duration.zero;
    }

    return interstitialCooldown - timeSinceLastAd;
  }

  void recordInterstitialShown() {
    _lastInterstitialShown = DateTime.now();
    debugPrint('📊 Interstitial shown at: $_lastInterstitialShown');
  }

  void resetInterstitialTimer() {
    _lastInterstitialShown = null;
    debugPrint('🔄 Interstitial timer reset');
  }
}
import 'package:flutter/material.dart';

import '../analytics/analytics_manager.dart';

mixin AdNavigationMixin<T extends StatefulWidget> on State<T> {
  final AnalyticsManager _analytics = AnalyticsManager();
  bool _isNavigating = false; // Защита от рекурсии

  Future<void> navigateWithAd(Widget page) async {
    if (_isNavigating) return; // Уже в процессе навигации
    _isNavigating = true;

    try {
      // Показываем рекламу ОДИН раз
      await _analytics.showInterstitialWithCooldown();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      }
    } finally {
      _isNavigating = false;
    }
  }

  Future<void> navigateAndReplaceWithAd(Widget page) async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      await _analytics.showInterstitialWithCooldown();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      }
    } finally {
      _isNavigating = false;
    }
  }
}
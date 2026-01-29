import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/foundation.dart';
import 'analytics_config.dart';
import 'package:decimal/decimal.dart';

class AppMetricaService {
  static AppMetricaService? _instance;
  bool _initialized = false;

  AppMetricaService._private();

  factory AppMetricaService() {
    _instance ??= AppMetricaService._private();
    return _instance!;
  }

  Future<void> initialize() async {
    try {
      if (_initialized) return;

      const config = AppMetricaConfig(
        AnalyticsConfig.appMetricaApiKey,
        logs: kDebugMode,
        sessionTimeout: 30,
        firstActivationAsUpdate: false,
      );

      await AppMetrica.activate(config);
      await AppMetrica.setUserProfileID('user_${DateTime.now().millisecondsSinceEpoch}');

      _initialized = true;
      debugPrint('✅ AppMetrica initialized');
    } catch (e) {
      debugPrint('❌ AppMetrica initialization error: $e');
    }
  }

  Future<void> logEvent(String eventName, [Map<String, dynamic>? params]) async {
    try {
      if (!_initialized) await initialize();

      if (params == null) {
        await AppMetrica.reportEvent(eventName);
      } else {
        final Map<String, Object> convertedParams = params.cast<String, Object>();
        await AppMetrica.reportEventWithMap(eventName, convertedParams);
      }

      debugPrint('📊 AppMetrica Event: $eventName');
    } catch (e) {
      debugPrint('❌ AppMetrica logEvent error: $e');
    }
  }

  // Map<String, Object> _convertParams(Map<String, dynamic> params) {
  //   final result = <String, Object>{};
  //
  //   params.forEach((key, value) {
  //     if (value != null) {
  //       if (value is String) {
  //         result[key] = value;
  //       } else if (value is num) {
  //         result[key] = value;
  //       } else if (value is bool) {
  //         result[key] = value;
  //       } else {
  //         result[key] = value.toString();
  //       }
  //     }
  //   });
  //
  //   return result;
  // }

  Future<void> logRevenue({
    required double price,
    required String currency,
    int? quantity,
    String? productId,
    String? transactionId,
    Map<String, dynamic>? payload,
    AppMetricaReceipt? receipt,
  }) async {
    try {
      if (!_initialized) await initialize();

      final revenue = AppMetricaRevenue(
        Decimal.parse(price.toString()),
        currency,
        quantity: quantity,
        productId: productId,
        transactionId: transactionId,
        receipt: receipt,
        payload: payload != null ? jsonEncode(payload) : null,
      );

      await AppMetrica.reportRevenue(revenue);
      debugPrint('💰 AppMetrica Revenue logged: $price $currency');
    } catch (e) {
      debugPrint('❌ AppMetrica logRevenue error: $e');
    }
  }

  Future<void> logAdRevenue({
    required AppMetricaAdRevenue adRevenue,
  }) async {
    try {
      await AppMetrica.reportAdRevenue(adRevenue);
    } catch (e) {
      debugPrint('❌ AppMetrica logAdRevenue error: $e');
    }
  }
}
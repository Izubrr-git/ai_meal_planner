import 'dart:async';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'analytics_config.dart';

class AppsFlyerService {
  static AppsFlyerService? _instance;
  late AppsflyerSdk _appsflyerSdk;
  bool _initialized = false;
  Completer<void>? _startSdkCompleter;

  AppsFlyerService._private();

  factory AppsFlyerService() {
    _instance ??= AppsFlyerService._private();
    return _instance!;
  }

  Future<void> initialize() async {
    try {
      if (_initialized) return;

      final options = {
        'afDevKey': AnalyticsConfig.appsFlyerDevKey,
        'afAppId': AnalyticsConfig.appleAppID,
        'isDebug': kDebugMode,
        'timeToWaitForATTUserAuthorization': AnalyticsConfig.attWaitingTime,
        'collectASA': true,
        'collectIMEI': false,
        'collectAndroidID': false,
      };

      _appsflyerSdk = AppsflyerSdk(options);

      // Инициализация SDK
      await _appsflyerSdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true,
      );

      // Устанавливаем коллбэки для конверсий
      _appsflyerSdk.onInstallConversionData((data) {
        debugPrint('AppsFlyer Conversion Data: $data');
        _sendConversionToAppHud(data);
      });

      _appsflyerSdk.onAppOpenAttribution((data) {
        debugPrint('AppsFlyer Deep Link Data: $data');
      });

      _appsflyerSdk.onDeepLinking((data) {
        debugPrint('AppsFlyer Deep Linking: $data');
      });

      _initialized = true;
      debugPrint('✅ AppsFlyer initialized successfully');

      // Запускаем SDK без await, так как метод возвращает void
      _startSdk();

    } catch (e) {
      debugPrint('❌ AppsFlyer initialization error: $e');
      // Завершаем Completer с ошибкой
      _startSdkCompleter?.completeError(e);
    }
  }

  void _startSdk() {
    try {
      _appsflyerSdk.startSDK(
        onSuccess: () {
          debugPrint('✅ AppsFlyer SDK started successfully');
          _startSdkCompleter?.complete();
        },
        onError: (errorCode, errorMessage) {
          final error = 'AppsFlyer SDK start error: $errorCode - $errorMessage';
          debugPrint('❌ $error');
          _startSdkCompleter?.completeError(Exception(error));
        },
      );
    } catch (e) {
      debugPrint('❌ Error starting AppsFlyer SDK: $e');
      _startSdkCompleter?.completeError(e);
    }
  }

  Future<void> waitForStart() async {
    if (_startSdkCompleter == null) {
      _startSdkCompleter = Completer<void>();

      // Таймаут 5 секунд
      Future.delayed(const Duration(seconds: 5), () {
        if (!_startSdkCompleter!.isCompleted) {
          _startSdkCompleter!.complete();
          debugPrint('⚠️ AppsFlyer start timeout - skipping');
        }
      });

      if (_initialized) {
        _startSdk();
      }
    }

    return _startSdkCompleter!.future;
  }

  void _sendConversionToAppHud(Map<dynamic, dynamic> conversionData) {
    try {
      final afStatus = conversionData['af_status'];
      final campaign = conversionData['campaign'];
      final mediaSource = conversionData['media_source'];

      debugPrint('📊 AppHud Attribution - Status: $afStatus, Campaign: $campaign, Source: $mediaSource');

      // Реализуйте интеграцию с AppHud здесь
      // Пример: await Apphud.sdk.addAttribution(...)
    } catch (e) {
      debugPrint('❌ Error sending conversion to AppHud: $e');
    }
  }

  Future<void> logEvent(String eventName, [Map<String, dynamic>? eventValues]) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      // Ждем успешного старта SDK
      await waitForStart();

      await _appsflyerSdk.logEvent(
        eventName,
        eventValues ?? {},
      );

      debugPrint('📈 AppsFlyer Event: $eventName - $eventValues');
    } catch (e) {
      debugPrint('❌ AppsFlyer logEvent error: $e');
    }
  }

  Future<String?> getAppsFlyerUID() async {
    try {
      if (!_initialized) {
        await initialize();
      }

      await waitForStart();
      return await _appsflyerSdk.getAppsFlyerUID();
    } catch (e) {
      debugPrint('❌ Error getting AppsFlyer UID: $e');
      return null;
    }
  }

  Future<void> logDeepLink(String deepLink) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      await waitForStart();
      await logEvent('deep_link_opened', {'link': deepLink});
    } catch (e) {
      debugPrint('❌ AppsFlyer deep link logging error: $e');
    }
  }
}
import 'dart:async';
import 'package:apphud/models/apphud_models/apphud_attribution_data.dart';
import 'package:apphud/models/apphud_models/apphud_attribution_provider.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:apphud/apphud.dart';

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

      await Apphud.start(apiKey: 'app_5z29xuZvQgGu95Yo8oVWVzmoRJLzAN');

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

      await _appsflyerSdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true,
      );

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

      _startSdk();

    } catch (e) {
      debugPrint('❌ AppsFlyer initialization error: $e');
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

  void _sendConversionToAppHud(Map<dynamic, dynamic> conversionData) async {
    try {
      final uid = await _appsflyerSdk.getAppsFlyerUID();

      if (uid != null && uid.isNotEmpty) {
        final attributionData = ApphudAttributionData(
          rawData: conversionData.cast<String, dynamic>(),
          adNetwork: conversionData['media_source']?.toString(),
          channel: conversionData['channel']?.toString(),
          campaign: conversionData['campaign']?.toString(),
          adSet: conversionData['adset']?.toString(),
          creative: conversionData['ad']?.toString(),
          keyword: conversionData['keyword']?.toString(),
        );

        await Apphud.setAttribution(
          provider: ApphudAttributionProvider.appsFlyer,
          identifier: uid,
          data: attributionData,
        );

        debugPrint('✅ AppHud attribution sent for UID: $uid');
      }
    } catch (e) {
      debugPrint('❌ Error sending attribution to AppHud: $e');
    }
  }

  Future<void> logEvent(String eventName, [Map<String, dynamic>? eventValues]) async {
    try {
      if (!_initialized) {
        await initialize();
      }

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
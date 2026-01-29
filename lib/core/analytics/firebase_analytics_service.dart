import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'analytics_config.dart';

class FirebaseAnalyticsService {
  static FirebaseAnalyticsService? _instance;
  late FirebaseAnalytics _analytics;
  bool _initialized = false;

  FirebaseAnalyticsService._private();

  factory FirebaseAnalyticsService() {
    _instance ??= FirebaseAnalyticsService._private();
    return _instance!;
  }

  Future<void> initialize() async {
    try {
      if (_initialized) return;

      await Firebase.initializeApp();
      _analytics = FirebaseAnalytics.instance;

      // Настраиваем параметры аналитики
      await _analytics.setAnalyticsCollectionEnabled(true);
      await _analytics.setUserId(id: await _getUserId());
      await _analytics.setUserProperty(name: 'app_version', value: '1.0.0');

      _initialized = true;
      debugPrint('✅ Firebase Analytics initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase Analytics initialization error: $e');
    }
  }

  Future<String> _getUserId() async {
    // Генерируем или получаем ID пользователя
    // В реальном приложении используйте уникальный ID пользователя
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      if (!_initialized) await initialize();

      // Безопасное преобразование с проверкой на null
      Map<String, Object>? firebaseParams;
      if (parameters != null) {
        // Метод .cast() создает Map<String, Object> "представление"
        firebaseParams = parameters.cast<String, Object>();
        // Альтернатива: создать новую мапу
        // firebaseParams = Map<String, Object>.from(parameters);
      }

      await _analytics.logEvent(
        name: name,
        parameters: firebaseParams,
      );

      debugPrint('📊 Firebase Event: $name - $parameters');
    } catch (e) {
      debugPrint('❌ Firebase Analytics logEvent error: $e');
    }
  }

  Future<void> setUserProperty({required String name, required String value}) async {
    try {
      if (!_initialized) await initialize();
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('❌ Firebase Analytics setUserProperty error: $e');
    }
  }

  Future<void> logScreenView({required String screenName}) async {
    try {
      if (!_initialized) await initialize();

      await _analytics.logScreenView(screenName: screenName);
      debugPrint('📱 Firebase Screen View: $screenName');
    } catch (e) {
      debugPrint('❌ Firebase Analytics screen view error: $e');
    }
  }
}
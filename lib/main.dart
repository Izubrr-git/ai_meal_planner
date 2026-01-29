import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/analytics/analytics_manager.dart';
import 'app/app.dart';
import 'core/constants/api_keys.dart';
import 'core/di/service_locator.dart';
import 'features/meal_planner/presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Инициализируем API ключи
  await ApiKeys.init();

  // Инициализируем сервисы
  await ServiceLocator.init();

  // ✅ Инициализируем SharedPreferences
  await SharedPreferences.getInstance();

  // ✅ Инициализируем аналитику (в фоне)
  unawaited(AnalyticsManager().initialize());

  runApp(
    ProviderScope(  // ✅ ProviderScope уже здесь
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AnalyticsManager _analyticsManager = AnalyticsManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Откладываем показ App Open Ad на 3 секунды после запуска
    Future.delayed(const Duration(seconds: 3), () {
      _showAppOpenAdSafely();
    });
  }

  Future<void> _showAppOpenAdSafely() async {
    try {
      final now = DateTime.now();

      // Проверяем время с момента запуска приложения
      final timeSinceStart = now.difference(_appStartTime);
      if (timeSinceStart < Duration(seconds: 2)) {
        debugPrint('⏳ Waiting for app to stabilize');
        return;
      }

      await AnalyticsManager().showAppOpenAd();
    } catch (e) {
      debugPrint('❌ Error in showAppOpenAdSafely: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // При возврате в приложение ждем 5 секунд
      Future.delayed(const Duration(seconds: 5), () {
        _showAppOpenAdSafely();
      });
    }
  }

  // Добавьте в класс:
  DateTime _appStartTime = DateTime.now();

  Future<void> _showAppOpenAdIfSafe() async {
    try {
      // Проверяем, что не было рекламы в последние 5 секунд
      final analytics = AnalyticsManager();

      // Ждем 500мс для стабильности
      await Future.delayed(const Duration(milliseconds: 500));

      // Показываем App Open Ad
      await analytics.showAppOpenAd();
    } catch (e) {
      debugPrint('❌ Error showing app open ad: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _analyticsManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: HomeScreen(), // Ваш главный экран
      debugShowCheckedModeBanner: false,
    );
  }
}
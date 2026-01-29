import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/analytics/analytics_manager.dart';
import 'app/app.dart';
import 'core/constants/api_keys.dart';
import 'core/di/service_locator.dart';
import 'features/meal_planner/presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiKeys.init();

  await ServiceLocator.init();

  await SharedPreferences.getInstance();

  unawaited(AnalyticsManager().initialize());

  runApp(
    ProviderScope(
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

    Future.delayed(const Duration(seconds: 3), () {
      _showAppOpenAdSafely();
    });
  }

  Future<void> _showAppOpenAdSafely() async {
    try {
      final now = DateTime.now();

      final timeSinceStart = now.difference(_appStartTime);
      if (timeSinceStart < const Duration(seconds: 2)) {
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

      Future.delayed(const Duration(seconds: 5), () {
        _showAppOpenAdSafely();
      });
    }
  }

  final DateTime _appStartTime = DateTime.now();

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
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
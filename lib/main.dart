import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/analytics/analytics_manager.dart';
import 'app/app.dart';
import 'features/meal_planner/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка ориентации
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Инициализация аналитики и рекламы
  await AnalyticsManager().initialize();

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

    // Показываем рекламу при открытии приложения
    _showAppOpenAd();
  }

  Future<void> _showAppOpenAd() async {
    await Future.delayed(const Duration(seconds: 1));
    await _analyticsManager.showAppOpenAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _analyticsManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _showAppOpenAd();
    }
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
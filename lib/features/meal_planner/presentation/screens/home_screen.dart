import 'package:ai_meal_planner/features/meal_planner/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../domain/entities/user_preferencies.dart';
import '../providers/meal_plan_provider.dart';
import '../widgets/meal_card.dart';
import 'history_screen.dart';
import 'meal_plan_detail_screen.dart';
import 'plan_generator_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  UserPreferences? _userPreferences;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadSavedPlans();
  }

  Future<void> _loadPreferences() async {
    final preferences = await ref.read(mealPlanProvider.notifier).loadPreferences();
    setState(() {
      _userPreferences = preferences ?? UserPreferences.defaults();
    });
  }

  Future<void> _loadSavedPlans() async {
    await ref.read(mealPlanProvider.notifier).loadSavedPlans();
  }

  void _navigateToGenerator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanGeneratorScreen(
          initialPreferences: _userPreferences,
        ),
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  void _quickGenerate() async {
    final preferences = _userPreferences ?? UserPreferences.defaults();

    await ref.read(mealPlanProvider.notifier).generateMealPlan(
      goal: preferences.goal,
      calories: preferences.targetCalories,
      restrictions: preferences.restrictions,
      allergies: preferences.allergies,
      days: 3,
    );

    final state = ref.read(mealPlanProvider);
    if (state.currentPlan != null && state.error == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MealPlanDetailScreen(plan: state.currentPlan!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealPlanProvider);
    final recentPlans = state.savedPlans.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Meal Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navigateToHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Привет!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Создайте персонализированный план питания с помощью ИИ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      onPressed: _navigateToGenerator,
                      text: 'Создать план питания',
                      icon: Icons.restaurant_menu,
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      onPressed: _quickGenerate,
                      text: 'Быстрая генерация',
                      variant: ButtonVariant.outlined,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Current preferences
            if (_userPreferences != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Текущие настройки',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            label: Text(_userPreferences!.goal),
                            backgroundColor: Colors.green.withOpacity(0.1),
                          ),
                          if (_userPreferences!.targetCalories != null)
                            Chip(
                              label: Text('${_userPreferences!.targetCalories} ккал'),
                              backgroundColor: Colors.blue.withOpacity(0.1),
                            ),
                          ..._userPreferences!.restrictions
                              .where((r) => r != 'Без ограничений')
                              .map((restriction) => Chip(
                            label: Text(restriction),
                            backgroundColor: Colors.orange.withOpacity(0.1),
                          )),
                          ..._userPreferences!.allergies
                              .where((a) => a != 'Нет')
                              .map((allergy) => Chip(
                            label: Text(allergy),
                            backgroundColor: Colors.red.withOpacity(0.1),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Recent plans
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Недавние планы',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: _navigateToHistory,
                  child: const Text('Все'),
                ),
              ],
            ),

            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (recentPlans.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'У вас пока нет сохраненных планов',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: recentPlans.map((plan) {
                  return MealCard(
                    plan: plan,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MealPlanDetailScreen(plan: plan),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

            // Error display
            if (state.error != null)
              AppErrorWidget(
                error: state.error!,
                onRetry: _loadSavedPlans,
              ),
          ],
        ),
      ),
    );
  }
}
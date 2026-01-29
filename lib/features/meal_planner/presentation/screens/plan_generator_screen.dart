import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/user_preferencies.dart';
import '../providers/meal_plan_provider.dart';
import 'meal_plan_detail_screen.dart';

class PlanGeneratorScreen extends ConsumerStatefulWidget {
  final UserPreferences? initialPreferences;

  const PlanGeneratorScreen({super.key, this.initialPreferences});

  @override
  ConsumerState<PlanGeneratorScreen> createState() => _PlanGeneratorScreenState();
}

class _PlanGeneratorScreenState extends ConsumerState<PlanGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _goal;
  late String _calories;
  late List<String> _selectedRestrictions;
  late List<String> _selectedAllergies;
  late int _days;

  @override
  void initState() {
    super.initState();
    final preferences = widget.initialPreferences ?? UserPreferences.defaults();

    _goal = preferences.goal;
    _calories = preferences.targetCalories?.toString() ?? '';
    _selectedRestrictions = List.from(preferences.restrictions);
    _selectedAllergies = List.from(preferences.allergies);
    _days = AppConstants.defaultDays;
  }

  void _generatePlan() async {
    if (_formKey.currentState?.validate() ?? false) {
      int? finalCalories;

      if (_calories.isEmpty) {
        final preferences =
        await ref.read(mealPlanProvider.notifier).loadPreferences();

        if (preferences != null &&
            preferences.age != null &&
            preferences.weight != null &&
            preferences.height != null &&
            preferences.gender != null) {
          finalCalories = preferences.calculateRecommendedCalories();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Используем рассчитанные калории: $finalCalories ккал/день',
                ),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        finalCalories = int.tryParse(_calories);
      }

      await ref.read(mealPlanProvider.notifier).generateMealPlan(
        goal: _goal,
        calories: _calories.isNotEmpty ? int.tryParse(_calories) : null,
        restrictions: _selectedRestrictions,
        allergies: _selectedAllergies,
        days: _days,
      );

      final state = ref.read(mealPlanProvider);

      if (state.currentPlan != null && state.error == null) {
        // Save preferences
        await ref.read(mealPlanProvider.notifier).savePreferences(
          UserPreferences(
            goal: _goal,
            targetCalories:
            _calories.isNotEmpty ? int.tryParse(_calories) : null,
            restrictions: _selectedRestrictions,
            allergies: _selectedAllergies,
          ),
        );

        // 📊 Аналитика — после успешной генерации плана
        AnalyticsManager().logPlanGenerated(
          goal: _goal,
          days: _days,
          calories: _calories.isNotEmpty ? int.tryParse(_calories) : null,
          restrictions: _selectedRestrictions,
          allergies: _selectedAllergies,
        );

        // 📢 Межстраничная реклама
        AnalyticsManager().showInterstitialAd();

        // Navigate to result
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MealPlanDetailScreen(plan: state.currentPlan!),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание плана питания'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal selection
              Text(
                'Цель',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _goal,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Выберите цель',
                ),
                items: AppConstants.goals
                    .map((goal) => DropdownMenuItem(
                  value: goal,
                  child: Text(goal),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _goal = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, выберите цель';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Calories input (optional)
              Text(
                'Целевые калории (опционально)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Оставьте пустым для автоматического расчета',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              AppTextField(
                initialValue: _calories,
                hintText: 'например, 2000',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _calories = value;
                },
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final calories = int.tryParse(value);
                    if (calories == null) {
                      return 'Введите число';
                    }
                    if (calories < 800) {
                      return 'Минимум 800 калорий для здорового питания';
                    }
                    if (calories > 5000) {
                      return 'Максимум 5000 калорий';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Dietary restrictions
              Text(
                'Диетические ограничения',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: AppConstants.dietaryRestrictions.map((restriction) {
                  final isSelected = _selectedRestrictions.contains(restriction);
                  return FilterChip(
                    label: Text(restriction),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedRestrictions.add(restriction);
                        } else {
                          _selectedRestrictions.remove(restriction);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Allergies
              Text(
                'Аллергии',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: AppConstants.allergies.map((allergy) {
                  final isSelected = _selectedAllergies.contains(allergy);
                  return FilterChip(
                    label: Text(allergy),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAllergies.add(allergy);
                        } else {
                          _selectedAllergies.remove(allergy);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Days selection
              Text(
                'Количество дней',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: AppConstants.daysOptions.map((days) {
                  return ChoiceChip(
                    label: Text('$days ${_getDayWord(days)}'),
                    selected: _days == days,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _days = days;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Generate button
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                AppButton(
                  onPressed: _generatePlan,
                  text: 'Сгенерировать план',
                  icon: Icons.auto_awesome,
                  isLoading: state.isLoading,
                ),

              if (state.error != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.red[700],
                        onPressed: () {
                          ref.read(mealPlanProvider.notifier).clearError();
                        },
                      ),
                    ],
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }

  String _getDayWord(int days) {
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }
}
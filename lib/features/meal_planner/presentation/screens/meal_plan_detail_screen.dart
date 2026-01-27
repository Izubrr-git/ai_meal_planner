import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_plan.dart';


class MealPlanDetailScreen extends StatelessWidget {
  final MealPlan plan;

  const MealPlanDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: plan.days,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'План питания',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                DateFormat('dd.MM.yyyy').format(plan.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: plan.mealDays
                .asMap()
                .entries
                .map((entry) => Tab(text: 'День ${entry.key + 1}'))
                .toList(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
          ],
        ),
        body: TabBarView(
          children: plan.mealDays.map((day) {
            return _buildDayView(day, context);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDayView(MealDay day, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${day.day} - ${day.date}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMacroStat('Калории', '${day.totalCalories}'),
                      _buildMacroStat('Белки', '${day.macros['protein'] ?? 0}г'),
                      _buildMacroStat('Углеводы', '${day.macros['carbs'] ?? 0}г'),
                      _buildMacroStat('Жиры', '${day.macros['fat'] ?? 0}г'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Meals
          Text(
            'Основные приемы пищи',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          _buildMealCard('Завтрак', day.meals['breakfast']!),
          const SizedBox(height: 12),
          _buildMealCard('Обед', day.meals['lunch']!),
          const SizedBox(height: 12),
          _buildMealCard('Ужин', day.meals['dinner']!),

          const SizedBox(height: 20),

          // Snacks
          if (day.snacks.isNotEmpty) ...[
            Text(
              'Перекусы',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...day.snacks.map((snack) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMealCard('Перекус', snack),
              );
            }).toList(),
          ],

          const SizedBox(height: 20),

          // Recommendations
          if (plan.recommendations.isNotEmpty) ...[
            Text(
              'Рекомендации',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final recommendation in plan.recommendations)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Plan summary
          if (plan.summary.isNotEmpty) ...[
            Text(
              'Описание плана',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  plan.summary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(String mealType, Meal meal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mealType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '${meal.calories} ккал',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              meal.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              meal.description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrient('Белки', '${meal.protein}г'),
                _buildNutrient('Углеводы', '${meal.carbs}г'),
                _buildNutrient('Жиры', '${meal.fat}г'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrient(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
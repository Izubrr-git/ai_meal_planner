import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/meal_plan.dart';

class ParameterCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final Color? iconColor;
  final bool showDivider;
  final VoidCallback? onTap;

  const ParameterCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.iconColor,
    this.showDivider = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и иконка
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor ?? theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: iconColor ?? theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Разделитель
              if (showDivider) ...[
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 12),
              ] else
                const SizedBox(height: 12),

              // Значение
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textColor.withValues(alpha: 0.9),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка с параметрами калорий
class CaloriesParameterCard extends StatelessWidget {
  final int calories;
  final bool isActive;
  final VoidCallback? onTap;

  const CaloriesParameterCard({
    super.key,
    required this.calories,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? theme.colorScheme.primary : theme.colorScheme.surface;
    final textColor = isActive ? Colors.white : theme.colorScheme.onSurface;

    return ParameterCard(
      title: 'Калории',
      value: AppFormatters.formatCalories(calories),
      icon: Icons.local_fire_department,
      color: color,
      iconColor: textColor,
      onTap: onTap,
    );
  }
}

/// Карточка с параметрами цели
class GoalParameterCard extends StatelessWidget {
  final String goal;
  final bool isActive;
  final VoidCallback? onTap;

  const GoalParameterCard({
    super.key,
    required this.goal,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _getGoalIcon(goal);
    final color = isActive ? theme.colorScheme.secondary : theme.colorScheme.surface;
    final textColor = isActive ? Colors.white : theme.colorScheme.onSurface;

    return ParameterCard(
      title: 'Цель',
      value: goal,
      icon: icon,
      color: color,
      iconColor: textColor,
      onTap: onTap,
    );
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'Похудение':
        return Icons.trending_down;
      case 'Набор мышечной массы':
        return Icons.fitness_center;
      case 'Поддержание веса':
        return Icons.balance;
      case 'Улучшение здоровья':
        return Icons.health_and_safety;
      case 'Повышение энергии':
        return Icons.bolt;
      default:
        return Icons.flag;
    }
  }
}

/// Карточка с параметрами диетических ограничений
class RestrictionsParameterCard extends StatelessWidget {
  final List<String> restrictions;
  final bool isActive;
  final VoidCallback? onTap;

  const RestrictionsParameterCard({
    super.key,
    required this.restrictions,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? theme.colorScheme.tertiary : theme.colorScheme.surface;
    final textColor = isActive ? Colors.white : theme.colorScheme.onSurface;
    final displayText = restrictions.isEmpty
        ? 'Без ограничений'
        : restrictions.length == 1
        ? restrictions.first
        : '${restrictions.length} ограничений';

    return ParameterCard(
      title: 'Ограничения',
      value: displayText,
      icon: Icons.restaurant_menu,
      color: color,
      iconColor: textColor,
      onTap: onTap,
    );
  }
}

/// Карточка с параметрами аллергий
class AllergiesParameterCard extends StatelessWidget {
  final List<String> allergies;
  final bool isActive;
  final VoidCallback? onTap;

  const AllergiesParameterCard({
    super.key,
    required this.allergies,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? Colors.orange : theme.colorScheme.surface;
    final textColor = isActive ? Colors.white : theme.colorScheme.onSurface;
    final displayText = allergies.isEmpty
        ? 'Нет аллергий'
        : allergies.length == 1
        ? allergies.first
        : '${allergies.length} аллергий';

    return ParameterCard(
      title: 'Аллергии',
      value: displayText,
      icon: Icons.warning,
      color: color,
      iconColor: textColor,
      onTap: onTap,
    );
  }
}

/// Карточка с параметрами дней
class DaysParameterCard extends StatelessWidget {
  final int days;
  final bool isActive;
  final VoidCallback? onTap;

  const DaysParameterCard({
    super.key,
    required this.days,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? Colors.green : theme.colorScheme.surface;
    final textColor = isActive ? Colors.white : theme.colorScheme.onSurface;

    return ParameterCard(
      title: 'Период',
      value: '$days ${_getDayWord(days)}',
      icon: Icons.calendar_today,
      color: color,
      iconColor: textColor,
      onTap: onTap,
    );
  }

  String _getDayWord(int days) {
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }
}

/// Карточка с макронутриентами
class MacrosParameterCard extends ConsumerWidget {
  final int protein;
  final int carbs;
  final int fat;
  final int calories;

  const MacrosParameterCard({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalGrams = protein + carbs + fat;
    final double proteinPercentage = (protein * 4 * 100 / calories).clamp(0, 100);
    final double carbsPercentage = (carbs * 4 * 100 / calories).clamp(0, 100);
    final double fatPercentage = (fat * 9 * 100 / calories).clamp(0, 100);

    return ParameterCard(
      title: 'Макронутриенты',
      value: '$totalGramsг всего',
      icon: Icons.pie_chart,
      showDivider: false,
      onTap: () {
        _showMacrosDialog(
          context,
          protein: protein,
          carbs: carbs,
          fat: fat,
          calories: calories,
          proteinPercentage: proteinPercentage,
          carbsPercentage: carbsPercentage,
          fatPercentage: fatPercentage,
        );
      },
    );
  }

  void _showMacrosDialog(
      BuildContext context, {
        required int protein,
        required int carbs,
        required int fat,
        required int calories,
        required double proteinPercentage,
        required double carbsPercentage,
        required double fatPercentage,
      }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Распределение макронутриентов'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Прогресс бары
            _buildMacroRow(
              context,
              label: 'Белки',
              value: protein,
              percentage: proteinPercentage,
              color: Colors.blue,
              unit: 'г',
            ),
            const SizedBox(height: 12),
            _buildMacroRow(
              context,
              label: 'Углеводы',
              value: carbs,
              percentage: carbsPercentage,
              color: Colors.green,
              unit: 'г',
            ),
            const SizedBox(height: 12),
            _buildMacroRow(
              context,
              label: 'Жиры',
              value: fat,
              percentage: fatPercentage,
              color: Colors.orange,
              unit: 'г',
            ),
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).dividerColor),
            const SizedBox(height: 12),
            // Итоги
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Всего калорий:'),
                Text(
                  AppFormatters.formatCalories(calories),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Всего грамм:'),
                Text(
                  '${protein + carbs + fat}г',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(
      BuildContext context, {
        required String label,
        required int value,
        required double percentage,
        required Color color,
        required String unit,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$value$unit (${percentage.toStringAsFixed(1)}%)'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}

/// Карточка сводки плана питания
class PlanSummaryCard extends StatelessWidget {
  final MealPlan plan;

  const PlanSummaryCard({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = plan.mealDays.fold(
      0,
          (sum, day) => sum + day.totalCalories,
    ) ~/ plan.days;

    final avgProtein = plan.mealDays.fold(
      0,
          (sum, day) => sum + (day.macros['protein'] ?? 0),
    ) ~/ plan.days;

    // final avgCarbs = plan.mealDays.fold(
    //   0,
    //       (sum, day) => sum + (day.macros['carbs'] ?? 0),
    // ) ~/ plan.days;
    //
    // final avgFat = plan.mealDays.fold(
    //   0,
    //       (sum, day) => sum + (day.macros['fat'] ?? 0),
    // ) ~/ plan.days;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.assignment,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Сводка плана',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Статистика
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Калории в день', '$totalCalories'),
                _buildStatItem(context, 'Белки', '${avgProtein}г'),
                _buildStatItem(context, 'Дней', '${plan.days}'),
              ],
            ),
            const SizedBox(height: 12),
            // Цель
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Цель: ${plan.goal}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (plan.summary.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                plan.summary,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
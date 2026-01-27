import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/meal_plan.dart';

class MealCard extends StatelessWidget {
  final MealPlan plan;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = plan.mealDays.fold(
      0,
          (sum, day) => sum + day.totalCalories,
    ) ~/ plan.days;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      plan.goal,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${plan.days} ${_getDayWord(plan.days)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd MMMM yyyy').format(plan.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStat('Калории', '$totalCalories'),
                  const SizedBox(width: 16),
                  _buildStat('Дней', '${plan.days}'),
                ],
              ),
              if (plan.restrictions.isNotEmpty && plan.restrictions.first != 'Без ограничений')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: plan.restrictions
                        .where((r) => r != 'Без ограничений')
                        .map((restriction) => Chip(
                      label: Text(
                        restriction,
                        style: const TextStyle(fontSize: 10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  String _getDayWord(int days) {
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }
}
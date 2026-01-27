import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/meal_plan.dart';
import '../providers/meal_plan_provider.dart';
import '../widgets/meal_card.dart';
import 'meal_plan_detail_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    await ref.read(mealPlanProvider.notifier).loadSavedPlans();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealPlanProvider);
    final plans = state.savedPlans;

    return Scaffold(
      appBar: AppBar(
        title: const Text('История планов'),
        actions: [
          if (plans.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                _showClearAllDialog();
              },
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'История пуста',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Создайте свой первый план питания',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadPlans,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Dismissible(
              key: Key(plan.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await _showDeleteDialog(plan);
              },
              child: MealCard(
                plan: plan,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MealPlanDetailScreen(plan: plan),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(MealPlan plan) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить план?'),
        content: Text('План от ${DateFormat('dd.MM.yyyy').format(plan.createdAt)} будет удален'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<void> _showClearAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить всю историю?'),
        content: const Text('Все сохраненные планы питания будут удалены'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Очистить'),
          ),
        ],
      ),
    ) ??
        false;

    if (confirmed) {
      // TODO: Implement clear all functionality
    }
  }
}
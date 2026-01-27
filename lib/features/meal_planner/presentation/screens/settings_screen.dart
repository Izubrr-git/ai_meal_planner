import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_keys.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/user_preferencies.dart';
import '../providers/meal_plan_provider.dart';
import 'api_key_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserPreferences _preferences;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await ref.read(mealPlanProvider.notifier).loadPreferences();
    setState(() {
      _preferences = preferences ?? UserPreferences.defaults();
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref.read(mealPlanProvider.notifier).savePreferences(_preferences);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Настройки сохранены'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка сохранения: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _clearApiKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить API ключ?'),
        content: const Text('Текущий API ключ будет удален. Вы сможете ввести новый ключ.'),
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
    ) ?? false;

    if (confirmed && mounted) {
      await ApiKeys.clearKey();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ApiKeyScreen()),
      );
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все данные?'),
        content: const Text('Будут удалены все сохраненные планы и настройки. Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Очистить всё', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref.read(mealPlanProvider.notifier).clearAllData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Все данные очищены'),
              backgroundColor: Colors.green,
            ),
          );

          // Обновляем список планов
          await _loadPreferences();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка очистки: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Основная информация
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Личная информация',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Пол
                      DropdownButtonFormField<String>(
                        value: _preferences.gender ?? 'Мужской',
                        decoration: const InputDecoration(
                          labelText: 'Пол',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Мужской', 'Женский']
                            .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _preferences = _preferences.copyWith(gender: value);
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // Возраст
                      AppTextField(
                        initialValue: _preferences.age?.toString(),
                        hintText: 'Возраст',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final age = int.tryParse(value);
                          if (age != null) {
                            setState(() {
                              _preferences = _preferences.copyWith(age: age);
                            });
                          }
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final age = int.tryParse(value);
                            if (age == null || age < 10 || age > 120) {
                              return 'Введите возраст от 10 до 120';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Вес
                      AppTextField(
                        initialValue: _preferences.weight?.toString(),
                        hintText: 'Вес (кг)',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final weight = double.tryParse(value.replaceAll(',', '.'));
                          if (weight != null) {
                            setState(() {
                              _preferences = _preferences.copyWith(weight: weight);
                            });
                          }
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final weight = double.tryParse(value.replaceAll(',', '.'));
                            if (weight == null || weight < 20 || weight > 300) {
                              return 'Введите вес от 20 до 300 кг';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Рост
                      AppTextField(
                        initialValue: _preferences.height?.toString(),
                        hintText: 'Рост (см)',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final height = double.tryParse(value.replaceAll(',', '.'));
                          if (height != null) {
                            setState(() {
                              _preferences = _preferences.copyWith(height: height);
                            });
                          }
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final height = double.tryParse(value.replaceAll(',', '.'));
                            if (height == null || height < 100 || height > 250) {
                              return 'Введите рост от 100 до 250 см';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Уровень активности
                      DropdownButtonFormField<String>(
                        value: _preferences.activityLevel,
                        decoration: const InputDecoration(
                          labelText: 'Уровень активности',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'Минимальная',
                          'Низкая',
                          'Средняя',
                          'Высокая',
                          'Очень высокая',
                        ]
                            .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _preferences = _preferences.copyWith(activityLevel: value!);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Рекомендуемые калории
              if (_preferences.age != null &&
                  _preferences.weight != null &&
                  _preferences.height != null &&
                  _preferences.gender != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Рекомендуемые калории',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'На основе ваших данных:',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_preferences.calculateRecommendedCalories()} ккал/день',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Для цели: ${_preferences.goal}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Управление данными
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Управление данными',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Кнопка очистки API ключа
                      ListTile(
                        leading: const Icon(Icons.vpn_key, color: Colors.blue),
                        title: const Text('Управление API ключом'),
                        subtitle: const Text('Очистить или изменить OpenAI API ключ'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _clearApiKey,
                      ),

                      // Кнопка очистки всех данных
                      ListTile(
                        leading: const Icon(Icons.delete_forever, color: Colors.red),
                        title: const Text('Очистить все данные'),
                        subtitle: const Text('Удалить все планы и настройки'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _clearAllData,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Сохранить кнопка
              AppButton(
                onPressed: _saveSettings,
                text: 'Сохранить настройки',
                icon: Icons.save,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
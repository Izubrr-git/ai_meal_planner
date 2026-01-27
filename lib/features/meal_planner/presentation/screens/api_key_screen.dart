import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import 'home_screen.dart';

class ApiKeyScreen extends ConsumerStatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  ConsumerState<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends ConsumerState<ApiKeyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _tryAutoDetectKey();
  }

  Future<void> _tryAutoDetectKey() async {
    // Проверяем, может ключ уже сохранен
    final prefs = await SharedPreferences.getInstance();
    final storedKey = prefs.getString('openai_api_key');

    if (storedKey != null && storedKey.isNotEmpty) {
      // Если ключ есть, автоматически используем его
      _apiKeyController.text = storedKey;

      // Немного задержки для лучшего UX
      await Future.delayed(const Duration(milliseconds: 500));

      // Переходим на главный экран
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false, // Удаляем все предыдущие роуты
    );
  }

  Future<void> _saveApiKey() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiKey = _apiKeyController.text.trim();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('openai_api_key', apiKey);

        await Future.delayed(const Duration(milliseconds: 500));

        _navigateToHome();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения ключа: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
        title: const Text('Настройка API ключа'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'AI Meal Planner',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Персональный генератор планов питания',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Divider
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 24),

            // Main content
            Text(
              'Для начала работы нужен OpenAI API ключ',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Приложение использует искусственный интеллект для создания '
                  'персонализированных планов питания.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    controller: _apiKeyController,
                    hintText: 'sk-... (введите ваш OpenAI API ключ)',
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите API ключ';
                      }
                      if (!value.startsWith('sk-')) {
                        return 'API ключ должен начинаться с "sk-"';
                      }
                      if (value.length < 20) {
                        return 'Ключ слишком короткий';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quick action buttons
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: [
                        AppButton(
                          onPressed: _saveApiKey,
                          text: 'Сохранить ключ и начать',
                          icon: Icons.play_arrow,
                          fullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showAdvanced = !_showAdvanced;
                            });
                          },
                          icon: Icon(_showAdvanced
                              ? Icons.expand_less
                              : Icons.expand_more),
                          label: Text(_showAdvanced
                              ? 'Скрыть подробности'
                              : 'Как получить ключ?'),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Advanced section
            if (_showAdvanced)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Инструкция по получению API ключа:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep('1. Перейдите на platform.openai.com'),
                    _buildInstructionStep('2. Войдите или создайте аккаунт'),
                    _buildInstructionStep('3. Нажмите "API Keys" в меню слева'),
                    _buildInstructionStep('4. Нажмите "Create new secret key"'),
                    _buildInstructionStep('5. Скопируйте ключ (начинается с sk-)'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Важная информация:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '• Первые 5 предоставляются бесплатно\n'
                                '• Ключ хранится только на вашем устройстве\n'
                                '• Приложение не отправляет ключ на наши серверы\n'
                                '• Вы можете сменить ключ в любой момент',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      onPressed: () {
                        // Просто показываем сообщение, так как url_launcher не установлен
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Откройте platform.openai.com в браузере'),
                          ),
                        );
                      },
                      text: 'Открыть OpenAI сайт',
                      icon: Icons.open_in_new,
                      variant: ButtonVariant.outlined,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Test mode option (для разработки)
            if (!_showAdvanced)
              TextButton(
                onPressed: () {
                  // Включаем тестовый режим
                  _useTestMode();
                },
                child: const Text(
                  'Использовать тестовый режим (демо-данные)',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _useTestMode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Немного задержки для лучшего UX
      await Future.delayed(const Duration(milliseconds: 500));

      _navigateToHome(); // Используем исправленный метод
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
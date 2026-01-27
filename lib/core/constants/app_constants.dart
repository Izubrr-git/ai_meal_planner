class AppConstants {
  // Goals
  static const List<String> goals = [
    'Похудение',
    'Набор мышечной массы',
    'Поддержание веса',
    'Улучшение здоровья',
    'Повышение энергии',
  ];

  // Dietary restrictions
  static const List<String> dietaryRestrictions = [
    'Без ограничений',
    'Вегетарианство',
    'Веганство',
    'Без глютена',
    'Без лактозы',
    'Низкоуглеводная',
    'Палео',
    'Кето',
  ];

  // Allergies
  static const List<String> allergies = [
    'Нет',
    'Орехи',
    'Молочные продукты',
    'Яйца',
    'Рыба/морепродукты',
    'Соя',
    'Пшеница',
  ];

  // Days options
  static const List<int> daysOptions = [1, 3, 5, 7];

  // Default values
  static const String defaultGoal = 'Поддержание веса';
  static const String defaultRestriction = 'Без ограничений';
  static const String defaultAllergy = 'Нет';
  static const int defaultDays = 3;
  static const int defaultCalories = 2000;

  // API Settings
  static const int apiTimeout = 30000; // 30 seconds
  static const int maxRetries = 3;
  static const String openAIModel = 'gpt-3.5-turbo';
  static const double temperature = 0.7;
  static const int maxTokens = 1500;
}
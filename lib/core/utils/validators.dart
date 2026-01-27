class Validators {
  /// Проверка обязательного поля
  static String? validateRequired(String? value, {String fieldName = 'Поле'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName обязательно для заполнения';
    }
    return null;
  }

  /// Проверка email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Введите корректный email';
    }

    return null;
  }

  /// Проверка пароля
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }

    if (value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }

    return null;
  }

  /// Проверка номера телефона
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер телефона';
    }

    final digits = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length < 10) {
      return 'Введите корректный номер телефона';
    }

    return null;
  }

  /// Проверка калорий
  static String? validateCalories(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Калории не обязательны
    }

    final calories = int.tryParse(value);
    if (calories == null) {
      return 'Введите число';
    }

    if (calories < 500) {
      return 'Минимум 500 калорий';
    }

    if (calories > 10000) {
      return 'Максимум 10000 калорий';
    }

    return null;
  }

  /// Проверка веса
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите вес';
    }

    final weight = double.tryParse(value.replaceAll(',', '.'));
    if (weight == null) {
      return 'Введите число';
    }

    if (weight < 20) {
      return 'Минимум 20 кг';
    }

    if (weight > 300) {
      return 'Максимум 300 кг';
    }

    return null;
  }

  /// Проверка роста
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите рост';
    }

    final height = int.tryParse(value);
    if (height == null) {
      return 'Введите число';
    }

    if (height < 100) {
      return 'Минимум 100 см';
    }

    if (height > 250) {
      return 'Максимум 250 см';
    }

    return null;
  }

  /// Проверка возраста
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите возраст';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Введите число';
    }

    if (age < 10) {
      return 'Минимум 10 лет';
    }

    if (age > 120) {
      return 'Максимум 120 лет';
    }

    return null;
  }

  /// Проверка, что значение является числом
  static String? validateNumber(String? value, {String fieldName = 'Значение'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName обязательно';
    }

    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Введите число';
    }

    return null;
  }

  /// Проверка положительного числа
  static String? validatePositiveNumber(String? value, {String fieldName = 'Значение'}) {
    final error = validateNumber(value, fieldName: fieldName);
    if (error != null) return error;

    final number = double.parse(value!.replaceAll(',', '.'));
    if (number <= 0) {
      return '$fieldName должно быть больше 0';
    }

    return null;
  }

  /// Проверка соответствия паролей
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Подтвердите пароль';
    }

    if (value != password) {
      return 'Пароли не совпадают';
    }

    return null;
  }

  /// Проверка минимальной длины
  static String? validateMinLength(String? value, int minLength, {String fieldName = 'Поле'}) {
    if (value == null || value.length < minLength) {
      return '$fieldName должно содержать минимум $minLength символов';
    }
    return null;
  }

  /// Проверка максимальной длины
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'Поле'}) {
    if (value != null && value.length > maxLength) {
      return '$fieldName должно содержать максимум $maxLength символов';
    }
    return null;
  }

  /// Проверка диапазона длины
  static String? validateLengthRange(String? value, int min, int max, {String fieldName = 'Поле'}) {
    if (value == null) {
      return '$fieldName обязательно';
    }

    if (value.length < min || value.length > max) {
      return '$fieldName должно содержать от $min до $max символов';
    }

    return null;
  }

  /// Проверка URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL не обязателен
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Введите корректный URL';
    }

    return null;
  }

  /// Проверка даты
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Выберите дату';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Введите корректную дату';
    }
  }

  /// Проверка, что дата не в будущем
  static String? validatePastDate(DateTime? date, {String fieldName = 'Дата'}) {
    if (date == null) {
      return 'Выберите $fieldName';
    }

    if (date.isAfter(DateTime.now())) {
      return '$fieldName не может быть в будущем';
    }

    return null;
  }

  /// Проверка, что дата не в прошлом
  static String? validateFutureDate(DateTime? date, {String fieldName = 'Дата'}) {
    if (date == null) {
      return 'Выберите $fieldName';
    }

    if (date.isBefore(DateTime.now())) {
      return '$fieldName не может быть в прошлом';
    }

    return null;
  }

  /// Комплексная проверка нескольких валидаторов
  static String? validateMultiple(List<String? Function()> validators) {
    for (final validator in validators) {
      final error = validator();
      if (error != null) return error;
    }
    return null;
  }
}
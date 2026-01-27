import 'dart:math';

import 'package:intl/intl.dart';

import 'extensions.dart';

class AppFormatters {
  /// Форматирование даты
  static String formatDate(DateTime? date, [String pattern = 'dd.MM.yyyy']) {
    if (date == null) return '';
    return DateFormat(pattern, 'ru_RU').format(date);
  }

  /// Форматирование даты и времени
  static String formatDateTime(DateTime? date, [String pattern = 'dd.MM.yyyy HH:mm']) {
    if (date == null) return '';
    return DateFormat(pattern, 'ru_RU').format(date);
  }

  /// Форматирование времени
  static String formatTime(DateTime? date, [String pattern = 'HH:mm']) {
    if (date == null) return '';
    return DateFormat(pattern, 'ru_RU').format(date);
  }

  /// Форматирование числа с разделителями
  static String formatNumber(num? number) {
    if (number == null) return '0';
    return NumberFormat('#,###', 'ru_RU').format(number);
  }

  /// Форматирование калорий
  static String formatCalories(num? calories) {
    if (calories == null) return '0 ккал';
    return '${formatNumber(calories)} ккал';
  }

  /// Форматирование макронутриентов
  static String formatMacros(num? grams) {
    if (grams == null) return '0г';
    return '${formatNumber(grams)}г';
  }

  /// Форматирование процентов
  static String formatPercentage(double? value, [int decimalDigits = 1]) {
    if (value == null) return '0%';
    final formatter = NumberFormat('#,###.##%', 'ru_RU');
    formatter.minimumFractionDigits = decimalDigits;
    formatter.maximumFractionDigits = decimalDigits;
    return formatter.format(value / 100);
  }

  /// Форматирование веса
  static String formatWeight(num? weight) {
    if (weight == null) return '0 кг';
    return '${formatNumber(weight)} кг';
  }

  /// Форматирование денег
  static String formatMoney(num? amount, [String currency = '₽']) {
    if (amount == null) return '0 $currency';
    return '${formatNumber(amount)} $currency';
  }

  /// Форматирование времени приготовления
  static String formatCookingTime(int? minutes) {
    if (minutes == null) return '0 мин';
    if (minutes < 60) return '$minutes мин';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours ${_pluralize(hours, 'час', 'часа', 'часов')}';
    }

    return '$hours ${_pluralize(hours, 'час', 'часа', 'часов')} $remainingMinutes мин';
  }

  /// Форматирование размера порции
  static String formatServingSize(int? size) {
    if (size == null) return '1 порция';
    return '$size ${_pluralize(size, 'порция', 'порции', 'порций')}';
  }

  /// Склонение слов для русского языка
  static String _pluralize(int number, String one, String two, String five) {
    final n = number.abs();
    if (n % 10 == 1 && n % 100 != 11) return one;
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return two;
    return five;
  }

  /// Форматирование относительного времени
  static String formatRelativeTime(DateTime date) {
    return date.toRelativeTime();
  }

  /// Форматирование номера телефона
  static String formatPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length == 11) {
      return '+7 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7, 9)}-${digits.substring(9)}';
    } else if (digits.length == 10) {
      return '+7 (${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 8)}-${digits.substring(8)}';
    }

    return phone;
  }

  /// Форматирование имени файла
  static String formatFileName(String fileName, [int maxLength = 30]) {
    if (fileName.length <= maxLength) return fileName;

    final extensionIndex = fileName.lastIndexOf('.');
    if (extensionIndex == -1) return StringExtensions(fileName).truncate(maxLength);

    final name = fileName.substring(0, extensionIndex);
    final extension = fileName.substring(extensionIndex);

    if (name.length <= maxLength - 3) return fileName;

    return '${StringExtensions(name).truncate(maxLength - extension.length - 3)}...$extension';
  }

  /// Форматирование байтов в читаемый вид
  static String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();

    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}

// Вспомогательные функции
extension StringFormatting on String {
  /// Обрезает строку
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
import 'package:flutter/material.dart';

/// Виджет для отображения загрузки поверх контента
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color barrierColor;
  final Color spinnerColor;
  final double spinnerSize;
  final bool dismissible;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
    this.barrierColor = Colors.black54,
    this.spinnerColor = Colors.white,
    this.spinnerSize = 40.0,
    this.dismissible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Основной контент
        child,

        // Загрузочный оверлей
        if (isLoading)
          Positioned.fill(
            child: ModalBarrier(
              color: barrierColor,
              dismissible: dismissible,
            ),
          ),

        // Индикатор загрузки
        if (isLoading)
          Center(
            child: _buildLoadingContent(context),
          ),
      ],
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Спиннер
          SizedBox(
            width: spinnerSize,
            height: spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // Сообщение
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Альтернативный вариант с полупрозрачным фоном
class TransparentLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? backgroundColor;

  const TransparentLoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: backgroundColor ?? Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Виджет с кнопкой отмены
class CancelableLoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final String message;
  final VoidCallback? onCancel;
  final String cancelText;

  const CancelableLoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    required this.message,
    this.onCancel,
    this.cancelText = 'Отмена',
  }) : super(key: key);

  @override
  State<CancelableLoadingOverlay> createState() =>
      _CancelableLoadingOverlayState();
}

class _CancelableLoadingOverlayState extends State<CancelableLoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          Positioned.fill(
            child: ModalBarrier(
              color: Colors.black54,
              dismissible: false,
            ),
          ),
        if (widget.isLoading)
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Спиннер
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Сообщение
                  Text(
                    widget.message,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Кнопка отмены
                  if (widget.onCancel != null)
                    ElevatedButton(
                      onPressed: widget.onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(widget.cancelText),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Видет для линейной загрузки
class LinearLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double? value;
  final String? message;
  final Color backgroundColor;
  final Color progressColor;

  const LinearLoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.value,
    this.message,
    this.backgroundColor = Colors.black54,
    this.progressColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Прогресс бар
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  // Сообщение
                  if (message != null && message!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        message!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Хелпер для показа загрузки в диалоге
class LoadingDialog {
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
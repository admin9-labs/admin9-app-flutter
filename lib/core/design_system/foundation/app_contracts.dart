import 'package:flutter/widgets.dart';

enum AppPlatform { android, ios }

enum AppButtonVariant { primary, secondary, tertiary, destructive }

enum AppTone { info, success, warning, error }

enum AppDialogVariant { information, confirmation, destructive }

enum AppProgressKind { circular, linear }

enum AppPageNavigationMode { root, child }

enum AppIconRole {
  back,
  close,
  chevronForward,
  home,
  homeSelected,
  account,
  accountSelected,
  settings,
  search,
  info,
  warning,
  success,
  error,
  visibility,
  visibilityOff,
  more,
}

typedef AppValueChanged<T extends Object> = void Function(T value);

@immutable
final class AppPageAction {
  const AppPageAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.key,
    this.enabled = true,
  });

  final Key? key;
  final String label;
  final AppIconRole icon;
  final VoidCallback onPressed;
  final bool enabled;
}

@immutable
final class AppNavigationDestination {
  const AppNavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final AppIconRole icon;
  final AppIconRole selectedIcon;
}

@immutable
final class AppSelectOption<T extends Object> {
  const AppSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

@immutable
final class AppChoice<T extends Object> {
  const AppChoice({required this.value, required this.label});

  final T value;
  final String label;
}

@immutable
final class AppActionMenuItem<T extends Object> {
  const AppActionMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.destructive = false,
    this.enabled = true,
  });

  final T value;
  final String label;
  final AppIconRole? icon;
  final bool destructive;
  final bool enabled;
}

@immutable
final class AppFeedbackRequest {
  const AppFeedbackRequest({
    required this.message,
    required this.tone,
    this.actionLabel,
    this.onAction,
  }) : assert((actionLabel == null) == (onAction == null)),
       assert(actionLabel == null || actionLabel != '');

  final String message;
  final AppTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;
}

abstract interface class AppFeedbackController {
  void show(AppFeedbackRequest request);

  void dismiss();
}

abstract interface class AppInteractionController {
  Future<void> showInformation({
    required String title,
    required String message,
  });

  Future<bool> showConfirmation({
    required String title,
    required String message,
    required String confirmLabel,
  });

  Future<bool> showDestructive({
    required String title,
    required String message,
    required String confirmLabel,
  });

  Future<T?> showActionMenu<T extends Object>({
    String? title,
    required List<AppActionMenuItem<T>> items,
    String cancelLabel = '取消',
  });
}

typedef AppInteractionControllerOf =
    AppInteractionController Function(BuildContext context);

class AppFeedbackHost extends InheritedWidget {
  const AppFeedbackHost({
    super.key,
    required this.controller,
    required super.child,
  });

  final AppFeedbackController controller;

  static AppFeedbackController of(BuildContext context) {
    final host = context.dependOnInheritedWidgetOfExactType<AppFeedbackHost>();
    if (host == null) {
      throw FlutterError('No AppFeedbackHost found in context.');
    }
    return host.controller;
  }

  @override
  bool updateShouldNotify(AppFeedbackHost oldWidget) =>
      !identical(controller, oldWidget.controller);
}

class AppInteractionHost extends InheritedWidget {
  const AppInteractionHost({
    super.key,
    required this.controller,
    required super.child,
  });

  final AppInteractionController controller;

  static AppInteractionController of(BuildContext context) {
    final host = context
        .dependOnInheritedWidgetOfExactType<AppInteractionHost>();
    if (host == null) {
      throw FlutterError('No AppInteractionHost found in context.');
    }
    return host.controller;
  }

  @override
  bool updateShouldNotify(AppInteractionHost oldWidget) =>
      !identical(controller, oldWidget.controller);
}

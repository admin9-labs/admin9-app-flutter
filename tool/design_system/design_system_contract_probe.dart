// Non-exported declaration probe for Admin9 Design System v1.0.
//
// These abstract widgets and immutable value objects verify that the frozen
// contracts are expressible on Flutter 3.44.1 / Dart 3.12.1. They contain no
// runtime implementation and are not imported by lib/ or the public barrel.

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

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

abstract class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.body,
    required this.navigationMode,
    this.actions = const <AppPageAction>[],
    this.parentLabel,
    this.scrollable = true,
  }) : assert(
         (navigationMode == AppPageNavigationMode.root &&
                 parentLabel == null) ||
             (navigationMode == AppPageNavigationMode.child &&
                 parentLabel != null &&
                 parentLabel != ''),
       );

  final String title;
  final Widget body;
  final AppPageNavigationMode navigationMode;
  final List<AppPageAction> actions;
  final String? parentLabel;
  final bool scrollable;
}

abstract class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<AppNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
}

abstract class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final AppButtonVariant variant;
  final AppIconRole? icon;
  final bool enabled;
  final bool loading;
}

abstract class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.validator,
    this.forceErrorText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.enabled = true,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String label;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final String? forceErrorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool showObscureToggle;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final AppIconRole? prefixIcon;
}

abstract class AppSelect<T extends Object> extends StatelessWidget {
  const AppSelect({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.enabled = true,
    this.validator,
    this.forceErrorText,
  });

  final String label;
  final T? value;
  final List<AppSelectOption<T>> options;
  final AppValueChanged<T> onChanged;
  final bool enabled;
  final FormFieldValidator<T>? validator;
  final String? forceErrorText;
}

abstract class AppSegmentedControl<T extends Object> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  final T value;
  final List<AppChoice<T>> options;
  final AppValueChanged<T> onChanged;
  final bool enabled;
}

abstract class AppSingleChoiceList<T extends Object> extends StatelessWidget {
  const AppSingleChoiceList({
    super.key,
    required this.title,
    required this.value,
    required this.choices,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final T value;
  final List<AppChoice<T>> choices;
  final AppValueChanged<T> onChanged;
  final bool enabled;
}

abstract class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
}

abstract class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.currentValue,
    this.onTap,
    this.enabled = true,
    this.selected = false,
    this.disclosure = false,
  });

  final String title;
  final String? subtitle;
  final AppIconRole? leadingIcon;
  final String? currentValue;
  final VoidCallback? onTap;
  final bool enabled;
  final bool selected;
  final bool disclosure;
}

abstract class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.children,
    this.title,
    this.footer,
  });

  final String? title;
  final String? footer;
  final List<Widget> children;
}

abstract class AppNotice extends StatelessWidget {
  const AppNotice({
    super.key,
    required this.tone,
    required this.message,
    this.title,
    this.actionLabel,
    this.onAction,
  }) : assert((actionLabel == null) == (onAction == null)),
       assert(actionLabel == null || actionLabel != '');

  final AppTone tone;
  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
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

abstract class AppFeedback extends StatelessWidget {
  const AppFeedback({super.key, required this.controller, required this.child});

  final AppFeedbackController controller;
  final Widget child;
}

abstract class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.variant,
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.cancelLabel,
  }) : assert(confirmLabel != ''),
       assert(
         (variant == AppDialogVariant.information && cancelLabel == null) ||
             (variant != AppDialogVariant.information &&
                 cancelLabel != null &&
                 cancelLabel != ''),
       );

  final AppDialogVariant variant;
  final String title;
  final Widget body;
  final String confirmLabel;
  final String? cancelLabel;
}

abstract class AppActionMenu<T extends Object> extends StatelessWidget {
  const AppActionMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.title,
    this.cancelLabel = '取消',
  });

  final String? title;
  final List<AppActionMenuItem<T>> items;
  final AppValueChanged<T> onSelected;
  final String cancelLabel;
}

abstract class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({
    super.key,
    required this.label,
    this.kind = AppProgressKind.circular,
    this.value,
  }) : assert(value == null || (value >= 0 && value <= 1));

  final String label;
  final AppProgressKind kind;
  final double? value;
}

abstract interface class AppDesignTokens {
  Color get background;
  Color get onBackground;
  Color get primary;
  Color get onPrimary;
  Color get secondary;
  Color get onSecondary;
  Color get surface;
  Color get onSurface;
  Color get surfaceContainer;
  Color get onSurfaceContainer;
  Color get outline;
  Color get danger;
  Color get onDanger;
  Color get warning;
  Color get onWarning;
  Color get info;
  Color get onInfo;
  Color get success;
  Color get onSuccess;
  Color get disabledText;
  Color get disabledContainer;
  Color get focus;
  double get space4;
  double get space8;
  double get space12;
  double get space16;
  double get space24;
  double get space32;
  double get space48;
  double get fieldRadius;
  double get controlRadius;
  TextStyle get displayTextStyle;
  TextStyle get pageTitleTextStyle;
  TextStyle get sectionTitleTextStyle;
  TextStyle get bodyTextStyle;
  TextStyle get supportingTextStyle;
  TextStyle get labelTextStyle;
  TextStyle get captionTextStyle;
  Duration get instantMotion;
  Duration get stateMotion;
  Duration get enterMotion;
  Duration get exitMotion;
}

@immutable
final class AppPlatformIconPair {
  const AppPlatformIconPair({required this.material, required this.cupertino});

  final IconData material;
  final IconData cupertino;
}

const appPlatformIconContract = <AppIconRole, AppPlatformIconPair>{
  AppIconRole.back: AppPlatformIconPair(
    material: Icons.arrow_back,
    cupertino: CupertinoIcons.back,
  ),
  AppIconRole.close: AppPlatformIconPair(
    material: Icons.close,
    cupertino: CupertinoIcons.clear,
  ),
  AppIconRole.chevronForward: AppPlatformIconPair(
    material: Icons.chevron_right,
    cupertino: CupertinoIcons.chevron_forward,
  ),
  AppIconRole.home: AppPlatformIconPair(
    material: Icons.home_outlined,
    cupertino: CupertinoIcons.house,
  ),
  AppIconRole.homeSelected: AppPlatformIconPair(
    material: Icons.home,
    cupertino: CupertinoIcons.house_fill,
  ),
  AppIconRole.account: AppPlatformIconPair(
    material: Icons.person_outline,
    cupertino: CupertinoIcons.person,
  ),
  AppIconRole.accountSelected: AppPlatformIconPair(
    material: Icons.person,
    cupertino: CupertinoIcons.person_fill,
  ),
  AppIconRole.settings: AppPlatformIconPair(
    material: Icons.settings_outlined,
    cupertino: CupertinoIcons.gear,
  ),
  AppIconRole.search: AppPlatformIconPair(
    material: Icons.search,
    cupertino: CupertinoIcons.search,
  ),
  AppIconRole.info: AppPlatformIconPair(
    material: Icons.info_outline,
    cupertino: CupertinoIcons.info,
  ),
  AppIconRole.warning: AppPlatformIconPair(
    material: Icons.warning_amber_outlined,
    cupertino: CupertinoIcons.exclamationmark_triangle,
  ),
  AppIconRole.success: AppPlatformIconPair(
    material: Icons.check_circle_outline,
    cupertino: CupertinoIcons.check_mark_circled,
  ),
  AppIconRole.error: AppPlatformIconPair(
    material: Icons.error_outline,
    cupertino: CupertinoIcons.exclamationmark_circle,
  ),
  AppIconRole.visibility: AppPlatformIconPair(
    material: Icons.visibility,
    cupertino: CupertinoIcons.eye,
  ),
  AppIconRole.visibilityOff: AppPlatformIconPair(
    material: Icons.visibility_off,
    cupertino: CupertinoIcons.eye_slash,
  ),
  AppIconRole.more: AppPlatformIconPair(
    material: Icons.more_horiz,
    cupertino: CupertinoIcons.ellipsis,
  ),
};

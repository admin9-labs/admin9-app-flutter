import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart' as forui;

import '../../foundation/app_contracts.dart';
import '../../foundation/app_design_tokens.dart';

class ForuiCandidateScope extends StatelessWidget {
  const ForuiCandidateScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    final platform = Theme.of(context).platform;
    final media = MediaQuery.of(context);
    final data = _theme(tokens);
    return Localizations.override(
      context: context,
      delegates: forui.FLocalizations.localizationsDelegates,
      child: forui.FTheme(
        data: data,
        motion: forui.FThemeMotion(duration: tokens.stateMotion),
        platform: platform == TargetPlatform.iOS
            ? forui.FPlatformVariant.iOS
            : forui.FPlatformVariant.android,
        accessibility: forui.FAccessibility(
          accessibleNavigation: media.accessibleNavigation,
          motion: media.disableAnimations
              ? forui.FAccessibilityMotion.disabled
              : forui.FAccessibilityMotion.all,
          focusHighlight: true,
        ),
        child: child,
      ),
    );
  }

  forui.FThemeData _theme(AppDesignTokens tokens) {
    final dark =
        ThemeData.estimateBrightnessForColor(tokens.background) ==
        Brightness.dark;
    final colors =
        (dark ? forui.FColors.neutralDark : forui.FColors.neutralLight)
            .copyWith(
              brightness: dark ? Brightness.dark : Brightness.light,
              systemOverlayStyle: dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
              background: tokens.background,
              foreground: tokens.onBackground,
              primary: tokens.primary,
              primaryForeground: tokens.onPrimary,
              secondary: tokens.surfaceContainer,
              secondaryForeground: tokens.onSurfaceContainer,
              muted: tokens.disabledContainer,
              mutedForeground: tokens.disabledText,
              destructive: tokens.danger,
              destructiveForeground: tokens.onDanger,
              error: tokens.danger,
              errorForeground: tokens.onDanger,
              card: tokens.surface,
              border: tokens.outline,
            );
    final typeface = _systemTypeface(tokens);
    return forui.FThemeData(
      debugLabel: 'Admin9 G2 Forui candidate',
      colors: colors,
      touch: true,
      typography: forui.FTypography(display: typeface, body: typeface),
    );
  }

  forui.FTypeface _systemTypeface(AppDesignTokens tokens) {
    TextStyle style(TextStyle source, double size) => source.copyWith(
      fontFamily: null,
      fontFamilyFallback: null,
      fontSize: size,
      leadingDistribution: TextLeadingDistribution.even,
    );

    return forui.FTypeface(
      fontFamily: '_Admin9SystemFont',
      xs3: style(tokens.captionTextStyle, 10),
      xs2: style(tokens.captionTextStyle, 12),
      xs: style(tokens.captionTextStyle, 13),
      sm: style(tokens.supportingTextStyle, 14),
      md: style(tokens.bodyTextStyle, 16),
      lg: style(tokens.sectionTitleTextStyle, 18),
      xl: style(tokens.pageTitleTextStyle, 20),
      xl2: style(tokens.pageTitleTextStyle, 24),
      xl3: style(tokens.displayTextStyle, 30),
      xl4: style(tokens.displayTextStyle, 36),
      xl5: style(tokens.displayTextStyle, 48),
      xl6: style(tokens.displayTextStyle, 60),
      xl7: style(tokens.displayTextStyle, 72),
      xl8: style(tokens.displayTextStyle, 96),
    );
  }
}

class ForuiCandidateButton extends StatelessWidget {
  const ForuiCandidateButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final AppButtonVariant variant;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final callback = enabled && !loading ? onPressed : null;
    return Semantics(
      button: true,
      enabled: callback != null,
      label: label,
      value: loading ? '加载中' : null,
      liveRegion: loading,
      onTap: callback,
      child: ExcludeSemantics(
        child: forui.FButton(
          variant: switch (variant) {
            AppButtonVariant.primary => forui.FButtonVariant.primary,
            AppButtonVariant.secondary => forui.FButtonVariant.outline,
            AppButtonVariant.tertiary => forui.FButtonVariant.ghost,
            AppButtonVariant.destructive => forui.FButtonVariant.destructive,
          },
          size: forui.FButtonSizeVariant.lg,
          onPress: callback,
          child: loading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label),
        ),
      ),
    );
  }
}

class ForuiCandidateTextField extends StatelessWidget {
  const ForuiCandidateTextField({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FocusNode? focusNode;
  final String? errorText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => forui.FTextField(
    control: forui.FTextFieldControl.managed(
      controller: controller,
      onChange: (value) => onChanged?.call(value.text),
    ),
    label: Text(label),
    error: errorText == null ? null : Text(errorText!),
    focusNode: focusNode,
    enabled: enabled,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    autofillHints: autofillHints,
    onSubmit: onSubmitted,
  );
}

class ForuiCandidateSwitch extends StatelessWidget {
  const ForuiCandidateSwitch({
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

  @override
  Widget build(BuildContext context) => forui.FSwitch(
    leadingLabel: true,
    semanticsLabel: label,
    label: Text(label),
    value: value,
    enabled: enabled,
    onChange: enabled ? onChanged : null,
  );
}

class ForuiCandidateTile extends StatelessWidget {
  const ForuiCandidateTile({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.onPressed,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final pressured =
        MediaQuery.sizeOf(context).width < 390 ||
        MediaQuery.textScalerOf(context).scale(16) > 24 ||
        title.runes.length > 12 ||
        (subtitle?.runes.length ?? 0) > 12 ||
        (value?.runes.length ?? 0) > 12;
    final supporting = [?subtitle, if (pressured) ?value].join('\n');
    return forui.FTile(
      semanticsLabel: [title, if (value != null) value].join('，'),
      title: Text(title),
      subtitle: supporting.isEmpty ? null : Text(supporting),
      details: pressured || value == null ? null : Text(value!),
      suffix: onPressed == null ? null : const Icon(Icons.chevron_right),
      enabled: enabled,
      onPress: enabled ? onPressed : null,
    );
  }
}

class ForuiCandidateFeedback extends StatelessWidget {
  const ForuiCandidateFeedback({
    super.key,
    required this.title,
    required this.message,
    required this.tone,
  });

  final String title;
  final String message;
  final AppTone tone;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: tone == AppTone.error,
    label: '${_toneLabel(tone)}，$title，$message',
    child: ExcludeSemantics(
      child: forui.FAlert(
        title: Text(title),
        subtitle: Text(message),
        variant: tone == AppTone.error
            ? forui.FAlertVariant.destructive
            : forui.FAlertVariant.primary,
        liveRegion: false,
      ),
    ),
  );

  String _toneLabel(AppTone value) => switch (value) {
    AppTone.info => '信息',
    AppTone.success => '成功',
    AppTone.warning => '警告',
    AppTone.error => '错误',
  };
}

class ForuiCandidateProgress extends StatelessWidget {
  const ForuiCandidateProgress({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    value: '${(value * 100).round()}%',
    liveRegion: true,
    child: ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label),
          const SizedBox(height: 8),
          forui.FDeterminateProgress(value: value),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';

import '../foundation/app_contracts.dart';
import '../foundation/app_design_tokens.dart';

class G2FirstPartyButton extends StatelessWidget {
  const G2FirstPartyButton({
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
    final tokens = AppDesignScope.of(context);
    final callback = enabled && !loading ? onPressed : null;
    final foreground = switch (variant) {
      AppButtonVariant.primary => tokens.onPrimary,
      AppButtonVariant.destructive => tokens.onDanger,
      _ => tokens.primary,
    };
    final background = switch (variant) {
      AppButtonVariant.primary => tokens.primary,
      AppButtonVariant.destructive => tokens.danger,
      _ => Colors.transparent,
    };
    return Semantics(
      button: true,
      enabled: callback != null,
      label: label,
      value: loading ? '加载中' : null,
      liveRegion: loading,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 48,
          child: FilledButton(
            style: FilledButton.styleFrom(
              foregroundColor: foreground,
              backgroundColor: background,
              disabledBackgroundColor: tokens.disabledContainer,
              disabledForegroundColor: tokens.disabledText,
              side: variant == AppButtonVariant.secondary
                  ? BorderSide(color: tokens.outline)
                  : BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.controlRadius),
              ),
            ),
            onPressed: callback,
            child: loading
                ? SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }
}

class G2FirstPartyTextField extends StatelessWidget {
  const G2FirstPartyTextField({
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
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    enabled: enabled,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    autofillHints: autofillHints,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    decoration: InputDecoration(
      labelText: label,
      errorText: errorText,
      errorMaxLines: 4,
      floatingLabelBehavior: FloatingLabelBehavior.always,
    ),
  );
}

class G2FirstPartySwitch extends StatelessWidget {
  const G2FirstPartySwitch({
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
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: label,
    toggled: value,
    enabled: enabled,
    child: ExcludeSemantics(
      child: SwitchListTile(
        title: Text(label),
        value: value,
        onChanged: enabled ? onChanged : null,
        contentPadding: EdgeInsets.zero,
      ),
    ),
  );
}

class G2FirstPartyTile extends StatelessWidget {
  const G2FirstPartyTile({
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
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value != null) Text(value!),
        if (onPressed != null) const Icon(Icons.chevron_right),
      ],
    ),
    enabled: enabled,
    onTap: enabled ? onPressed : null,
  );
}

class G2FirstPartyFeedback extends StatelessWidget {
  const G2FirstPartyFeedback({
    super.key,
    required this.title,
    required this.message,
    required this.tone,
  });

  final String title;
  final String message;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    final color = tone == AppTone.error ? tokens.danger : tokens.info;
    return Semantics(
      container: true,
      liveRegion: tone == AppTone.error,
      label: '${_toneLabel(tone)}，$title，$message',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.surface,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(tokens.controlRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: tokens.sectionTitleTextStyle),
                      const SizedBox(height: 4),
                      Text(message),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _toneLabel(AppTone value) => switch (value) {
    AppTone.info => '信息',
    AppTone.success => '成功',
    AppTone.warning => '警告',
    AppTone.error => '错误',
  };
}

class G2FirstPartyProgress extends StatelessWidget {
  const G2FirstPartyProgress({
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
          LinearProgressIndicator(value: value),
        ],
      ),
    ),
  );
}

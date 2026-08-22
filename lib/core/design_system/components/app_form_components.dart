import 'package:flutter/material.dart';

import '../foundation/app_contracts.dart';
import '../foundation/app_design_tokens.dart';
import 'app_icon.dart';

class AppButton extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    final callback = enabled && !loading ? onPressed : null;
    final foreground = switch (variant) {
      AppButtonVariant.primary => tokens.onPrimary,
      AppButtonVariant.destructive => tokens.onDanger,
      _ => tokens.primary,
    };
    final content = _ButtonContent(
      label: label,
      icon: icon,
      loading: loading,
      progressColor: foreground,
    );

    return Semantics(
      button: true,
      enabled: callback != null,
      label: label,
      value: loading ? '加载中' : null,
      liveRegion: loading,
      onTap: callback,
      child: ExcludeSemantics(
        child: _button(tokens, foreground, callback, content),
      ),
    );
  }

  Widget _button(
    AppDesignTokens tokens,
    Color foreground,
    VoidCallback? callback,
    Widget child,
  ) {
    final baseStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.controlRadius),
        ),
      ),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (!states.contains(WidgetState.pressed)) return null;
        return foreground.withValues(alpha: 0.16);
      }),
    );
    return switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: callback,
        style: baseStyle,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: callback,
        style: baseStyle,
        child: child,
      ),
      AppButtonVariant.tertiary => TextButton(
        onPressed: callback,
        style: baseStyle,
        child: child,
      ),
      AppButtonVariant.destructive => FilledButton(
        onPressed: callback,
        style: baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? tokens.disabledContainer
                : tokens.danger,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? tokens.disabledText
                : tokens.onDanger,
          ),
        ),
        child: child,
      ),
    };
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.loading,
    required this.progressColor,
  });

  final String label;
  final AppIconRole? icon;
  final bool loading;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    final inheritedText = DefaultTextStyle.of(context);
    final labelContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(resolveAppIcon(icon!, Theme.of(context).platform), size: 20),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: DefaultTextStyle(
            style: inheritedText.style,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.visible,
            maxLines: null,
            child: Text(
              label,
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ],
    );
    if (!loading) return labelContent;
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: 0, child: labelContent),
        SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: progressColor,
          ),
        ),
      ],
    );
  }
}

class AppTextField extends StatefulWidget {
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

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final GlobalKey<FormFieldState<String>> _fieldKey = GlobalKey();
  late bool _obscured;
  late String _lastControllerText;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _lastControllerText = widget.controller.text;
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      _lastControllerText = widget.controller.text;
      widget.controller.addListener(_handleControllerChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fieldKey.currentState?.didChange(widget.controller.text);
      });
    }
    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    final value = widget.controller.text;
    if (_lastControllerText == value) return;
    _lastControllerText = value;
    _fieldKey.currentState?.didChange(value);
  }

  void _handleChanged(String value, FormFieldState<String> field) {
    _lastControllerText = value;
    if (field.value != value) field.didChange(value);
    widget.onChanged?.call(value);
  }

  void _toggleObscured() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    return FormField<String>(
      key: _fieldKey,
      initialValue: widget.controller.text,
      validator: widget.validator,
      forceErrorText: widget.forceErrorText,
      enabled: widget.enabled,
      builder: (field) {
        final errorText = field.errorText;
        final labelFontSize = tokens.labelTextStyle.fontSize ?? 14;
        final usesExternalLabel =
            MediaQuery.textScalerOf(context).scale(labelFontSize) > 24 ||
            widget.label.runes.length > 12;
        final textField = TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          obscureText: _obscured,
          enabled: widget.enabled,
          onChanged: (value) => _handleChanged(value, field),
          onSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            labelText: usesExternalLabel ? null : widget.label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            error: errorText == null ? null : const SizedBox.shrink(),
            prefixIcon: _prefix(context),
            suffixIcon: _visibilityToggle(context),
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (usesExternalLabel) ...[
              ExcludeSemantics(
                child: Text(
                  widget.label,
                  maxLines: null,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: tokens.labelTextStyle,
                ),
              ),
              SizedBox(height: tokens.space8),
            ],
            if (usesExternalLabel)
              Semantics(label: widget.label, child: textField)
            else
              textField,
            if (errorText != null) ...[
              SizedBox(height: tokens.space4),
              Semantics(
                container: true,
                liveRegion:
                    widget.focusNode == null || widget.focusNode!.hasFocus,
                label: errorText,
                child: ExcludeSemantics(
                  child: Text(
                    errorText,
                    style: tokens.captionTextStyle.copyWith(
                      color: tokens.danger,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget? _prefix(BuildContext context) {
    final role = widget.prefixIcon;
    if (role == null) return null;
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
        child: Icon(resolveAppIcon(role, Theme.of(context).platform), size: 20),
      ),
    );
  }

  Widget? _visibilityToggle(BuildContext context) {
    if (!widget.showObscureToggle) return null;
    final label = _obscured ? '显示密码' : '隐藏密码';
    final iconRole = _obscured
        ? AppIconRole.visibility
        : AppIconRole.visibilityOff;
    final icon = Icon(
      resolveAppIcon(iconRole, Theme.of(context).platform),
      size: 20,
    );
    return IconButton(
      tooltip: label,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      onPressed: widget.enabled ? _toggleObscured : null,
      icon: icon,
    );
  }
}

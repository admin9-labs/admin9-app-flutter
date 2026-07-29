import 'package:flutter/cupertino.dart';
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
    final platform = Theme.of(context).platform;
    final tokens = AppDesignScope.of(context);
    final callback = enabled && !loading ? onPressed : null;
    final content = _ButtonContent(
      label: label,
      icon: icon,
      loading: loading,
      platform: platform,
      progressColor: _progressColor(tokens),
    );
    final button = platform == TargetPlatform.iOS
        ? _cupertinoButton(tokens, callback, content)
        : _materialButton(tokens, callback, content);

    return Semantics(
      button: true,
      enabled: callback != null,
      label: label,
      value: loading ? '加载中' : null,
      liveRegion: loading,
      onTap: callback,
      child: ExcludeSemantics(child: button),
    );
  }

  Color _progressColor(AppDesignTokens tokens) => switch (variant) {
    AppButtonVariant.primary => tokens.onPrimary,
    AppButtonVariant.destructive => tokens.onDanger,
    AppButtonVariant.secondary || AppButtonVariant.tertiary => tokens.primary,
  };

  Widget _materialButton(
    AppDesignTokens tokens,
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

  Widget _cupertinoButton(
    AppDesignTokens tokens,
    VoidCallback? callback,
    Widget child,
  ) {
    final common = (
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      borderRadius: BorderRadius.circular(tokens.controlRadius),
    );
    return switch (variant) {
      AppButtonVariant.primary => CupertinoButton.filled(
        minimumSize: common.minimumSize,
        padding: common.padding,
        borderRadius: common.borderRadius,
        color: tokens.primary,
        disabledColor: tokens.disabledContainer,
        foregroundColor: tokens.onPrimary,
        onPressed: callback,
        child: child,
      ),
      AppButtonVariant.secondary => CupertinoButton.tinted(
        minimumSize: common.minimumSize,
        padding: common.padding,
        borderRadius: common.borderRadius,
        color: tokens.primary,
        disabledColor: tokens.disabledContainer,
        foregroundColor: tokens.primary,
        onPressed: callback,
        child: child,
      ),
      AppButtonVariant.tertiary => CupertinoButton(
        minimumSize: common.minimumSize,
        padding: common.padding,
        borderRadius: common.borderRadius,
        foregroundColor: tokens.primary,
        onPressed: callback,
        child: child,
      ),
      AppButtonVariant.destructive => CupertinoButton(
        minimumSize: common.minimumSize,
        padding: common.padding,
        borderRadius: common.borderRadius,
        color: tokens.danger,
        disabledColor: tokens.disabledContainer,
        foregroundColor: tokens.onDanger,
        onPressed: callback,
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
    required this.platform,
    required this.progressColor,
  });

  final String label;
  final AppIconRole? icon;
  final bool loading;
  final TargetPlatform platform;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    final inheritedText = DefaultTextStyle.of(context);
    final labelContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(resolveAppIcon(icon!, platform), size: 20),
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
          child: platform == TargetPlatform.iOS
              ? CupertinoActivityIndicator(color: progressColor)
              : CircularProgressIndicator(strokeWidth: 2, color: progressColor),
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
  final GlobalKey<FormFieldState<String>> _cupertinoFieldKey = GlobalKey();
  late bool _obscured;
  late String _lastControllerText;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _lastControllerText = widget.controller.text;
    widget.controller.addListener(_handleControllerChanged);
    widget.focusNode?.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      _lastControllerText = widget.controller.text;
      widget.controller.addListener(_handleControllerChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _cupertinoFieldKey.currentState?.didChange(widget.controller.text);
        }
      });
    }
    if (!identical(oldWidget.focusNode, widget.focusNode)) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      widget.focusNode?.addListener(_handleFocusChanged);
    }
    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    widget.focusNode?.removeListener(_handleFocusChanged);
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  void _handleControllerChanged() {
    final value = widget.controller.text;
    if (_lastControllerText == value) return;
    _lastControllerText = value;
    _cupertinoFieldKey.currentState?.didChange(value);
  }

  void _handleChanged(String value, FormFieldState<String>? field) {
    _lastControllerText = value;
    if (field?.value != value) field?.didChange(value);
    widget.onChanged?.call(value);
  }

  void _toggleObscured() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS
        ? _buildCupertino(context)
        : _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      validator: widget.validator,
      forceErrorText: widget.forceErrorText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      obscureText: _obscured,
      enabled: widget.enabled,
      onChanged: (value) => _handleChanged(value, null),
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        errorMaxLines: 20,
        prefixIcon: _prefix(context),
        suffixIcon: _visibilityToggle(context, TargetPlatform.android),
      ),
    );
  }

  Widget _buildCupertino(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    return FormField<String>(
      key: _cupertinoFieldKey,
      initialValue: widget.controller.text,
      validator: widget.validator,
      forceErrorText: widget.forceErrorText,
      enabled: widget.enabled,
      builder: (field) {
        final errorText = field.errorText;
        final borderColor = errorText == null ? tokens.outline : tokens.danger;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              container: true,
              label: widget.label,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(widget.label, style: tokens.labelTextStyle),
                  ),
                  SizedBox(height: tokens.space8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: CupertinoTextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      autofillHints: widget.autofillHints,
                      obscureText: _obscured,
                      enabled: widget.enabled,
                      onChanged: (value) => _handleChanged(value, field),
                      onSubmitted: widget.onFieldSubmitted,
                      prefix: _prefix(context),
                      suffix: _visibilityToggle(context, TargetPlatform.iOS),
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.space12,
                        vertical: tokens.space12,
                      ),
                      decoration: BoxDecoration(
                        color: widget.enabled
                            ? tokens.surface
                            : tokens.disabledContainer,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(tokens.fieldRadius),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  Widget? _visibilityToggle(BuildContext context, TargetPlatform platform) {
    if (!widget.showObscureToggle) return null;
    final label = _obscured ? '显示密码' : '隐藏密码';
    final iconRole = _obscured
        ? AppIconRole.visibility
        : AppIconRole.visibilityOff;
    final icon = Icon(resolveAppIcon(iconRole, platform), size: 20);
    if (platform == TargetPlatform.iOS) {
      return Semantics(
        container: true,
        button: true,
        label: label,
        enabled: widget.enabled,
        onTap: widget.enabled ? _toggleObscured : null,
        child: ExcludeSemantics(
          child: CupertinoButton(
            minimumSize: const Size(44, 44),
            padding: EdgeInsets.zero,
            onPressed: widget.enabled ? _toggleObscured : null,
            child: icon,
          ),
        ),
      );
    }
    return IconButton(
      tooltip: label,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      onPressed: widget.enabled ? _toggleObscured : null,
      icon: icon,
    );
  }
}

import 'package:flutter/material.dart';

import '../foundation/app_contracts.dart';
import '../foundation/app_design_tokens.dart';

class G2FirstPartyButton extends StatefulWidget {
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
  State<G2FirstPartyButton> createState() => _G2FirstPartyButtonState();
}

class _G2FirstPartyButtonState extends State<G2FirstPartyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    final callback = widget.enabled && !widget.loading
        ? widget.onPressed
        : null;
    final foreground = switch (widget.variant) {
      AppButtonVariant.primary => tokens.onPrimary,
      AppButtonVariant.destructive => tokens.onDanger,
      _ => tokens.primary,
    };
    final background = switch (widget.variant) {
      AppButtonVariant.primary => tokens.primary,
      AppButtonVariant.destructive => tokens.danger,
      _ => Colors.transparent,
    };
    return Semantics(
      button: true,
      enabled: callback != null,
      label: widget.label,
      value: widget.loading ? '加载中' : null,
      liveRegion: widget.loading,
      onTap: callback,
      child: ExcludeSemantics(
        child: Listener(
          onPointerDown: callback == null
              ? null
              : (_) => setState(() => _pressed = true),
          onPointerUp: callback == null
              ? null
              : (_) => setState(() => _pressed = false),
          onPointerCancel: callback == null
              ? null
              : (_) => setState(() => _pressed = false),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: FilledButton(
              style: FilledButton.styleFrom(
                foregroundColor: foreground,
                backgroundColor: _pressed
                    ? Color.alphaBlend(
                        foreground.withValues(alpha: 0.16),
                        background,
                      )
                    : background,
                disabledBackgroundColor: tokens.disabledContainer,
                disabledForegroundColor: tokens.disabledText,
                side: widget.variant == AppButtonVariant.secondary
                    ? BorderSide(color: tokens.outline)
                    : BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.controlRadius),
                ),
              ),
              onPressed: callback,
              child: widget.loading
                  ? SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                      ),
                    )
                  : Text(widget.label),
            ),
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
    this.obscureText = false,
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
  final bool obscureText;
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
    obscureText: obscureText,
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
    onTap: enabled ? () => onChanged(!value) : null,
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
  Widget build(BuildContext context) {
    final pressured =
        MediaQuery.sizeOf(context).width < 390 ||
        MediaQuery.textScalerOf(context).scale(16) > 24 ||
        title.runes.length > 12 ||
        (subtitle?.runes.length ?? 0) > 12 ||
        (value?.runes.length ?? 0) > 12;
    final supporting = [?subtitle, if (pressured) ?value].join('\n');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: supporting.isEmpty ? null : Text(supporting),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!pressured && value != null) Text(value!),
          if (onPressed != null) const Icon(Icons.chevron_right),
        ],
      ),
      enabled: enabled,
      onTap: enabled ? onPressed : null,
    );
  }
}

class G2FirstPartyFeedback extends StatelessWidget {
  const G2FirstPartyFeedback({
    super.key,
    required this.title,
    required this.message,
    required this.tone,
    this.actionLabel,
    this.onAction,
  }) : assert((actionLabel == null) == (onAction == null));

  final String title;
  final String message;
  final AppTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    final color = tone == AppTone.error ? tokens.danger : tokens.info;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(tokens.controlRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              container: true,
              liveRegion: tone == AppTone.error,
              label: '${_toneLabel(tone)}，$title，$message',
              child: ExcludeSemantics(
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
            if (actionLabel != null) ...[
              const SizedBox(height: 8),
              G2FirstPartyButton(
                label: actionLabel!,
                variant: AppButtonVariant.tertiary,
                onPressed: onAction!,
              ),
            ],
          ],
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
  const G2FirstPartyProgress({super.key, required this.label, this.value});

  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    value: value == null ? null : '${(value! * 100).round()}%',
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

class G2FirstPartyBottomNavigation extends StatelessWidget {
  const G2FirstPartyBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    const destinations = [
      (label: '首页', icon: Icons.home_outlined, selected: Icons.home),
      (label: '我的', icon: Icons.person_outline, selected: Icons.person),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(top: BorderSide(color: tokens.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final (index, destination) in destinations.indexed)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: selectedIndex == index,
                  label: destination.label,
                  onTap: () => onSelected(index),
                  child: ExcludeSemantics(
                    child: InkWell(
                      onTap: () => onSelected(index),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedIndex == index
                                  ? destination.selected
                                  : destination.icon,
                              color: selectedIndex == index
                                  ? tokens.primary
                                  : tokens.onSurfaceContainer,
                            ),
                            const SizedBox(height: 2),
                            Text(destination.label),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class G2FirstPartyDialogPanel extends StatelessWidget {
  const G2FirstPartyDialogPanel({
    super.key,
    required this.title,
    required this.message,
    required this.onCancel,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    return Semantics(
      container: true,
      namesRoute: true,
      label: title,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border.all(color: tokens.outline),
          borderRadius: BorderRadius.circular(tokens.controlRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: tokens.pageTitleTextStyle),
              const SizedBox(height: 8),
              Text(message),
              const SizedBox(height: 20),
              G2FirstPartyButton(
                label: '取消',
                variant: AppButtonVariant.secondary,
                onPressed: onCancel,
              ),
              const SizedBox(height: 8),
              G2FirstPartyButton(label: '确认', onPressed: onConfirm),
            ],
          ),
        ),
      ),
    );
  }
}

class G2FirstPartyActionMenu extends StatelessWidget {
  const G2FirstPartyActionMenu({
    super.key,
    required this.items,
    required this.onSelected,
    required this.onCancel,
  });

  final List<({String label, bool enabled, bool destructive})> items;
  final ValueChanged<int> onSelected;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border.all(color: tokens.outline),
        borderRadius: BorderRadius.circular(tokens.controlRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('选择操作', style: tokens.sectionTitleTextStyle),
            const SizedBox(height: 8),
            for (final (index, item) in items.indexed)
              G2FirstPartyButton(
                label: item.label,
                enabled: item.enabled,
                variant: item.destructive
                    ? AppButtonVariant.destructive
                    : AppButtonVariant.tertiary,
                onPressed: () => onSelected(index),
              ),
            const Divider(),
            G2FirstPartyButton(
              label: '取消',
              variant: AppButtonVariant.secondary,
              onPressed: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}

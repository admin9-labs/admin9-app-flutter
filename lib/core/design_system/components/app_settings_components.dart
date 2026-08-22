import 'package:flutter/material.dart';

import '../foundation/app_contracts.dart';
import '../foundation/app_design_tokens.dart';
import 'app_icon.dart';

class AppSingleChoiceList<T extends Object> extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    assert(choices.length >= 2);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: RadioGroup<T>(
        groupValue: value,
        onChanged: (next) {
          if (enabled && next != null) onChanged(next);
        },
        child: ListView(
          children: choices
              .map(
                (choice) => Semantics(
                  container: true,
                  label: choice.label,
                  checked: choice.value == value,
                  enabled: enabled,
                  inMutuallyExclusiveGroup: true,
                  onTap: enabled ? () => onChanged(choice.value) : null,
                  child: ExcludeSemantics(
                    child: RadioListTile<T>(
                      key: ValueKey<Object>(choice.value),
                      value: choice.value,
                      title: Text(choice.label),
                      enabled: enabled,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class AppSwitch extends StatelessWidget {
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

  void _toggle() {
    if (enabled) onChanged(!value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label,
      toggled: value,
      enabled: enabled,
      onTap: enabled ? _toggle : null,
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
}

class AppListTile extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final pressured = _isPressured(
      context,
      primaryText: title,
      secondaryText: currentValue ?? subtitle,
    );
    final subtitleLines = <String>[?subtitle, if (pressured) ?currentValue];
    final leading = leadingIcon == null
        ? null
        : Icon(resolveAppIcon(leadingIcon!, platform));
    final trailing = _trailing(context, platform, pressured);
    final tap = enabled ? onTap : null;
    return ListTile(
      title: Text(title),
      subtitle: subtitleLines.isEmpty ? null : Text(subtitleLines.join('\n')),
      leading: leading,
      trailing: trailing,
      onTap: tap,
      enabled: enabled,
      selected: selected,
      minVerticalPadding: 12,
    );
  }

  Widget? _trailing(
    BuildContext context,
    TargetPlatform platform,
    bool pressured,
  ) {
    final children = <Widget>[
      if (!pressured && currentValue != null)
        Flexible(child: Text(currentValue!, overflow: TextOverflow.ellipsis)),
      if (disclosure)
        Icon(resolveAppIcon(AppIconRole.chevronForward, platform)),
    ];
    if (children.isEmpty) return null;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

bool _isPressured(
  BuildContext context, {
  String? primaryText,
  String? secondaryText,
}) {
  return MediaQuery.sizeOf(context).width < 390 ||
      MediaQuery.textScalerOf(context).scale(16) > 24 ||
      (primaryText?.runes.length ?? 0) > 12 ||
      (secondaryText?.runes.length ?? 0) > 12;
}

class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.children,
    this.title,
    this.footer,
  });

  final String? title;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space16,
              tokens.space16,
              tokens.space16,
              tokens.space8,
            ),
            child: Text(title!, style: tokens.sectionTitleTextStyle),
          ),
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1)
            Divider(height: 1, indent: tokens.space16),
        ],
        if (footer != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space16,
              tokens.space8,
              tokens.space16,
              tokens.space16,
            ),
            child: Text(footer!, style: tokens.supportingTextStyle),
          ),
      ],
    );
  }
}

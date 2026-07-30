import 'package:flutter/cupertino.dart';
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
    return Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              automaticallyImplyLeading: true,
              previousPageTitle: '设置',
              middle: Text(title),
            ),
            child: SafeArea(
              child: ListView(
                children: [
                  CupertinoListSection.insetGrouped(
                    children: choices
                        .map((choice) {
                          final pressured =
                              MediaQuery.textScalerOf(context).scale(16) > 24 ||
                              choice.label.runes.length > 12;
                          final trailing = choice.value == value
                              ? const Icon(CupertinoIcons.check_mark)
                              : null;
                          final tap = enabled
                              ? () => onChanged(choice.value)
                              : null;
                          return Semantics(
                            container: true,
                            label: choice.label,
                            button: true,
                            selected: choice.value == value,
                            enabled: enabled,
                            onTap: tap,
                            child: ExcludeSemantics(
                              child: pressured
                                  ? _CupertinoPressuredRow(
                                      key: ValueKey<Object>(choice.value),
                                      content: Text(choice.label),
                                      trailing: trailing,
                                      onPressed: tap,
                                    )
                                  : CupertinoListTile(
                                      key: ValueKey<Object>(choice.value),
                                      title: Text(choice.label),
                                      trailing: trailing,
                                      onTap: tap,
                                    ),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
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
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      final pressured = _isPressured(context, primaryText: label);
      return Semantics(
        container: true,
        label: label,
        toggled: value,
        enabled: enabled,
        onTap: enabled ? _toggle : null,
        child: ExcludeSemantics(
          child: pressured
              ? _CupertinoPressuredRow(
                  onPressed: enabled ? _toggle : null,
                  content: Text(label),
                  trailing: CupertinoSwitch(
                    value: value,
                    onChanged: enabled ? onChanged : null,
                  ),
                )
              : CupertinoListTile(
                  title: Text(label),
                  onTap: enabled ? _toggle : null,
                  trailing: CupertinoSwitch(
                    value: value,
                    onChanged: enabled ? onChanged : null,
                  ),
                ),
        ),
      );
    }
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
    if (platform == TargetPlatform.iOS) {
      return Semantics(
        selected: selected,
        enabled: enabled,
        child: pressured
            ? _CupertinoPressuredRow(
                onPressed: tap,
                leading: leading,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    if (subtitleLines.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitleLines.join('\n'),
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: trailing,
              )
            : CupertinoListTile(
                title: Text(title),
                subtitle: subtitleLines.isEmpty
                    ? null
                    : Text(subtitleLines.join('\n')),
                leading: leading,
                additionalInfo: currentValue == null
                    ? null
                    : Text(currentValue!),
                trailing: trailing,
                onTap: tap,
              ),
      );
    }
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
      if (!pressured && currentValue != null && platform != TargetPlatform.iOS)
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

class _CupertinoPressuredRow extends StatelessWidget {
  const _CupertinoPressuredRow({
    super.key,
    required this.content,
    required this.trailing,
    this.leading,
    this.onPressed,
  });

  final Widget content;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minimumSize: const Size(44, 44),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 12, 12),
      onPressed: onPressed,
      child: DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              SizedBox.square(dimension: 28, child: Center(child: leading)),
              const SizedBox(width: 12),
            ],
            Expanded(child: content),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
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
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoListSection.insetGrouped(
        header: title == null ? null : Text(title!),
        footer: footer == null ? null : Text(footer!),
        children: children,
      );
    }
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

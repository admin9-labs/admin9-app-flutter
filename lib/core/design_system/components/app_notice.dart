import 'package:flutter/material.dart';

import '../foundation/app_contracts.dart';
import '../foundation/app_design_tokens.dart';
import 'app_form_components.dart';
import 'app_icon.dart';

class AppNotice extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    final foreground = _foreground(tokens);
    final background = Color.alphaBlend(
      foreground.withValues(alpha: 0.12),
      tokens.surface,
    );
    return Semantics(
      container: true,
      liveRegion: tone == AppTone.error,
      label: [_toneLabel, ?title, message].join('，'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: foreground),
          borderRadius: BorderRadius.circular(tokens.controlRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.space16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(
                  resolveAppIcon(_iconRole, Theme.of(context).platform),
                  color: foreground,
                ),
              ),
              SizedBox(width: tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) ...[
                      Text(
                        title!,
                        style: tokens.sectionTitleTextStyle.copyWith(
                          color: foreground,
                        ),
                      ),
                      SizedBox(height: tokens.space4),
                    ],
                    Text(message, style: TextStyle(color: foreground)),
                    if (actionLabel != null) ...[
                      SizedBox(height: tokens.space8),
                      AppButton(
                        label: actionLabel!,
                        variant: AppButtonVariant.tertiary,
                        onPressed: onAction!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppIconRole get _iconRole => switch (tone) {
    AppTone.info => AppIconRole.info,
    AppTone.success => AppIconRole.success,
    AppTone.warning => AppIconRole.warning,
    AppTone.error => AppIconRole.error,
  };

  Color _foreground(AppDesignTokens tokens) => switch (tone) {
    AppTone.info => tokens.info,
    AppTone.success => tokens.success,
    AppTone.warning => tokens.warning,
    AppTone.error => tokens.danger,
  };

  String get _toneLabel => switch (tone) {
    AppTone.info => '信息',
    AppTone.success => '成功',
    AppTone.warning => '警告',
    AppTone.error => '错误',
  };
}

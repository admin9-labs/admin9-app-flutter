import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../foundation/app_contracts.dart';
import '../foundation/app_design_tokens.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({
    super.key,
    required this.label,
    this.kind = AppProgressKind.circular,
    this.value,
  }) : assert(label != ''),
       assert(value == null || (value >= 0 && value <= 1));

  final String label;
  final AppProgressKind kind;
  final double? value;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final tokens = AppDesignScope.of(context);
    final semanticValue = value == null ? null : '${(value! * 100).round()}%';
    final indicator = platform == TargetPlatform.iOS
        ? _cupertinoIndicator(tokens)
        : _materialIndicator();
    final usesLinearLayout =
        kind == AppProgressKind.linear ||
        (platform == TargetPlatform.iOS && value != null);
    final content = !usesLinearLayout
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              indicator,
              SizedBox(width: tokens.space12),
              Flexible(child: Text(label)),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label),
              SizedBox(height: tokens.space8),
              indicator,
            ],
          );
    return Semantics(
      label: label,
      value: semanticValue,
      liveRegion: true,
      child: ExcludeSemantics(child: content),
    );
  }

  Widget _materialIndicator() => kind == AppProgressKind.circular
      ? CircularProgressIndicator(value: value)
      : LinearProgressIndicator(value: value);

  Widget _cupertinoIndicator(AppDesignTokens tokens) {
    if (value == null) {
      return const CupertinoActivityIndicator();
    }
    return SizedBox(
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: tokens.disabledContainer),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: ColoredBox(color: tokens.primary),
            ),
          ],
        ),
      ),
    );
  }
}

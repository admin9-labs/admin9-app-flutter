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
    final tokens = AppDesignScope.of(context);
    final semanticValue = value == null ? null : '${(value! * 100).round()}%';
    final indicator = _indicator();
    final usesLinearLayout = kind == AppProgressKind.linear;
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

  Widget _indicator() => kind == AppProgressKind.circular
      ? CircularProgressIndicator(value: value)
      : LinearProgressIndicator(value: value);
}

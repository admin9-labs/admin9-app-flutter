import 'package:flutter/widgets.dart';

import 'a_grid.dart';

enum _AGridBadgeKind { count, dot, label }

/// A compact, semantic badge for an [AGrid] icon action.
class AGridBadge extends StatelessWidget {
  const AGridBadge.count(int count, {required this.semanticsLabel, super.key})
    : assert(count >= 0),
      _kind = _AGridBadgeKind.count,
      _count = count,
      _label = null;

  const AGridBadge.dot({required this.semanticsLabel, super.key})
    : _kind = _AGridBadgeKind.dot,
      _count = null,
      _label = null;

  const AGridBadge.label(String label, {String? semanticsLabel, super.key})
    : assert(label.length > 0),
      _kind = _AGridBadgeKind.label,
      _count = null,
      _label = label,
      semanticsLabel = semanticsLabel ?? label;

  final _AGridBadgeKind _kind;
  final int? _count;
  final String? _label;
  final String semanticsLabel;

  bool get visible => _kind != _AGridBadgeKind.count || _count! > 0;

  String? get _text => switch (_kind) {
    _AGridBadgeKind.count => _count! > 99 ? '99+' : '$_count',
    _AGridBadgeKind.dot => null,
    _AGridBadgeKind.label => _label,
  };

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final style = AGrid.styleOf(context);
    if (_kind == _AGridBadgeKind.dot) {
      return DecoratedBox(
        key: const ValueKey('agrid-badge-dot'),
        decoration: style.attentionBadgeDecoration,
        child: SizedBox.square(dimension: style.badgeDotSize),
      );
    }

    final label = _kind == _AGridBadgeKind.label;
    final padding = label ? style.badgeLabelPadding : style.badgeCountPadding;
    final textStyle = label
        ? style.neutralBadgeTextStyle
        : style.attentionBadgeTextStyle;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: style.badgeMinimumSize,
        minHeight: style.badgeMinimumSize,
        maxWidth: label ? style.badgeLabelMaxWidth : double.infinity,
      ),
      child: DecoratedBox(
        key: ValueKey(label ? 'agrid-badge-label' : 'agrid-badge-count'),
        decoration: label
            ? style.neutralBadgeDecoration
            : style.attentionBadgeDecoration,
        child: Padding(
          padding: padding,
          child: Text(
            _text!,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}

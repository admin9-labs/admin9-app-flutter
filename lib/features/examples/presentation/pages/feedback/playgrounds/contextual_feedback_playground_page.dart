import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_clipboard.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_code_panel.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class ContextualFeedbackPlaygroundPage extends StatefulWidget {
  const ContextualFeedbackPlaygroundPage({super.key});

  @override
  State<ContextualFeedbackPlaygroundPage> createState() =>
      _ContextualFeedbackPlaygroundPageState();
}

class _ContextualFeedbackPlaygroundPageState
    extends State<ContextualFeedbackPlaygroundPage> {
  bool _enabled = true;
  bool _above = false;
  bool _popoverShown = false;
  bool _tooltipShown = false;
  String _statusKey = 'examples.feedback.playgrounds.contextual.status_ready';

  String get _summary =>
      'enabled: $_enabled, placement: ${_above ? 'above' : 'below'}';

  String get _code =>
      'FPopover(popoverAnchor: AlignmentGeometry.${_above ? 'bottomCenter' : 'topCenter'}, ...);\n'
      'FPopoverMenu(menuBuilder: ...);\n'
      'FTooltip(longPress: $_enabled, ...);';

  void _setPopoverShown(bool shown) {
    if (!_enabled && shown) return;
    if (mounted && shown != _popoverShown) {
      setState(() => _popoverShown = shown);
    }
  }

  void _setTooltipShown(bool shown) {
    if (!_enabled && shown) return;
    if (mounted && shown != _tooltipShown) {
      setState(() => _tooltipShown = shown);
    }
  }

  void _setEnabled(bool enabled) => setState(() {
    _enabled = enabled;
    if (!enabled) {
      _popoverShown = false;
      _tooltipShown = false;
    }
  });

  void _select(String statusKey) => setState(() => _statusKey = statusKey);

  void _reset() => setState(() {
    _enabled = true;
    _above = false;
    _popoverShown = false;
    _tooltipShown = false;
    _statusKey = 'examples.feedback.playgrounds.contextual.status_ready';
  });

  Future<void> _copy() => copyPlaygroundText(
    context,
    text: _code,
    title: 'examples.feedback.playgrounds.common.copied_title'.tr(),
    description: 'examples.feedback.playgrounds.common.copied_description'.tr(),
  );

  @override
  Widget build(BuildContext context) {
    final popoverAnchor = _above
        ? AlignmentGeometry.bottomCenter
        : AlignmentGeometry.topCenter;
    final childAnchor = _above
        ? AlignmentGeometry.topCenter
        : AlignmentGeometry.bottomCenter;

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text('examples.feedback.playgrounds.contextual.title'.tr()),
        prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
      ),
      child: ResponsivePageBody(
        children: [
          ComponentExampleSection(
            title: 'examples.feedback.playgrounds.common.configuration'.tr(),
            child: Column(
              spacing: 16,
              children: [
                FSwitch(
                  key: const ValueKey('contextual-enabled-control'),
                  label: Text(
                    'examples.feedback.playgrounds.common.enabled'.tr(),
                  ),
                  value: _enabled,
                  onChange: _setEnabled,
                ),
                FSwitch(
                  key: const ValueKey('contextual-placement-control'),
                  label: Text(
                    'examples.feedback.playgrounds.contextual.place_above'.tr(),
                  ),
                  value: _above,
                  onChange: (value) => setState(() => _above = value),
                ),
              ],
            ),
          ),
          PlaygroundPreview(
            title: 'examples.feedback.playgrounds.common.preview'.tr(),
            status: _statusKey.tr(),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FPopover(
                  key: const ValueKey('contextual-popover'),
                  control: .lifted(
                    shown: _popoverShown,
                    onChange: _setPopoverShown,
                  ),
                  popoverAnchor: popoverAnchor,
                  childAnchor: childAnchor,
                  overflow: .flip,
                  useViewPadding: true,
                  popoverBuilder: (_, controller) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Column(
                        key: const ValueKey('contextual-popover-content'),
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Text(
                            'examples.feedback.playgrounds.contextual.popover_body'
                                .tr(),
                          ),
                          FButton(
                            key: const ValueKey('contextual-popover-apply'),
                            size: .sm,
                            mainAxisSize: .min,
                            onPress: () {
                              _select(
                                'examples.feedback.playgrounds.contextual.status_applied',
                              );
                              controller.hide();
                            },
                            child: Text(
                              'examples.feedback.playgrounds.contextual.apply'
                                  .tr(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  builder: (_, controller, _) => FButton(
                    key: const ValueKey('contextual-popover-open'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: _enabled ? controller.toggle : null,
                    child: Text(
                      'examples.feedback.playgrounds.contextual.open_popover'
                          .tr(),
                    ),
                  ),
                ),
                FPopoverMenu(
                  key: const ValueKey('contextual-menu'),
                  menuAnchor: popoverAnchor,
                  childAnchor: childAnchor,
                  overflow: .flip,
                  useViewPadding: true,
                  menuBuilder: (_, controller, _) => [
                    .group(
                      children: [
                        .item(
                          prefix: const Icon(FLucideIcons.copy),
                          title: Text(
                            'examples.feedback.playgrounds.contextual.menu_copy'
                                .tr(),
                          ),
                          onPress: () {
                            _select(
                              'examples.feedback.playgrounds.contextual.status_copied',
                            );
                            controller.hide();
                          },
                        ),
                        .item(
                          prefix: const Icon(FLucideIcons.share2),
                          title: Text(
                            'examples.feedback.playgrounds.contextual.menu_share'
                                .tr(),
                          ),
                          onPress: () {
                            _select(
                              'examples.feedback.playgrounds.contextual.status_shared',
                            );
                            controller.hide();
                          },
                        ),
                      ],
                    ),
                  ],
                  builder: (_, controller, _) => FButton(
                    key: const ValueKey('contextual-menu-open'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: _enabled ? controller.toggle : null,
                    child: Text(
                      'examples.feedback.playgrounds.contextual.open_menu'.tr(),
                    ),
                  ),
                ),
                FTooltip(
                  key: const ValueKey('contextual-tooltip'),
                  control: .lifted(
                    shown: _tooltipShown,
                    onChange: _setTooltipShown,
                  ),
                  tipAnchor: popoverAnchor,
                  childAnchor: childAnchor,
                  longPress: _enabled,
                  useViewPadding: true,
                  tipBuilder: (_, _) => Text(
                    'examples.feedback.playgrounds.contextual.tooltip_body'
                        .tr(),
                  ),
                  child: FButton.icon(
                    key: const ValueKey('contextual-tooltip-open'),
                    variant: .outline,
                    semanticsLabel: 'examples.feedback.playgrounds.contextual.tooltip_semantics'
                        .tr(),
                    onPress: _enabled
                        ? () => _setTooltipShown(!_tooltipShown)
                        : null,
                    child: const Icon(FLucideIcons.info),
                  ),
                ),
              ],
            ),
          ),
          PlaygroundCodePanel(
            title: 'examples.feedback.playgrounds.common.usage'.tr(),
            summary: _summary,
            code: _code,
          ),
          PlaygroundActionBar(
            copyLabel: 'examples.feedback.playgrounds.common.copy'.tr(),
            resetLabel: 'examples.feedback.playgrounds.common.reset'.tr(),
            onCopy: _copy,
            onReset: _reset,
          ),
        ],
      ),
    );
  }
}

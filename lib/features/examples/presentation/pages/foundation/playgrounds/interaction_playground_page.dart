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
class InteractionPlaygroundPage extends StatefulWidget {
  const InteractionPlaygroundPage({super.key});

  @override
  State<InteractionPlaygroundPage> createState() =>
      _InteractionPlaygroundPageState();
}

enum _TabControlMode { managed, lifted }

class _InteractionPlaygroundPageState extends State<InteractionPlaygroundPage> {
  final _tappableFocusNode = FocusNode();
  int _tabIndex = 0;
  _TabControlMode _controlMode = _TabControlMode.lifted;
  bool _scrollable = false;
  bool _swipe = true;
  bool _expanded = true;
  bool _enabled = true;
  bool _selected = false;
  int _pressCount = 0;

  String get _summary =>
      'tabIndex: $_tabIndex, control: ${_controlMode.name}, '
      'scrollable: $_scrollable, swipe: $_swipe, '
      'expanded: $_expanded, enabled: $_enabled, '
      'selected: $_selected, presses: $_pressCount';

  String get _code =>
      '''FTabs(
  control: FTabControl.${_controlMode.name}(...),
  scrollable: $_scrollable,
  expands: true,
  contentPhysics: ${_swipe ? 'BouncingScrollPhysics()' : 'NeverScrollableScrollPhysics()'},
  children: entries,
)
FTappable(
  selected: $_selected,
  onPress: ${_enabled ? 'onPress' : 'null'},
)''';

  void _reset() => setState(() {
    _tabIndex = 0;
    _controlMode = _TabControlMode.lifted;
    _scrollable = false;
    _swipe = true;
    _expanded = true;
    _enabled = true;
    _selected = false;
    _pressCount = 0;
  });

  @override
  void dispose() {
    _tappableFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.foundation.playgrounds.interaction.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: context.maybePop)],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'examples.playground.configuration'.tr(),
          child: Column(
            spacing: 16,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FButton(
                    key: const ValueKey('interaction-control-managed'),
                    variant: .outline,
                    mainAxisSize: .min,
                    selected: _controlMode == _TabControlMode.managed,
                    onPress: () =>
                        setState(() => _controlMode = _TabControlMode.managed),
                    child: Text(
                      'examples.foundation.playgrounds.interaction.managed'
                          .tr(),
                    ),
                  ),
                  FButton(
                    key: const ValueKey('interaction-control-lifted'),
                    variant: .outline,
                    mainAxisSize: .min,
                    selected: _controlMode == _TabControlMode.lifted,
                    onPress: () =>
                        setState(() => _controlMode = _TabControlMode.lifted),
                    child: Text(
                      'examples.foundation.playgrounds.interaction.lifted'.tr(),
                    ),
                  ),
                ],
              ),
              FSwitch(
                key: const ValueKey('interaction-scrollable'),
                label: Text(
                  'examples.foundation.playgrounds.interaction.scrollable'.tr(),
                ),
                value: _scrollable,
                onChange: (value) => setState(() => _scrollable = value),
              ),
              FSwitch(
                key: const ValueKey('interaction-swipe'),
                label: Text(
                  'examples.foundation.playgrounds.interaction.swipe'.tr(),
                ),
                value: _swipe,
                onChange: (value) => setState(() => _swipe = value),
              ),
              FSwitch(
                key: const ValueKey('interaction-expanded'),
                label: Text(
                  'examples.foundation.playgrounds.interaction.expanded'.tr(),
                ),
                value: _expanded,
                onChange: (value) => setState(() => _expanded = value),
              ),
              FSwitch(
                key: const ValueKey('interaction-enabled'),
                label: Text(
                  'examples.foundation.playgrounds.interaction.enabled'.tr(),
                ),
                value: _enabled,
                onChange: (value) => setState(() => _enabled = value),
              ),
              FSwitch(
                key: const ValueKey('interaction-selected'),
                label: Text(
                  'examples.foundation.playgrounds.interaction.selected'.tr(),
                ),
                value: _selected,
                onChange: (value) => setState(() => _selected = value),
              ),
            ],
          ),
        ),
        PlaygroundPreview(
          title: 'examples.playground.preview'.tr(),
          status: _summary,
          child: Column(
            spacing: 16,
            children: [
              SizedBox(
                height: MediaQuery.textScalerOf(context)
                    .scale(250)
                    .clamp(250, 600)
                    .toDouble(),
                child: KeyedSubtree(
                  key: const ValueKey('interaction-tabs'),
                  child: FTabs(
                    key: ValueKey(_controlMode),
                    control: switch (_controlMode) {
                      _TabControlMode.managed => FTabControl.managed(
                        initial: _tabIndex,
                        onChange: (index) => setState(() => _tabIndex = index),
                      ),
                      _TabControlMode.lifted => FTabControl.lifted(
                        index: _tabIndex,
                        onChange: (index) => setState(() => _tabIndex = index),
                      ),
                    },
                    scrollable: _scrollable,
                    style: _scrollable
                        ? const .delta(indicatorSize: .label)
                        : const .context(),
                    expands: true,
                    contentPhysics: _swipe
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    children: [
                      FTabEntry.entry(
                        label: Text(
                          'examples.foundation.playgrounds.interaction.general'
                              .tr(),
                        ),
                        child: Text(
                          'examples.foundation.playgrounds.interaction.general_body'
                              .tr(),
                        ),
                      ),
                      FTabEntry.entry(
                        label: Text(
                          'examples.foundation.playgrounds.interaction.advanced'
                              .tr(),
                        ),
                        child: Text(
                          'examples.foundation.playgrounds.interaction.advanced_body'
                              .tr(),
                        ),
                      ),
                      FTabEntry.entry(
                        label: Text(
                          'examples.foundation.playgrounds.interaction.long_tab'
                              .tr(),
                        ),
                        child: Text(
                          'examples.foundation.playgrounds.interaction.long_tab_body'
                              .tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Semantics(
                key: const ValueKey('interaction-disclosure-semantics'),
                button: true,
                expanded: _expanded,
                label:
                    (_expanded
                            ? 'examples.foundation.playgrounds.interaction.collapse'
                            : 'examples.foundation.playgrounds.interaction.expand')
                        .tr(),
                onTap: () => setState(() => _expanded = !_expanded),
                child: ExcludeSemantics(
                  child: FButton(
                    key: const ValueKey('interaction-disclosure'),
                    variant: .outline,
                    suffix: Icon(
                      _expanded
                          ? FLucideIcons.chevronUp
                          : FLucideIcons.chevronDown,
                    ),
                    onPress: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      (_expanded
                              ? 'examples.foundation.playgrounds.interaction.collapse'
                              : 'examples.foundation.playgrounds.interaction.expand')
                          .tr(),
                    ),
                  ),
                ),
              ),
              FCollapsible(
                key: const ValueKey('interaction-collapsible-vertical'),
                value: _expanded ? 1 : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.theme.colors.muted,
                    borderRadius: context.theme.style.borderRadius.md,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'examples.foundation.playgrounds.interaction.collapsible_body'
                          .tr(),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FCollapsible(
                  key: const ValueKey('interaction-collapsible-horizontal'),
                  axis: .horizontal,
                  value: _expanded ? 1 : 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.theme.colors.muted,
                      borderRadius: context.theme.style.borderRadius.md,
                    ),
                    child: SizedBox(
                      width: 240,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'examples.foundation.playgrounds.interaction.horizontal_body'
                              .tr(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              FTappable(
                key: const ValueKey('interaction-tappable'),
                focusNode: _tappableFocusNode,
                focusedOutlineStyle: context.theme.style.focusedOutlineStyle,
                selected: _selected,
                semanticsLabel:
                    'examples.foundation.playgrounds.interaction.action'.tr(),
                semanticsHint:
                    'examples.foundation.playgrounds.interaction.action_hint'
                        .tr(),
                onPress: _enabled
                    ? () => setState(() {
                        _pressCount++;
                        _selected = !_selected;
                      })
                    : null,
                builder: (context, states, _) {
                  final selected = states.contains(FTappableVariant.selected);
                  final disabled = states.contains(FTappableVariant.disabled);
                  final pressed = states.contains(FTappableVariant.pressed);
                  return DecoratedBox(
                    key: const ValueKey('interaction-tappable-surface'),
                    decoration: BoxDecoration(
                      color: disabled
                          ? context.theme.colors.muted
                          : selected
                          ? context.theme.colors.primary
                          : pressed
                          ? context.theme.colors.secondary
                          : context.theme.colors.card,
                      border: Border.all(color: context.theme.colors.border),
                      borderRadius: context.theme.style.borderRadius.md,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${'examples.foundation.playgrounds.interaction.action'.tr()} '
                        '($_pressCount)',
                        style: context.theme.typography.body.md.copyWith(
                          color: selected && !disabled
                              ? context.theme.colors.primaryForeground
                              : context.theme.colors.foreground,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        PlaygroundCodePanel(
          title: 'examples.playground.usage'.tr(),
          summary: _summary,
          code: _code,
        ),
        PlaygroundActionBar(
          copyLabel: 'examples.playground.copy'.tr(),
          resetLabel: 'examples.playground.reset'.tr(),
          onCopy: () => copyPlaygroundText(
            context,
            text: _code,
            title: 'examples.playground.copied'.tr(),
            description: _summary,
          ),
          onReset: _reset,
        ),
      ],
    ),
  );
}

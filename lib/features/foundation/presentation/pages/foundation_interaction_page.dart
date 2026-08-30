import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class FoundationInteractionPage extends StatefulWidget {
  const FoundationInteractionPage({super.key});

  @override
  State<FoundationInteractionPage> createState() =>
      _FoundationInteractionPageState();
}

class _FoundationInteractionPageState extends State<FoundationInteractionPage> {
  bool _expanded = false;
  int _pressCount = 0;

  @override
  Widget build(BuildContext context) {
    final motion = context.accessibility.motion;

    return Column(
      children: [
        FHeader.nested(
          title: Text('foundation.interaction.title'.tr()),
          prefixes: [
            FHeaderAction.back(
              onPress: () {
                context.maybePop();
              },
            ),
          ],
        ),
        Expanded(
          child: ResponsivePageBody(
            children: [
              ComponentExampleSection(
                title: 'foundation.interaction.collapsible.title'.tr(),
                description: 'foundation.interaction.collapsible.description'
                    .tr(),
                child: Column(
                  spacing: 12,
                  children: [
                    FButton(
                      variant: .outline,
                      suffix: _expanded
                          ? context.theme.icons.chevronUp(context)
                          : context.theme.icons.chevronDown(context),
                      onPress: () {
                        setState(() => _expanded = !_expanded);
                      },
                      child: Text(
                        _expanded
                            ? 'foundation.interaction.collapsible.collapse'.tr()
                            : 'foundation.interaction.collapsible.expand'.tr(),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      duration: motion == .all
                          ? const Duration(milliseconds: 200)
                          : Duration.zero,
                      curve: Curves.easeInOut,
                      tween: Tween(end: _expanded ? 1 : 0),
                      builder: (context, value, child) =>
                          FCollapsible(value: value, child: child!),
                      child: FCard(
                        builder: (context, style, _) => Padding(
                          padding: style.padding,
                          child: Text(
                            'foundation.interaction.collapsible.body'.tr(),
                            style: style.subtitleTextStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ComponentExampleSection(
                title: 'foundation.interaction.tappable.title'.tr(),
                description: 'foundation.interaction.tappable.description'.tr(),
                child: FTappable(
                  semanticsLabel:
                      '${'foundation.interaction.tappable.label'.tr()}，'
                      '${'foundation.interaction.tappable.count'.tr(namedArgs: {'count': '$_pressCount'})}',
                  semanticsHint: 'foundation.interaction.tappable.hint'.tr(),
                  excludeSemantics: true,
                  onPress: () {
                    setState(() => _pressCount++);
                  },
                  builder: (context, states, child) {
                    final active = states.contains(FTappableVariant.pressed);
                    return AnimatedContainer(
                      duration: motion == .disabled
                          ? Duration.zero
                          : const Duration(milliseconds: 120),
                      padding: const .all(20),
                      decoration: BoxDecoration(
                        color: active
                            ? context.theme.colors.secondary
                            : context.theme.colors.card,
                        border: Border.all(color: context.theme.colors.border),
                        borderRadius: .circular(8),
                      ),
                      child: child,
                    );
                  },
                  child: Row(
                    spacing: 12,
                    children: [
                      context.theme.icons.userRound(context),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          spacing: 4,
                          children: [
                            Text(
                              'foundation.interaction.tappable.label'.tr(),
                              style: context.theme.typography.body.md,
                            ),
                            Text(
                              'foundation.interaction.tappable.count'.tr(
                                namedArgs: {'count': '$_pressCount'},
                              ),
                              style: context.theme.typography.body.sm.copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

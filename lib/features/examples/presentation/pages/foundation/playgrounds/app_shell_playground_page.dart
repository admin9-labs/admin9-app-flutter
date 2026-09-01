import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class AppShellPlaygroundPage extends StatefulWidget {
  const AppShellPlaygroundPage({super.key});

  @override
  State<AppShellPlaygroundPage> createState() => _AppShellPlaygroundPageState();
}

class _AppShellPlaygroundPageState extends State<AppShellPlaygroundPage> {
  int _index = 0;
  bool _safeAreaBottom = true;
  bool _headerActionEnabled = true;
  int _searchCount = 0;

  void _reset() => setState(() {
    _index = 0;
    _safeAreaBottom = true;
    _headerActionEnabled = true;
    _searchCount = 0;
  });

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.foundation.playgrounds.app_shell.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: context.maybePop)],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'examples.playground.configuration'.tr(),
          child: Column(
            spacing: 16,
            children: [
              FSwitch(
                key: const ValueKey('app-shell-safe-area'),
                label: Text(
                  'examples.foundation.playgrounds.app_shell.safe_area'.tr(),
                ),
                description: Text(
                  'examples.foundation.playgrounds.app_shell.safe_area_description'
                      .tr(),
                ),
                value: _safeAreaBottom,
                onChange: (value) => setState(() => _safeAreaBottom = value),
              ),
              FSwitch(
                key: const ValueKey('app-shell-header-action'),
                label: Text(
                  'examples.foundation.playgrounds.app_shell.header_action'
                      .tr(),
                ),
                value: _headerActionEnabled,
                onChange: (value) =>
                    setState(() => _headerActionEnabled = value),
              ),
            ],
          ),
        ),
        PlaygroundPreview(
          title: 'examples.playground.preview'.tr(),
          status:
              '${'examples.foundation.playgrounds.app_shell.selected'.tr()} '
              '${_index + 1} · '
              '${'examples.foundation.playgrounds.app_shell.search_count'.tr()} '
              '$_searchCount',
          child: SizedBox(
            height: MediaQuery.textScalerOf(context)
                .scale(380)
                .clamp(380, 720)
                .toDouble(),
            child: FScaffold(
              key: const ValueKey('app-shell-preview'),
              header: FHeader(
                title: Text(
                  'examples.foundation.playgrounds.app_shell.preview_title'
                      .tr(),
                ),
                suffixes: [
                  FHeaderAction(
                    key: const ValueKey('app-shell-search-action'),
                    icon: context.theme.icons.search(context),
                    semanticsLabel:
                        'examples.foundation.layout.header.search_semantics'
                            .tr(),
                    onPress: _headerActionEnabled
                        ? () => setState(() => _searchCount++)
                        : null,
                  ),
                ],
              ),
              footer: FBottomNavigationBar(
                key: const ValueKey('app-shell-bottom-navigation'),
                safeAreaBottom: _safeAreaBottom,
                index: _index,
                onChange: (index) => setState(() => _index = index),
                children: [
                  FBottomNavigationBarItem(
                    icon: const Icon(FLucideIcons.house),
                    label: Text('examples.navigation.foundation'.tr()),
                  ),
                  FBottomNavigationBarItem(
                    icon: const Icon(FLucideIcons.listChecks),
                    label: Text('examples.navigation.forms'.tr()),
                  ),
                  FBottomNavigationBarItem(
                    icon: const Icon(FLucideIcons.settings),
                    label: Text('navigation.settings'.tr()),
                  ),
                ],
              ),
              child: ListView(
                key: const ValueKey('app-shell-scroll'),
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  Text(
                    key: const ValueKey('app-shell-content-start'),
                    'examples.foundation.playgrounds.app_shell.long_copy'.tr(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Semantics(
                      key: const ValueKey(
                        'app-shell-divider-horizontal-semantics',
                      ),
                      container: true,
                      explicitChildNodes: true,
                      label: 'examples.foundation.layout.divider.title'.tr(),
                      child: const FDivider(
                        key: ValueKey('app-shell-divider-horizontal'),
                        style: .delta(
                          padding: .value(
                            EdgeInsetsDirectional.only(start: 24, end: 8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) => Text(
                      key: const ValueKey('app-shell-width'),
                      '${constraints.maxWidth.toStringAsFixed(0)} px · '
                      '${Localizations.localeOf(context).toLanguageTag()}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.textScalerOf(context)
                        .scale(56)
                        .clamp(56, 128)
                        .toDouble(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'examples.foundation.playgrounds.app_shell.primary_pane'
                                .tr(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Semantics(
                          key: const ValueKey(
                            'app-shell-divider-vertical-semantics',
                          ),
                          container: true,
                          explicitChildNodes: true,
                          label: 'examples.foundation.layout.divider.title'
                              .tr(),
                          child: const FDivider(
                            key: ValueKey('app-shell-divider-vertical'),
                            axis: .vertical,
                            style: .delta(
                              padding: .value(
                                EdgeInsetsDirectional.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'examples.foundation.playgrounds.app_shell.secondary_pane'
                                .tr(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var index = 1; index <= 6; index++)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'examples.foundation.playgrounds.app_shell.content_row'
                            .tr(namedArgs: {'index': '$index'}),
                      ),
                    ),
                  Text(
                    key: const ValueKey('app-shell-content-end'),
                    'examples.foundation.playgrounds.app_shell.content_end'
                        .tr(),
                  ),
                ],
              ),
            ),
          ),
        ),
        PlaygroundActionBar(
          resetLabel: 'examples.playground.reset'.tr(),
          onReset: _reset,
        ),
      ],
    ),
  );
}

import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class IconsPage extends StatefulWidget {
  const IconsPage({super.key});

  @override
  State<IconsPage> createState() => _IconsPageState();
}

class _IconsPageState extends State<IconsPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selected = 'search';
  double _size = 28;
  bool _themeMapping = true;

  List<_IconEntry> get _visible => _icons
      .where((entry) => entry.id.contains(_query.trim().toLowerCase()))
      .toList(growable: false);

  _IconEntry get _selectedEntry =>
      _icons.firstWhere((entry) => entry.id == _selected);

  String get _summary =>
      'icon: $_selected, size: ${_size.toStringAsFixed(0)}, '
      'themeMapping: $_themeMapping';

  void _reset() => setState(() {
    _searchController.clear();
    _query = '';
    _selected = 'search';
    _size = 28;
    _themeMapping = true;
  });

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.foundation.reference.icons.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: context.maybePop)],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'examples.playground.configuration'.tr(),
          child: Column(
            spacing: 16,
            children: [
              FTextField(
                key: const ValueKey('icons-search'),
                control: .managed(
                  controller: _searchController,
                  onChange: (value) => setState(() => _query = value.text),
                ),
                label: Text(
                  'examples.foundation.playgrounds.icons.search'.tr(),
                ),
                hint: 'search / calendar / settings',
                clearable: (value) => value.text.isNotEmpty,
                prefixBuilder: (context, style, states) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      states,
                      const Icon(FLucideIcons.search),
                    ),
              ),
              FSwitch(
                key: const ValueKey('icons-theme-mapping'),
                label: Text(
                  'examples.foundation.playgrounds.icons.theme_mapping'.tr(),
                ),
                description: Text(
                  'examples.foundation.playgrounds.icons.theme_mapping_description'
                      .tr(),
                ),
                value: _themeMapping,
                enabled: _selectedEntry.supportsThemeMapping,
                onChange: _selectedEntry.supportsThemeMapping
                    ? (value) => setState(() => _themeMapping = value)
                    : null,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final size in const [20.0, 28.0, 36.0])
                    FButton(
                      key: ValueKey('icons-size-${size.toInt()}'),
                      variant: .outline,
                      selected: _size == size,
                      mainAxisSize: .min,
                      onPress: () => setState(() => _size = size),
                      child: Text('${size.toInt()} px'),
                    ),
                ],
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
                height: 72,
                child: Center(
                  child: _themeMapping
                      ? _themeIcon(context, _selectedEntry, _size)
                      : Icon(
                          _selectedEntry.icon,
                          key: const ValueKey('icons-selected-preview'),
                          size: _size,
                          semanticLabel: _selected,
                        ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) => GridView.count(
                  key: const ValueKey('icons-browser'),
                  crossAxisCount: constraints.maxWidth < 360 ? 3 : 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    for (final entry in _visible)
                      FTappable(
                        key: ValueKey('icon-${entry.id}'),
                        selected: _selected == entry.id,
                        focusedOutlineStyle:
                            context.theme.style.focusedOutlineStyle,
                        semanticsLabel: entry.id,
                        onPress: () => setState(() {
                          _selected = entry.id;
                          if (!entry.supportsThemeMapping) {
                            _themeMapping = false;
                          }
                        }),
                        builder: (context, states, _) => DecoratedBox(
                          decoration: BoxDecoration(
                            color: states.contains(FTappableVariant.selected)
                                ? context.theme.colors.secondary
                                : context.theme.colors.muted,
                            border: Border.all(
                              color: states.contains(FTappableVariant.selected)
                                  ? context.theme.colors.primary
                                  : context.theme.colors.border,
                            ),
                            borderRadius: context.theme.style.borderRadius.md,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 6,
                            children: [
                              Icon(entry.icon, size: 24),
                              Text(
                                entry.id,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.theme.typography.body.xs,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
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

Widget _themeIcon(BuildContext context, _IconEntry entry, double size) {
  final icon = switch (entry.themeToken!) {
    _ThemeIconToken.search => context.theme.icons.search(
      context,
      semanticsLabel: entry.id,
    ),
    _ThemeIconToken.calendar => context.theme.icons.calendar(
      context,
      semanticsLabel: entry.id,
    ),
    _ThemeIconToken.check => context.theme.icons.check(
      context,
      semanticsLabel: entry.id,
    ),
    _ThemeIconToken.arrowLeft => context.theme.icons.arrowLeft(
      context,
      semanticsLabel: entry.id,
    ),
    _ThemeIconToken.userRound => context.theme.icons.userRound(
      context,
      semanticsLabel: entry.id,
    ),
  };
  return IconTheme(
    key: const ValueKey('icons-selected-preview'),
    data: context.theme.style.iconStyle.copyWith(size: size),
    child: icon,
  );
}

const _icons = [
  _IconEntry(
    'search',
    'search',
    FLucideIcons.search,
    themeToken: _ThemeIconToken.search,
  ),
  _IconEntry(
    'calendar',
    'calendar',
    FLucideIcons.calendar,
    themeToken: _ThemeIconToken.calendar,
  ),
  _IconEntry(
    'check',
    'check',
    FLucideIcons.check,
    themeToken: _ThemeIconToken.check,
  ),
  _IconEntry(
    'back',
    'arrowLeft',
    FLucideIcons.arrowLeft,
    themeToken: _ThemeIconToken.arrowLeft,
  ),
  _IconEntry(
    'user',
    'userRound',
    FLucideIcons.userRound,
    themeToken: _ThemeIconToken.userRound,
  ),
  _IconEntry('home', 'house', FLucideIcons.house),
  _IconEntry('grid', 'layoutGrid', FLucideIcons.layoutGrid),
  _IconEntry('settings', 'settings', FLucideIcons.settings),
  _IconEntry('bell', 'bell', FLucideIcons.bell),
  _IconEntry('heart', 'heart', FLucideIcons.heart),
  _IconEntry('star', 'star', FLucideIcons.star),
  _IconEntry('info', 'info', FLucideIcons.info),
];

class _IconEntry {
  const _IconEntry(this.id, this.lucideName, this.icon, {this.themeToken});

  final String id;
  final String lucideName;
  final IconData icon;
  final _ThemeIconToken? themeToken;

  bool get supportsThemeMapping => themeToken != null;
}

enum _ThemeIconToken { search, calendar, check, arrowLeft, userRound }

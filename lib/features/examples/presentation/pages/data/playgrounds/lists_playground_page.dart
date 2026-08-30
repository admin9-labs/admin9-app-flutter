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
class ListsPlaygroundPage extends StatefulWidget {
  const ListsPlaygroundPage({super.key});

  @override
  State<ListsPlaygroundPage> createState() => _ListsPlaygroundPageState();
}

class _ListsPlaygroundPageState extends State<ListsPlaygroundPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemScrollController = ScrollController();
  bool _enabled = true;
  bool _showDescriptions = true;
  bool _fullDividers = false;
  String _layout = 'comfortable';
  Set<String> _sections = {'updates'};
  String _selectedEntry = 'updates';
  String _statusKey = 'examples.content.playgrounds.common.ready';

  String get _summary =>
      'enabled: $_enabled, descriptions: $_showDescriptions, '
      'divider: ${_fullDividers ? 'full' : 'indented'}, layout: $_layout, '
      'sections: ${_sections.join(',')}, selected: $_selectedEntry';

  String get _code =>
      '''FItemGroup(
  enabled: $_enabled,
  divider: FItemDivider.${_fullDividers ? 'full' : 'indented'},
  children: items,
)
FTileGroup(
  enabled: $_enabled,
  divider: FItemDivider.${_fullDividers ? 'full' : 'indented'},
  children: tiles,
)''';

  void _reset() {
    _formKey.currentState?.reset();
    setState(() {
      _enabled = true;
      _showDescriptions = true;
      _fullDividers = false;
      _layout = 'comfortable';
      _sections = {'updates'};
      _selectedEntry = 'updates';
      _statusKey = 'examples.content.playgrounds.common.reset_done';
    });
    if (_itemScrollController.hasClients) _itemScrollController.jumpTo(0);
  }

  @override
  void dispose() {
    _itemScrollController.dispose();
    super.dispose();
  }

  void _selectEntry(String value) => setState(() {
    _selectedEntry = value;
    _statusKey = 'examples.content.playgrounds.lists.selected';
  });

  void _setLayout(Set<String> values) {
    if (values.firstOrNull case final value?) {
      setState(() {
        _layout = value;
        _statusKey = 'examples.content.playgrounds.lists.layout_changed';
      });
    }
  }

  void _setSections(Set<String> values) => setState(() {
    _sections = values;
  });

  void _saveSelections() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _statusKey = 'common.saved');
    }
  }

  FItemDivider get _divider =>
      _fullDividers ? FItemDivider.full : FItemDivider.indented;

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.content.playgrounds.lists.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: context.maybePop)],
    ),
    child: ResponsivePageBody(
      children: [
        PlaygroundPreview(
          title: 'examples.content.playgrounds.common.preview'.tr(),
          status: _statusKey.tr(
            namedArgs: {'value': _selectedEntry, 'layout': _layout},
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              FItemGroup.builder(
                key: const ValueKey('lists-item-group'),
                scrollController: _itemScrollController,
                maxHeight: 220,
                enabled: _enabled,
                divider: _divider,
                semanticsLabel:
                    'examples.content.playgrounds.lists.content_group'.tr(),
                count: 8,
                itemBuilder: (context, index) => _item(index),
              ),
              FTileGroup(
                key: const ValueKey('lists-tile-group'),
                enabled: _enabled,
                divider: _divider,
                label: Text(
                  'examples.content.playgrounds.lists.preferences'.tr(),
                ),
                children: [
                  FSelectMenuTile<String>(
                    key: ValueKey('lists-menu-$_layout'),
                    prefix: const Icon(FLucideIcons.layoutGrid),
                    title: Text(
                      'examples.content.playgrounds.lists.layout'.tr(),
                    ),
                    subtitle: _showDescriptions
                        ? Text(
                            'examples.content.playgrounds.lists.layout_description'
                                .tr(),
                          )
                        : null,
                    selectControl: .managedRadio(
                      initial: _layout,
                      onChange: _setLayout,
                    ),
                    detailsBuilder: (_, values, _) => Text(
                      (values.firstOrNull == 'compact'
                              ? 'examples.content.playgrounds.lists.compact'
                              : 'examples.content.playgrounds.lists.comfortable')
                          .tr(),
                    ),
                    menu: [
                      FSelectTile<String>(
                        key: const ValueKey('lists-menu-comfortable-option'),
                        title: Text(
                          'examples.content.playgrounds.lists.comfortable'.tr(),
                        ),
                        value: 'comfortable',
                      ),
                      FSelectTile<String>(
                        key: const ValueKey('lists-menu-compact-option'),
                        title: Text(
                          'examples.content.playgrounds.lists.compact'.tr(),
                        ),
                        value: 'compact',
                      ),
                    ],
                  ),
                  FTile(
                    key: const ValueKey('lists-danger-tile'),
                    variant: .destructive,
                    prefix: const Icon(FLucideIcons.trash2),
                    title: Text(
                      'examples.content.playgrounds.lists.clear_cache'.tr(),
                    ),
                    subtitle: _showDescriptions
                        ? Text(
                            'examples.content.playgrounds.lists.clear_cache_description'
                                .tr(),
                          )
                        : null,
                    suffix: const Icon(FLucideIcons.chevronRight),
                    onPress: () => setState(
                      () => _statusKey =
                          'examples.content.playgrounds.lists.cache_cleared',
                    ),
                  ),
                  FTile(
                    key: const ValueKey('lists-disabled-tile'),
                    enabled: false,
                    prefix: const Icon(FLucideIcons.lock),
                    title: Text('common.loading'.tr()),
                    subtitle: Text('common.error_message'.tr()),
                    suffix: const Icon(FLucideIcons.lock),
                  ),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    FSelectTileGroup<String>(
                      key: ValueKey('lists-layout-group-$_layout'),
                      enabled: _enabled,
                      control: .managedRadio(
                        initial: _layout,
                        onChange: _setLayout,
                      ),
                      label: Text(
                        'examples.content.playgrounds.lists.layout'.tr(),
                      ),
                      children: [
                        FSelectTile<String>(
                          title: Text(
                            'examples.content.playgrounds.lists.comfortable'
                                .tr(),
                          ),
                          value: 'comfortable',
                        ),
                        FSelectTile<String>(
                          key: const ValueKey('lists-layout-compact'),
                          title: Text(
                            'examples.content.playgrounds.lists.compact'.tr(),
                          ),
                          value: 'compact',
                        ),
                      ],
                    ),
                    FSelectTileGroup<String>(
                      key: const ValueKey('lists-sections-group'),
                      enabled: _enabled,
                      control: .lifted(
                        value: _sections,
                        onChange: _setSections,
                      ),
                      label: Text(
                        'examples.content.playgrounds.lists.content_group'.tr(),
                      ),
                      validator: (values) => (values?.isEmpty ?? true)
                          ? 'common.error_message'.tr()
                          : null,
                      children: [
                        FSelectTile<String>(
                          key: const ValueKey('lists-section-updates'),
                          title: Text(
                            'examples.content.playgrounds.lists.updates'.tr(),
                          ),
                          value: 'updates',
                        ),
                        FSelectTile<String>(
                          key: const ValueKey('lists-section-members'),
                          title: Text(
                            'examples.content.playgrounds.lists.members'.tr(),
                          ),
                          value: 'members',
                        ),
                      ],
                    ),
                    FSelectTileGroup<String>(
                      key: const ValueKey('lists-disabled-select-group'),
                      enabled: false,
                      control: const .managedRadio(initial: 'locked'),
                      label: Text('common.loading'.tr()),
                      children: [
                        FSelectTile<String>(
                          title: Text('common.loading'.tr()),
                          value: 'locked',
                        ),
                      ],
                    ),
                    FButton(
                      key: const ValueKey('lists-save-selection'),
                      onPress: _enabled ? _saveSelections : null,
                      child: Text('common.save'.tr()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ComponentExampleSection(
          title: 'examples.content.playgrounds.common.configuration'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              FSwitch(
                key: const ValueKey('lists-enabled'),
                label: Text('examples.content.playgrounds.lists.enabled'.tr()),
                value: _enabled,
                onChange: (value) => setState(() => _enabled = value),
              ),
              FSwitch(
                key: const ValueKey('lists-descriptions'),
                label: Text(
                  'examples.content.playgrounds.lists.show_descriptions'.tr(),
                ),
                value: _showDescriptions,
                onChange: (value) => setState(() => _showDescriptions = value),
              ),
              FSwitch(
                key: const ValueKey('lists-full-dividers'),
                label: Text(
                  'examples.content.playgrounds.lists.full_dividers'.tr(),
                ),
                value: _fullDividers,
                onChange: (value) => setState(() => _fullDividers = value),
              ),
            ],
          ),
        ),
        PlaygroundCodePanel(
          title: 'examples.content.playgrounds.common.current_parameters'.tr(),
          summary: _summary,
          code: _code,
        ),
        PlaygroundActionBar(
          copyLabel: 'examples.content.playgrounds.common.copy'.tr(),
          resetLabel: 'examples.content.playgrounds.common.reset'.tr(),
          onCopy: () => copyPlaygroundText(
            context,
            text: _code,
            title: 'examples.content.playgrounds.common.copied'.tr(),
            description:
                'examples.content.playgrounds.common.copied_description'.tr(),
          ),
          onReset: _reset,
        ),
      ],
    ),
  );

  FItem _item(int index) {
    final destructive = index == 6;
    final disabled = index == 7;
    final entry = index.isEven ? 'updates' : 'members';
    final title = destructive
        ? 'examples.content.playgrounds.lists.clear_cache'.tr()
        : disabled
        ? 'common.loading'.tr()
        : '${(entry == 'updates' ? 'examples.content.playgrounds.lists.updates' : 'examples.content.playgrounds.lists.members').tr()} ${index + 1}';
    return FItem(
      key: ValueKey('lists-item-$index'),
      variant: destructive ? .destructive : .primary,
      enabled: !disabled,
      prefix: Icon(
        destructive
            ? FLucideIcons.trash2
            : disabled
            ? FLucideIcons.lock
            : entry == 'updates'
            ? FLucideIcons.bell
            : FLucideIcons.users,
      ),
      title: Text(title),
      subtitle: _showDescriptions
          ? Text(
              (entry == 'updates'
                      ? 'examples.content.playgrounds.lists.updates_description'
                      : 'examples.content.playgrounds.lists.members_description')
                  .tr(),
            )
          : null,
      details: Text('${index + 1}'),
      suffix: Icon(disabled ? FLucideIcons.lock : FLucideIcons.chevronRight),
      selected: _selectedEntry == '$entry-$index',
      onPress: disabled
          ? null
          : () => destructive
                ? setState(
                    () => _statusKey =
                        'examples.content.playgrounds.lists.cache_cleared',
                  )
                : _selectEntry('$entry-$index'),
    );
  }
}

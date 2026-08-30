import 'dart:convert';

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
class OverviewPlaygroundPage extends StatefulWidget {
  const OverviewPlaygroundPage({super.key});

  @override
  State<OverviewPlaygroundPage> createState() => _OverviewPlaygroundPageState();
}

class _OverviewPlaygroundPageState extends State<OverviewPlaygroundPage> {
  static const _defaultMembers = 12;

  bool _showBadge = true;
  bool _showDescription = true;
  Set<int> _expandedSections = {0};
  bool _following = false;
  int _members = _defaultMembers;
  String _statusKey = 'examples.content.playgrounds.common.ready';

  String get _summary =>
      'showBadge: $_showBadge, showDescription: $_showDescription, '
      'expanded: ${_expandedSections.toList()}, members: $_members, '
      'following: $_following';

  String get _code =>
      '''FCard(
  child: Column(
    children: [
      FAvatar.raw(child: const Text('A9')),
      ${_showBadge ? "FBadge(child: const Text('$_members'))," : ''}
      FAccordion(
        control: FAccordionControl.lifted(
          expanded: (index) => ${_expandedSections.contains(0)},
          onChange: onExpandedChanged,
        ),
        children: projectSections,
      ),
    ],
  ),
)''';

  void _reset() => setState(() {
    _showBadge = true;
    _showDescription = true;
    _expandedSections = {0};
    _following = false;
    _members = _defaultMembers;
    _statusKey = 'examples.content.playgrounds.common.reset_done';
  });

  void _toggleFollowing() => setState(() {
    _following = !_following;
    _statusKey = _following
        ? 'examples.content.playgrounds.overview.followed'
        : 'examples.content.playgrounds.overview.unfollowed';
  });

  void _share() => setState(() {
    _statusKey = 'examples.content.playgrounds.overview.shared';
  });

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.content.playgrounds.overview.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: context.maybePop)],
    ),
    child: ResponsivePageBody(
      children: [
        PlaygroundPreview(
          title: 'examples.content.playgrounds.common.preview'.tr(),
          status: _statusKey.tr(),
          child: FCard(
            key: const ValueKey('overview-project-card'),
            builder: (context, style, _) => Padding(
              padding: style.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      FAvatar.raw(size: 48, child: const Text('A9')),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              'examples.content.playgrounds.overview.project'
                                  .tr(),
                              style: style.titleTextStyle,
                            ),
                            if (_showDescription)
                              Text(
                                'examples.content.playgrounds.overview.description'
                                    .tr(),
                                style: style.subtitleTextStyle,
                              ),
                          ],
                        ),
                      ),
                      if (_showBadge)
                        Semantics(
                          label: 'examples.content.playgrounds.overview.members'
                              .tr(namedArgs: {'count': '$_members'}),
                          excludeSemantics: true,
                          child: FBadge(
                            key: const ValueKey('overview-member-badge'),
                            variant: .secondary,
                            child: Text('$_members'),
                          ),
                        ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FBadge(
                        child: Text(
                          'examples.content.playgrounds.overview.following'
                              .tr(),
                        ),
                      ),
                      FBadge(
                        variant: .outline,
                        child: Text(
                          'examples.content.playgrounds.overview.project'.tr(),
                        ),
                      ),
                      FBadge(
                        variant: .destructive,
                        child: Text('common.error_title'.tr()),
                      ),
                    ],
                  ),
                  Semantics(
                    container: true,
                    label: 'examples.content.playgrounds.overview.members'.tr(
                      namedArgs: {'count': '$_members'},
                    ),
                    excludeSemantics: true,
                    child: Row(
                      key: const ValueKey('overview-avatar-row'),
                      spacing: 8,
                      children: [
                        FAvatar(
                          key: const ValueKey('overview-avatar-image'),
                          image: _avatarImage,
                          size: 32,
                          fallback: const Text('A9'),
                        ),
                        FAvatar(
                          key: const ValueKey('overview-avatar-fallback'),
                          image: const AssetImage(
                            'assets/missing-overview-avatar.png',
                          ),
                          size: 40,
                          fallback: const Text('CN'),
                        ),
                        FAvatar.raw(
                          key: const ValueKey('overview-avatar-raw-icon'),
                          size: 52,
                          child: const Icon(FLucideIcons.userRound),
                        ),
                        FAvatar.raw(
                          key: const ValueKey('overview-avatar-raw-text'),
                          size: 64,
                          child: const Text('UI'),
                        ),
                      ],
                    ),
                  ),
                  FAccordion(
                    key: const ValueKey('overview-accordion'),
                    control: .lifted(
                      expanded: _expandedSections.contains,
                      onChange: (index, expanded) {
                        setState(() {
                          if (expanded) {
                            _expandedSections = {..._expandedSections, index};
                          } else {
                            _expandedSections = {..._expandedSections}
                              ..remove(index);
                          }
                        });
                      },
                    ),
                    children: [
                      FAccordionItem(
                        title: Text(
                          'examples.content.playgrounds.overview.progress_title'
                              .tr(),
                        ),
                        child: Text(
                          'examples.content.playgrounds.overview.progress_body'
                              .tr(),
                        ),
                      ),
                      FAccordionItem(
                        title: Text('common.error_title'.tr()),
                        child: Text('common.error_message'.tr()),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FButton(
                        key: const ValueKey('overview-follow'),
                        variant: _following ? .secondary : .primary,
                        selected: _following,
                        mainAxisSize: .min,
                        prefix: Icon(
                          _following ? FLucideIcons.check : FLucideIcons.bell,
                        ),
                        onPress: _toggleFollowing,
                        child: Text(
                          (_following
                                  ? 'examples.content.playgrounds.overview.following'
                                  : 'examples.content.playgrounds.overview.follow')
                              .tr(),
                        ),
                      ),
                      FButton(
                        key: const ValueKey('overview-share'),
                        variant: .outline,
                        mainAxisSize: .min,
                        prefix: const Icon(FLucideIcons.share2),
                        onPress: _share,
                        child: Text(
                          'examples.content.playgrounds.overview.share'.tr(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        ComponentExampleSection(
          title: 'examples.content.playgrounds.common.configuration'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              FSwitch(
                key: const ValueKey('overview-show-badge'),
                label: Text(
                  'examples.content.playgrounds.overview.show_badge'.tr(),
                ),
                value: _showBadge,
                onChange: (value) => setState(() => _showBadge = value),
              ),
              FSwitch(
                key: const ValueKey('overview-show-description'),
                label: Text(
                  'examples.content.playgrounds.overview.show_description'.tr(),
                ),
                value: _showDescription,
                onChange: (value) => setState(() => _showDescription = value),
              ),
              FSwitch(
                key: const ValueKey('overview-expanded'),
                label: Text(
                  'examples.content.playgrounds.overview.expanded'.tr(),
                ),
                value: _expandedSections.isNotEmpty,
                onChange: (value) =>
                    setState(() => _expandedSections = value ? {0} : <int>{}),
              ),
              Text(
                'examples.content.playgrounds.overview.member_count'.tr(
                  namedArgs: {'count': '$_members'},
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FButton.icon(
                    key: const ValueKey('overview-members-decrease'),
                    variant: .outline,
                    semanticsLabel:
                        'examples.content.playgrounds.overview.decrease'.tr(),
                    onPress: _members > 1
                        ? () => setState(() => _members--)
                        : null,
                    child: const Icon(FLucideIcons.minus),
                  ),
                  FButton.icon(
                    key: const ValueKey('overview-members-increase'),
                    variant: .outline,
                    semanticsLabel:
                        'examples.content.playgrounds.overview.increase'.tr(),
                    onPress: () => setState(() => _members++),
                    child: const Icon(FLucideIcons.plus),
                  ),
                ],
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
}

final MemoryImage _avatarImage = MemoryImage(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

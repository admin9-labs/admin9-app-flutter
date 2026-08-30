import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class ContentBasicsPage extends StatelessWidget {
  const ContentBasicsPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('content.basics.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'content.basics.card.section_title'.tr(),
          description: 'content.basics.card.description'.tr(),
          child: FCard(
            builder: (context, style, _) => Padding(
              padding: style.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  DefaultTextStyle.merge(
                    style: style.titleTextStyle,
                    child: Text('content.basics.card.title'.tr()),
                  ),
                  DefaultTextStyle.merge(
                    style: style.subtitleTextStyle,
                    child: Text('content.basics.card.subtitle'.tr()),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      FAvatar.raw(child: const Text('A9')),
                      Expanded(child: Text('content.basics.card.owner'.tr())),
                      FBadge(
                        variant: FBadgeVariant.secondary,
                        child: Text('content.basics.card.badge'.tr()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        ComponentExampleSection(
          title: 'content.basics.avatar.section_title'.tr(),
          description: 'content.basics.avatar.description'.tr(),
          child: Row(
            spacing: 12,
            children: [
              FAvatar.raw(child: const Text('A9')),
              FAvatar.raw(
                child: Icon(
                  FLucideIcons.userRound,
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              FAvatar.raw(size: 52, child: const Text('CN')),
            ],
          ),
        ),
        ComponentExampleSection(
          title: 'content.basics.badge.section_title'.tr(),
          description: 'content.basics.badge.description'.tr(),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FBadge(child: Text('content.basics.badge.primary'.tr())),
              FBadge(
                variant: FBadgeVariant.secondary,
                child: Text('content.basics.badge.secondary'.tr()),
              ),
              FBadge(
                variant: FBadgeVariant.outline,
                child: Text('content.basics.badge.outline'.tr()),
              ),
              FBadge(
                variant: FBadgeVariant.destructive,
                child: Text('content.basics.badge.destructive'.tr()),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

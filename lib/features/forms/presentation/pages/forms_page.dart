import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class FormsPage extends StatelessWidget {
  const FormsPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader(title: Text('forms.title'.tr())),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'forms.catalog.title'.tr(),
          description: 'forms.catalog.description'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              _CatalogButton(
                label: 'forms.catalog.buttons_labels'.tr(),
                onPress: () => context.pushRoute(const ButtonsLabelsRoute()),
              ),
              _CatalogButton(
                label: 'forms.catalog.text_input'.tr(),
                onPress: () => context.pushRoute(const TextInputRoute()),
              ),
              _CatalogButton(
                label: 'forms.catalog.toggles_groups'.tr(),
                onPress: () => context.pushRoute(const TogglesGroupsRoute()),
              ),
              _CatalogButton(
                label: 'forms.catalog.select_range'.tr(),
                onPress: () => context.pushRoute(const SelectRangeRoute()),
              ),
              _CatalogButton(
                label: 'forms.catalog.date_time'.tr(),
                onPress: () => context.pushRoute(const DateTimeRoute()),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CatalogButton extends StatelessWidget {
  const _CatalogButton({required this.label, required this.onPress});

  final String label;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) => FButton(
    variant: .outline,
    onPress: onPress,
    suffix: context.theme.icons.chevronRight(context),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(label),
    ),
  );
}

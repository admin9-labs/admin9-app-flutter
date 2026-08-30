import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class AccordionPage extends StatelessWidget {
  const AccordionPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('content.accordion.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'content.accordion.section_title'.tr(),
          description: 'content.accordion.description'.tr(),
          child: FAccordion(
            control: const .managed(max: 2),
            children: [
              FAccordionItem(
                initiallyExpanded: true,
                title: Text('content.accordion.theme.title'.tr()),
                child: Text('content.accordion.theme.body'.tr()),
              ),
              FAccordionItem(
                title: Text('content.accordion.mobile.title'.tr()),
                child: Text('content.accordion.mobile.body'.tr()),
              ),
              FAccordionItem(
                title: Text('content.accordion.accessibility.title'.tr()),
                child: Text('content.accordion.accessibility.body'.tr()),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

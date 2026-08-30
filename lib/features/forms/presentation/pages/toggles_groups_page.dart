import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class TogglesGroupsPage extends StatefulWidget {
  const TogglesGroupsPage({super.key});

  @override
  State<TogglesGroupsPage> createState() => _TogglesGroupsPageState();
}

class _TogglesGroupsPageState extends State<TogglesGroupsPage> {
  bool _switchValue = true;
  bool _checkboxValue = false;
  bool _radioValue = true;

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('forms.toggles_groups.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'forms.toggles_groups.controls'.tr(),
          child: Column(
            spacing: 16,
            children: [
              FSwitch(
                leadingLabel: true,
                label: Text('forms.toggles_groups.switch_label'.tr()),
                description: Text(
                  'forms.toggles_groups.switch_description'.tr(),
                ),
                value: _switchValue,
                onChange: (value) => setState(() => _switchValue = value),
              ),
              FCheckbox(
                label: Text('forms.toggles_groups.checkbox_label'.tr()),
                value: _checkboxValue,
                onChange: (value) => setState(() => _checkboxValue = value),
              ),
              FRadio(
                label: Text('forms.toggles_groups.radio_label'.tr()),
                value: _radioValue,
                onChange: (value) => setState(() => _radioValue = value),
              ),
            ],
          ),
        ),
        ComponentExampleSection(
          title: 'forms.toggles_groups.radio_group'.tr(),
          child: FSelectGroup<String>(
            control: const .managedRadio(initial: 'daily'),
            children: [
              .radio(
                value: 'daily',
                label: Text('forms.toggles_groups.daily'.tr()),
              ),
              .radio(
                value: 'weekly',
                label: Text('forms.toggles_groups.weekly'.tr()),
              ),
              .radio(
                value: 'never',
                label: Text('forms.toggles_groups.never'.tr()),
              ),
            ],
          ),
        ),
        ComponentExampleSection(
          title: 'forms.toggles_groups.checkbox_group'.tr(),
          child: FSelectGroup<String>(
            control: const .managed(initial: {'email'}),
            children: [
              .checkbox(
                value: 'email',
                label: Text('forms.toggles_groups.email'.tr()),
              ),
              .checkbox(
                value: 'push',
                label: Text('forms.toggles_groups.push'.tr()),
              ),
              .checkbox(
                value: 'sms',
                label: Text('forms.toggles_groups.sms'.tr()),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

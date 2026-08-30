import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class SelectRangePage extends StatelessWidget {
  const SelectRangePage({super.key});

  @override
  Widget build(BuildContext context) {
    final priorities = {
      'forms.select_range.priority_low'.tr(): 'low',
      'forms.select_range.priority_medium'.tr(): 'medium',
      'forms.select_range.priority_high'.tr(): 'high',
    };
    final channels = {
      'forms.select_range.channel_email'.tr(): 'email',
      'forms.select_range.channel_push'.tr(): 'push',
      'forms.select_range.channel_sms'.tr(): 'sms',
    };

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text('forms.select_range.title'.tr()),
        prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
      ),
      child: ResponsivePageBody(
        children: [
          ComponentExampleSection(
            title: 'forms.select_range.select'.tr(),
            child: FSelect<String>(
              items: priorities,
              label: Text('forms.select_range.priority_label'.tr()),
              hint: 'forms.select_range.priority_hint'.tr(),
              clearable: true,
            ),
          ),
          ComponentExampleSection(
            title: 'forms.select_range.multi_select'.tr(),
            child: FMultiSelect<String>(
              items: channels,
              label: Text('forms.select_range.channels_label'.tr()),
              hint: Text('forms.select_range.channels_hint'.tr()),
              clearable: true,
            ),
          ),
          ComponentExampleSection(
            title: 'forms.select_range.slider'.tr(),
            child: FSlider(
              label: Text('forms.select_range.slider_label'.tr()),
              description: Text('forms.select_range.slider_description'.tr()),
              control: .managedContinuous(
                initial: FSliderValue(max: 0.45),
                stepPercentage: 0.05,
              ),
            ),
          ),
          ComponentExampleSection(
            title: 'forms.select_range.range_slider'.tr(),
            child: FSlider(
              label: Text('forms.select_range.range_label'.tr()),
              control: .managedContinuousRange(
                initial: FSliderValue(min: 0.2, max: 0.75),
                stepPercentage: 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

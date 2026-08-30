import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class DateTimePage extends StatelessWidget {
  const DateTimePage({super.key});

  @override
  Widget build(BuildContext context) {
    final periods = [
      'forms.date_time.picker_first'.tr(),
      'forms.date_time.picker_second'.tr(),
      'forms.date_time.picker_third'.tr(),
    ];

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text('forms.date_time.title'.tr()),
        prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
      ),
      child: ResponsivePageBody(
        children: [
          ComponentExampleSection(
            title: 'forms.date_time.date_field'.tr(),
            child: FDateField.calendar(
              label: Text('forms.date_time.date_label'.tr()),
              calendar: const FDateFieldWheelCalendarProperties(),
              clearable: true,
            ),
          ),
          ComponentExampleSection(
            title: 'forms.date_time.time_field'.tr(),
            child: FTimeField.picker(
              label: Text('forms.date_time.time_label'.tr()),
              clearable: true,
            ),
          ),
          ComponentExampleSection(
            title: 'forms.date_time.picker'.tr(),
            child: SizedBox(
              height: 180,
              child: FPicker(
                control: const .managed(initial: [1]),
                children: [
                  FPickerWheel(
                    semanticsLabel: 'forms.date_time.picker_semantics'.tr(),
                    semanticsValueBuilder: (index) => periods[index],
                    children: [for (final period in periods) Text(period)],
                  ),
                ],
              ),
            ),
          ),
          ComponentExampleSection(
            title: 'forms.date_time.date_time_picker'.tr(),
            child: const SizedBox(height: 180, child: FDateTimePicker()),
          ),
          ComponentExampleSection(
            title: 'forms.date_time.time_picker'.tr(),
            child: const SizedBox(height: 180, child: FTimePicker()),
          ),
        ],
      ),
    );
  }
}

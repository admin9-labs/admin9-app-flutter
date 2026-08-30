import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  static final _today = DateTime.utc(2026, 8, 30);
  static final _start = DateTime.utc(2025);
  static final _end = DateTime.utc(2028);

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('content.calendar.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'content.calendar.grid.title'.tr(),
          description: 'content.calendar.grid.description'.tr(),
          child: FCalendar.grid(
            control: FGridCalendarControl(
              start: _start,
              today: _today,
              initial: _today,
              end: _end,
            ),
            selectionControl: FDateSelectionControl.managedSingle(
              initial: _today,
            ),
            fixedWeeks: true,
          ),
        ),
        ComponentExampleSection(
          title: 'content.calendar.wheel.title'.tr(),
          description: 'content.calendar.wheel.description'.tr(),
          child: FCalendar.wheel(
            control: FWheelCalendarControl(
              start: _start,
              today: _today,
              initial: _today,
              end: _end,
            ),
            selectionControl: FDateSelectionControl.managedSingle(
              initial: _today,
            ),
          ),
        ),
      ],
    ),
  );
}

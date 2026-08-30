import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class LineCalendarPage extends StatelessWidget {
  const LineCalendarPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('content.line_calendar.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'content.line_calendar.section_title'.tr(),
          description: 'content.line_calendar.description'.tr(),
          child: FLineCalendar(
            control: .managed(initial: DateTime.utc(2026, 8, 31)),
            selectable: (date) => date.weekday != DateTime.sunday,
            builder: _mobileLineCalendarItem,
          ),
        ),
      ],
    ),
  );
}

Widget _mobileLineCalendarItem(
  BuildContext context,
  FLineCalendarItemData data,
  Widget? child,
) {
  final style = data.style;
  final localizations = FLocalizations.of(context) ?? FDefaultLocalizations();
  return Stack(
    fit: StackFit.expand,
    children: [
      DecoratedBox(
        decoration: style.decoration.resolve(data.variants),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              Text(
                localizations.shortWeekDays[data.date.weekday % 7],
                style: style.weekdayTextStyle.resolve(data.variants),
              ),
              Text(
                '${data.date.day}',
                style: style.dateTextStyle.resolve(data.variants),
              ),
            ],
          ),
        ),
      ),
      if (data.variants.contains(FLineCalendarItemVariant.today))
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: style.todayIndicatorColor.resolve(data.variants),
              shape: BoxShape.circle,
            ),
          ),
        ),
    ],
  );
}

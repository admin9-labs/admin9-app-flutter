import 'dart:math' as math;

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

enum _CalendarMode { single, multiple, range }

@RoutePage()
class CalendarPlaygroundPage extends StatefulWidget {
  const CalendarPlaygroundPage({super.key});

  @override
  State<CalendarPlaygroundPage> createState() => _CalendarPlaygroundPageState();
}

class _CalendarPlaygroundPageState extends State<CalendarPlaygroundPage> {
  static final _today = DateTime.utc(2026, 8, 31);
  static final _start = DateTime.utc(2026, 8, 1);
  static final _end = DateTime.utc(2026, 10, 31);
  static final _blockedDates = {DateTime.utc(2026, 9, 8)};

  late final FGridCalendarController _calendarController;
  late final FLineCalendarScrollController _lineScrollController;
  _CalendarMode _mode = _CalendarMode.single;
  bool _excludeWeekends = true;
  bool _showLineCalendar = true;
  DateTime? _singleDate = _today;
  Set<DateTime> _multipleDates = {_today, DateTime.utc(2026, 9, 2)};
  (DateTime, DateTime)? _range = (_today, DateTime.utc(2026, 9, 2));
  DateTime? _lineDate = _today;
  String _statusKey = 'examples.content.playgrounds.common.ready';

  String get _summary =>
      'mode: ${_mode.name}, '
      'excludeWeekends: $_excludeWeekends, '
      'lineCalendar: $_showLineCalendar, selection: ${_selectionText()}';

  String get _code =>
      '''FCalendar.grid(
  control: FGridCalendarControl(selectable: selectable),
  selectionControl: FDateSelectionControl.${switch (_mode) {
        _CalendarMode.single => 'liftedSingle',
        _CalendarMode.multiple => 'liftedMulti',
        _CalendarMode.range => 'liftedRange',
      }}(
    value: ${switch (_mode) {
        _CalendarMode.single => 'selectedDate',
        _CalendarMode.multiple => 'selectedDates',
        _CalendarMode.range => 'selectedRange',
      }},
    onChange: onSelectionChanged,
  ),
)
${_showLineCalendar ? 'FLineCalendar(control: FLineCalendarControl.lifted(...))' : ''}''';

  @override
  void initState() {
    super.initState();
    _calendarController = FGridCalendarController(
      start: _start,
      today: _today,
      initial: _today,
      end: _end,
      selectable: _selectable,
    );
    _lineScrollController = FLineCalendarScrollController(
      start: _start,
      end: _end.add(const Duration(days: 1)),
      today: _today,
      initialDate: _today,
    );
  }

  @override
  void dispose() {
    _lineScrollController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  bool _selectable(DateTime date) =>
      !_blockedDates.contains(date) &&
      (!_excludeWeekends ||
          (date.weekday != DateTime.saturday &&
              date.weekday != DateTime.sunday));

  String _date(DateTime? value) => value == null
      ? '-'
      : '${value.year}-${value.month.toString().padLeft(2, '0')}-'
            '${value.day.toString().padLeft(2, '0')}';

  String _selectionText() {
    return switch (_mode) {
      _CalendarMode.single => _date(_singleDate),
      _CalendarMode.multiple =>
        (_multipleDates.map(_date).toList()..sort()).join(','),
      _CalendarMode.range => switch (_range) {
        null => '-',
        final range => '${_date(range.$1)}..${_date(range.$2)}',
      },
    };
  }

  void _reset() => setState(() {
    _mode = _CalendarMode.single;
    _excludeWeekends = true;
    _showLineCalendar = true;
    _singleDate = _today;
    _multipleDates = {_today, DateTime.utc(2026, 9, 2)};
    _range = (_today, DateTime.utc(2026, 9, 2));
    _lineDate = _today;
    _statusKey = 'examples.content.playgrounds.common.reset_done';
    _calendarController.jumpToDayPicker(_today);
    if (_lineScrollController.hasClients) {
      _lineScrollController.jumpToDate(_today);
    }
  });

  Widget _calendar(BuildContext context) {
    final dayExtent = math.max(
      44.0,
      MediaQuery.textScalerOf(context).scale(28),
    );
    final style = FCalendarStyleDelta.delta(
      dayPickerStyle: FCalendarDayPickerStyleDelta.delta(
        daySize: Size.square(dayExtent),
      ),
    );
    final control = FGridCalendarControl(controller: _calendarController);
    return switch (_mode) {
      _CalendarMode.range => FCalendar.grid(
        key: const ValueKey('calendar-playground-range'),
        style: style,
        control: control,
        selectionControl: FDateSelectionControl.liftedRange(
          value: _range,
          onChange: (value) => setState(() {
            _range = value;
            _statusKey = 'examples.content.playgrounds.calendar.changed';
          }),
        ),
        fixedWeeks: true,
      ),
      _CalendarMode.multiple => FCalendar.grid(
        key: const ValueKey('calendar-playground-multiple'),
        style: style,
        control: control,
        selectionControl: FDateSelectionControl.liftedMulti(
          value: _multipleDates,
          onChange: (value) => setState(() {
            _multipleDates = value;
            _statusKey = 'examples.content.playgrounds.calendar.changed';
          }),
        ),
        fixedWeeks: true,
      ),
      _CalendarMode.single => FCalendar.grid(
        key: const ValueKey('calendar-playground-single'),
        style: style,
        control: control,
        selectionControl: FDateSelectionControl.liftedSingle(
          value: _singleDate,
          onChange: (value) => setState(() {
            _singleDate = value;
            _statusKey = 'examples.content.playgrounds.calendar.changed';
          }),
        ),
        fixedWeeks: true,
      ),
    };
  }

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.content.playgrounds.calendar.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: context.maybePop)],
    ),
    child: ResponsivePageBody(
      children: [
        PlaygroundPreview(
          title: 'examples.content.playgrounds.common.preview'.tr(),
          status: '${_statusKey.tr()}：${_selectionText()}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              FAlert(
                liveRegion: false,
                icon: const Icon(FLucideIcons.calendarDays),
                title: Text(
                  'examples.content.playgrounds.calendar.event_title'.tr(),
                ),
                subtitle: Text(
                  'examples.content.playgrounds.calendar.event_description'
                      .tr(),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final minimumWidth = MediaQuery.textScalerOf(context)
                      .scale(220);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: math.max(constraints.maxWidth, minimumWidth),
                      ),
                      child: _calendar(context),
                    ),
                  );
                },
              ),
              if (_showLineCalendar)
                FLineCalendar(
                  key: const ValueKey('calendar-playground-line'),
                  control: .lifted(
                    date: _lineDate,
                    onChange: (date) => setState(() {
                      _lineDate = date;
                      _singleDate = date;
                      _statusKey =
                          'examples.content.playgrounds.calendar.changed';
                    }),
                  ),
                  scrollControl: FLineCalendarScrollControl.managed(
                    controller: _lineScrollController,
                  ),
                  style: .delta(
                    contentEdgeSpacing: MediaQuery.textScalerOf(context)
                        .scale(16),
                  ),
                  selectable: _selectable,
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
              Text('examples.content.playgrounds.calendar.selection_mode'.tr()),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FButton(
                    key: const ValueKey('calendar-mode-single'),
                    variant: .outline,
                    selected: _mode == _CalendarMode.single,
                    mainAxisSize: .min,
                    onPress: () => setState(() => _mode = _CalendarMode.single),
                    child: Text(
                      'examples.content.playgrounds.calendar.single'.tr(),
                    ),
                  ),
                  FButton(
                    key: const ValueKey('calendar-mode-multiple'),
                    variant: .outline,
                    selected: _mode == _CalendarMode.multiple,
                    mainAxisSize: .min,
                    onPress: () =>
                        setState(() => _mode = _CalendarMode.multiple),
                    child: Text(
                      'examples.content.playgrounds.calendar.multiple'.tr(),
                    ),
                  ),
                  FButton(
                    key: const ValueKey('calendar-mode-range'),
                    variant: .outline,
                    selected: _mode == _CalendarMode.range,
                    mainAxisSize: .min,
                    onPress: () => setState(() => _mode = _CalendarMode.range),
                    child: Text(
                      'examples.content.playgrounds.calendar.range'.tr(),
                    ),
                  ),
                ],
              ),
              FSwitch(
                key: const ValueKey('calendar-exclude-weekends'),
                label: Text(
                  'examples.content.playgrounds.calendar.exclude_weekends'.tr(),
                ),
                value: _excludeWeekends,
                onChange: (value) => setState(() => _excludeWeekends = value),
              ),
              FSwitch(
                key: const ValueKey('calendar-show-line'),
                label: Text(
                  'examples.content.playgrounds.calendar.show_line'.tr(),
                ),
                value: _showLineCalendar,
                onChange: (value) => setState(() => _showLineCalendar = value),
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

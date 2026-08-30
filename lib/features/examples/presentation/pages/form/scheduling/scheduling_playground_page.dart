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
class SchedulingPlaygroundPage extends StatefulWidget {
  const SchedulingPlaygroundPage({super.key});

  @override
  State<SchedulingPlaygroundPage> createState() =>
      _SchedulingPlaygroundPageState();
}

class _SchedulingPlaygroundPageState extends State<SchedulingPlaygroundPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final FDateTimePickerController _dateTimeController;
  late final FTimePickerController _timePickerController;
  late final FTimeFieldController _timeInputController;
  late final FPopoverController _timePopoverController;
  DateTime _dateTime = DateTime(2026, 9, 8, 14, 30);
  DateTime? _date = DateTime(2026, 9, 8);
  FTime? _time = const FTime(14, 30);
  FTime _wheelTime = const FTime(14, 30);
  String _dateMode = 'calendar';
  bool _popoverShown = false;
  bool _hour24 = true;
  bool _enabled = true;
  int _minuteInterval = 15;
  String _status = 'examples.forms.playgrounds.common.ready'.tr();

  @override
  void initState() {
    super.initState();
    _dateTimeController = FDateTimePickerController(dateTime: _dateTime);
    _timePickerController = FTimePickerController(time: _wheelTime);
    _timeInputController = FTimeFieldController(
      time: const FTime(9, 30),
      validator: (value) => value == null
          ? 'examples.forms.playgrounds.scheduling.validation_failed'.tr()
          : null,
    );
    _timePopoverController = FPopoverController(vsync: this);
  }

  String get _summary =>
      'hour24: $_hour24, minuteInterval: $_minuteInterval, '
      'enabled: $_enabled, dateField: $_dateMode, '
      'popoverShown: $_popoverShown, dateTime: ${_dateTime.toIso8601String()}';

  String get _code =>
      '''FDateTimePicker(
  control: FDateTimePickerControl.lifted(
    dateTime: DateTime(2026, 9, 8, ${_dateTime.hour}, ${_dateTime.minute}),
    onChange: updateSchedule,
  ),
  hour24: $_hour24,
  minuteInterval: $_minuteInterval,
)''';

  void _save() {
    final valid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _status = !valid || _date == null || _time == null
          ? 'examples.forms.playgrounds.scheduling.validation_failed'.tr()
          : 'examples.forms.playgrounds.scheduling.saved'.tr();
    });
  }

  void _handleDateTimeChange(DateTime value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || value == _dateTime) return;
      setState(() {
        _dateTime = value;
        _status = value.toIso8601String();
      });
    });
  }

  void _handleWheelTimeChange(FTime value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || value == _wheelTime) return;
      setState(() {
        _wheelTime = value;
        _status = value.toString();
      });
    });
  }

  void _reset() => setState(() {
    _dateTime = DateTime(2026, 9, 8, 14, 30);
    _dateTimeController.value = _dateTime;
    _wheelTime = const FTime(14, 30);
    _timePickerController.value = _wheelTime;
    _timeInputController.value = const FTime(9, 30);
    _date = DateTime(2026, 9, 8);
    _time = const FTime(14, 30);
    _dateMode = 'calendar';
    _popoverShown = false;
    _hour24 = true;
    _enabled = true;
    _minuteInterval = 15;
    _status = 'examples.forms.playgrounds.common.reset_done'.tr();
  });

  Future<void> _copy() => copyPlaygroundText(
    context,
    text: _code,
    title: 'examples.forms.playgrounds.common.copied'.tr(),
    description: 'examples.forms.playgrounds.common.copied_description'.tr(),
  );

  @override
  void dispose() {
    _dateTimeController.dispose();
    _timePickerController.dispose();
    _timeInputController.dispose();
    _timePopoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.forms.playgrounds.scheduling.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        PlaygroundPreview(
          title: 'examples.forms.playgrounds.common.preview'.tr(),
          status: _status,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Text('examples.forms.playgrounds.scheduling.scenario'.tr()),
                if (_dateMode == 'input')
                  FDateField.input(
                    key: const ValueKey('schedule-date-field-input'),
                    selectionControl: FDateSelectionControl.liftedSingle(
                      value: _date,
                      onChange: (value) => setState(() => _date = value),
                      toggleable: false,
                    ),
                    enabled: _enabled,
                    label: Text(
                      'examples.forms.playgrounds.scheduling.date'.tr(),
                    ),
                    validator: (value) => value == null
                        ? 'examples.forms.playgrounds.scheduling.validation_failed'
                              .tr()
                        : null,
                    formFieldKey: const ValueKey('schedule-date-form-field'),
                  )
                else
                  FDateField.calendar(
                    key: const ValueKey('schedule-date-field-calendar'),
                    selectionControl: FDateSelectionControl.liftedSingle(
                      value: _date,
                      onChange: (value) => setState(() => _date = value),
                      toggleable: false,
                    ),
                    enabled: _enabled,
                    clearable: true,
                    label: Text(
                      'examples.forms.playgrounds.scheduling.date'.tr(),
                    ),
                    validator: (value) => value == null
                        ? 'examples.forms.playgrounds.scheduling.validation_failed'
                              .tr()
                        : null,
                    formFieldKey: const ValueKey('schedule-date-form-field'),
                    calendar: FDateFieldGridCalendarProperties(
                      control: FGridCalendarControl(
                        start: DateTime.utc(2026),
                        initial: DateTime.utc(2026, 9, 8),
                        today: DateTime.utc(2026, 9, 8),
                        end: DateTime.utc(2027),
                      ),
                    ),
                  ),
                FTimeField(
                  key: const ValueKey('schedule-time-field-input'),
                  control: .managed(
                    controller: _timeInputController,
                    onChange: (value) => setState(() {
                      _status = value?.toString() ?? '';
                    }),
                  ),
                  enabled: _enabled,
                  clearable: true,
                  hour24: _hour24,
                  label: Text(
                    'examples.forms.playgrounds.scheduling.time_input'.tr(),
                  ),
                  formFieldKey: const ValueKey(
                    'schedule-time-input-form-field',
                  ),
                ),
                FTimeField.picker(
                  key: const ValueKey('schedule-time-field-picker'),
                  control: .lifted(
                    time: _time,
                    onChange: (value) => setState(() => _time = value),
                  ),
                  popoverControl: .managed(
                    controller: _timePopoverController,
                    onChange: (shown) => setState(() => _popoverShown = shown),
                  ),
                  enabled: _enabled,
                  clearable: true,
                  hour24: _hour24,
                  minuteInterval: _minuteInterval,
                  label: Text(
                    'examples.forms.playgrounds.scheduling.time'.tr(),
                  ),
                ),
                SizedBox(
                  height: 240,
                  child: FDateTimePicker(
                    key: const ValueKey('schedule-preview-picker'),
                    control: .managed(
                      controller: _dateTimeController,
                      onChange: _handleDateTimeChange,
                    ),
                    hour24: _hour24,
                    dayInterval: 1,
                    hourInterval: 1,
                    minuteInterval: _minuteInterval,
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: FTimePicker(
                    key: const ValueKey('schedule-preview-time-picker'),
                    control: .managed(
                      controller: _timePickerController,
                      onChange: _handleWheelTimeChange,
                    ),
                    hour24: _hour24,
                    hourInterval: 1,
                    minuteInterval: _minuteInterval,
                  ),
                ),
                FButton(
                  key: const ValueKey('schedule-save'),
                  onPress: _enabled ? _save : null,
                  child: Text(
                    'examples.forms.playgrounds.scheduling.confirm'.tr(),
                  ),
                ),
              ],
            ),
          ),
        ),
        ComponentExampleSection(
          title: 'examples.forms.playgrounds.common.configuration'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              Text(
                'examples.forms.playgrounds.scheduling.date_field_mode'.tr(),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mode in const ['input', 'calendar'])
                    FButton(
                      key: ValueKey('schedule-date-mode-$mode'),
                      variant: .outline,
                      selected: _dateMode == mode,
                      mainAxisSize: .min,
                      onPress: () => setState(() => _dateMode = mode),
                      child: Text(
                        mode == 'input'
                            ? 'examples.forms.playgrounds.scheduling.date_mode.input'
                                  .tr()
                            : 'examples.forms.playgrounds.scheduling.date_mode.calendar'
                                  .tr(),
                      ),
                    ),
                ],
              ),
              FSwitch(
                key: const ValueKey('schedule-hour24-toggle'),
                label: Text(
                  'examples.forms.playgrounds.scheduling.hour24'.tr(),
                ),
                value: _hour24,
                onChange: (value) => setState(() => _hour24 = value),
              ),
              FSwitch(
                label: Text('examples.forms.playgrounds.common.enabled'.tr()),
                value: _enabled,
                onChange: (value) => setState(() => _enabled = value),
              ),
              Text(
                'examples.forms.playgrounds.scheduling.minute_interval'.tr(),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final interval in const [5, 15, 30])
                    FButton(
                      key: ValueKey('schedule-minute-$interval'),
                      variant: .outline,
                      selected: _minuteInterval == interval,
                      mainAxisSize: .min,
                      onPress: () => setState(() => _minuteInterval = interval),
                      child: Text('$interval'),
                    ),
                ],
              ),
            ],
          ),
        ),
        PlaygroundCodePanel(
          title: 'examples.forms.playgrounds.common.current_parameters'.tr(),
          summary: _summary,
          code: _code,
        ),
        PlaygroundActionBar(
          copyLabel: 'examples.forms.playgrounds.common.copy'.tr(),
          resetLabel: 'examples.forms.playgrounds.common.reset'.tr(),
          onCopy: _copy,
          onReset: _reset,
        ),
      ],
    ),
  );
}

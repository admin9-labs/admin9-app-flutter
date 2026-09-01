import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class ValueControlsPlaygroundPage extends StatefulWidget {
  const ValueControlsPlaygroundPage({super.key});

  @override
  State<ValueControlsPlaygroundPage> createState() =>
      _ValueControlsPlaygroundPageState();
}

class _ValueControlsPlaygroundPageState
    extends State<ValueControlsPlaygroundPage> {
  late final FPickerController _pickerController;
  FSliderValue _value = FSliderValue(
    max: 0.45,
    constraints: (min: 0.25, max: 0.75),
  );
  FSliderValue _range = FSliderValue(min: 0.2, max: 0.75);
  List<int> _pickerIndexes = [1, 0];
  bool _rangeMode = false;
  bool _enabled = true;
  double _step = 0.05;
  String _status = 'value: 45%';

  @override
  void initState() {
    super.initState();
    _pickerController = FPickerController(indexes: _pickerIndexes);
    _pickerController.addListener(_handlePickerChange);
  }

  void _handlePickerChange() {
    final indexes = _pickerController.value;
    if (!mounted || indexes == _pickerIndexes) return;
    setState(() {
      _pickerIndexes = indexes;
      final periods = [
        'examples.forms.playgrounds.value_controls.morning'.tr(),
        'examples.forms.playgrounds.value_controls.afternoon'.tr(),
        'examples.forms.playgrounds.value_controls.evening'.tr(),
      ];
      final channels = [
        'examples.forms.playgrounds.value_controls.email'.tr(),
        'examples.forms.playgrounds.value_controls.push'.tr(),
        'examples.forms.playgrounds.value_controls.sms'.tr(),
      ];
      _status = '${periods[indexes[0]]}/${channels[indexes[1]]}';
    });
  }

  void _reset() => setState(() {
    _value = FSliderValue(max: 0.45, constraints: (min: 0.25, max: 0.75));
    _range = FSliderValue(min: 0.2, max: 0.75);
    _pickerIndexes = [1, 0];
    _pickerController.value = _pickerIndexes;
    _rangeMode = false;
    _enabled = true;
    _step = 0.05;
    _status = 'value: 45%';
  });

  @override
  void dispose() {
    _pickerController.removeListener(_handlePickerChange);
    _pickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final periods = [
      'examples.forms.playgrounds.value_controls.morning'.tr(),
      'examples.forms.playgrounds.value_controls.afternoon'.tr(),
      'examples.forms.playgrounds.value_controls.evening'.tr(),
    ];
    final channels = [
      'examples.forms.playgrounds.value_controls.email'.tr(),
      'examples.forms.playgrounds.value_controls.push'.tr(),
      'examples.forms.playgrounds.value_controls.sms'.tr(),
    ];

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text('examples.forms.playgrounds.value_controls.title'.tr()),
        prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
      ),
      child: ResponsivePageBody(
        children: [
          PlaygroundPreview(
            title: 'examples.forms.playgrounds.common.preview'.tr(),
            status: _status,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Text('examples.forms.playgrounds.value_controls.scenario'.tr()),
                KeyedSubtree(
                  key: ValueKey('value-slider-mode-$_rangeMode'),
                  child: FSlider(
                    key: const ValueKey('value-preview-slider'),
                    label: Text(
                      _rangeMode
                          ? 'examples.forms.playgrounds.value_controls.range'
                                .tr()
                          : 'examples.forms.playgrounds.value_controls.threshold'
                                .tr(),
                    ),
                    description: Text(
                      'examples.forms.playgrounds.value_controls.slider_description'
                          .tr(),
                    ),
                    enabled: _enabled,
                    control: _rangeMode
                        ? .liftedContinuousRange(
                            value: _range,
                            stepPercentage: _step,
                            onChange: (value) => setState(() {
                              _range = value;
                              _status =
                                  'range: ${(value.min * 100).round()}%-${(value.max * 100).round()}%';
                            }),
                          )
                        : .liftedContinuous(
                            value: _value,
                            stepPercentage: _step,
                            interaction: .tapAndSlideThumb,
                            onChange: (value) => setState(() {
                              _value = value;
                              _status = 'value: ${(value.max * 100).round()}%';
                            }),
                          ),
                    marks: const [
                      .mark(value: 0, label: Text('0%')),
                      .mark(value: 0.5, label: Text('50%')),
                      .mark(value: 1, label: Text('100%')),
                    ],
                    semanticFormatterCallback: (value) => _rangeMode
                        ? '${(value.min * 100).round()}%-${(value.max * 100).round()}%'
                        : '${(value.max * 100).round()}%',
                  ),
                ),
                SizedBox(
                  height: 180,
                  child: FPicker(
                    key: const ValueKey('value-preview-picker'),
                    control: .managed(controller: _pickerController),
                    children: [
                      FPickerWheel(
                        semanticsLabel:
                            'examples.forms.playgrounds.value_controls.period'
                                .tr(),
                        semanticsValueBuilder: (index) => periods[index],
                        children: [for (final period in periods) Text(period)],
                      ),
                      const Text('/'),
                      FPickerWheel(
                        semanticsLabel:
                            'examples.forms.playgrounds.value_controls.channel'
                                .tr(),
                        semanticsValueBuilder: (index) => channels[index],
                        children: [
                          for (final channel in channels) Text(channel),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ComponentExampleSection(
            title: 'examples.forms.playgrounds.common.configuration'.tr(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                FSwitch(
                  key: const ValueKey('value-range-toggle'),
                  label: Text(
                    'examples.forms.playgrounds.value_controls.range_mode'.tr(),
                  ),
                  value: _rangeMode,
                  onChange: (value) => setState(() => _rangeMode = value),
                ),
                FSwitch(
                  label: Text('examples.forms.playgrounds.common.enabled'.tr()),
                  value: _enabled,
                  onChange: (value) => setState(() => _enabled = value),
                ),
                Text('examples.forms.playgrounds.value_controls.step'.tr()),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final step in const [0.05, 0.1])
                      FButton(
                        key: ValueKey('value-step-${(step * 100).round()}'),
                        variant: .outline,
                        selected: _step == step,
                        mainAxisSize: .min,
                        onPress: () => setState(() => _step = step),
                        child: Text('${(step * 100).round()}%'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          PlaygroundActionBar(
            resetLabel: 'examples.forms.playgrounds.common.reset'.tr(),
            onReset: _reset,
          ),
        ],
      ),
    );
  }
}

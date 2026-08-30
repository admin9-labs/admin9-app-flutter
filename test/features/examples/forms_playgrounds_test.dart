import 'dart:convert';
import 'dart:ui' as ui;

import 'package:admin9_app_flutter/features/examples/presentation/pages/form/buttons/buttons_playground_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/form/scheduling/scheduling_playground_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/form/selection_controls/selection_controls_playground_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/form/selects/selects_playground_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/form/text_input/text_input_playground_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/form/value_controls/value_controls_playground_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_code_panel.dart';
import 'package:admin9_app_flutter/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Map<String, dynamic> _translations;

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    _translations = jsonDecode(
      await rootBundle.loadString('assets/translations/zh-CN.json'),
    ) as Map<String, dynamic>;
  });

  testWidgets(
    'WF02 covers constructors, content, states, semantics, and reset',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpPage(tester, const ButtonsPlaygroundPage());

      expect(
        find.byKey(const ValueKey('buttons-preview-standard')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('buttons-prefix')), findsOneWidget);
      expect(find.byKey(const ValueKey('buttons-suffix')), findsOneWidget);
      final expandedWidth = tester
          .getSize(find.byKey(const ValueKey('buttons-preview-button')))
          .width;
      await _tap(tester, 'buttons-expanded-toggle');
      expect(
        tester
            .getSize(find.byKey(const ValueKey('buttons-preview-button')))
            .width,
        lessThan(expandedWidth),
      );

      await _tap(tester, 'buttons-variant-destructive');
      await _tap(tester, 'buttons-size-lg');
      var preview = tester.widget<FButton>(
        find.byKey(const ValueKey('buttons-preview-button')),
      );
      expect(preview.variant, FButtonVariant.destructive);
      expect(preview.size, FButtonSizeVariant.lg);
      expect(_summary(tester), contains('variant: destructive'));

      await _tap(tester, 'buttons-kind-icon');
      expect(
        find.byKey(const ValueKey('buttons-preview-icon')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FButton>(
              find.byKey(const ValueKey('buttons-preview-button')),
            )
            .semanticsLabel,
        '发布变更',
      );

      await _tap(tester, 'buttons-kind-raw');
      expect(find.byKey(const ValueKey('buttons-preview-raw')), findsOneWidget);

      await _tap(tester, 'buttons-kind-standard');
      await _tap(tester, 'buttons-loading-toggle');
      preview = tester.widget<FButton>(
        find.byKey(const ValueKey('buttons-preview-button')),
      );
      expect(preview.onPress, isNull);
      expect(find.byKey(const ValueKey('buttons-progress')), findsOneWidget);
      await _tap(tester, 'buttons-loading-toggle');
      await _tap(tester, 'buttons-preview-button');
      expect(_status(tester), isNotEmpty);
      expect(
        find.semantics
            .byLabel('发布变更')
            .evaluate()
            .single
            .flagsCollection
            .isSelected,
        ui.Tristate.isTrue,
      );

      await _tapAction(tester, 'playground-reset');
      preview = tester.widget<FButton>(
        find.byKey(const ValueKey('buttons-preview-button')),
      );
      expect(preview.variant, FButtonVariant.primary);
      expect(preview.size, FButtonSizeVariant.md);
      expect(_summary(tester), contains('kind: standard'));
      semantics.dispose();
    },
  );

  testWidgets('WF01/WF06/WF08/WF15/WF16 run a complete input form', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPage(tester, const TextInputPlaygroundPage());

    final standard = _editableWithin(const ValueKey('text-preview-field'));
    await tester.ensureVisible(standard);
    await tester.enterText(standard, '中文输入与选择');
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '中文输入与选择',
        selection: TextSelection(baseOffset: 0, extentOffset: 4),
      ),
    );
    await tester.pump();
    expect(
      tester.widget<EditableText>(standard).controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: 4),
    );
    expect(
      tester
          .widget<EditableText>(
            _editableWithin(const ValueKey('text-email-field')),
          )
          .keyboardType,
      TextInputType.emailAddress,
    );
    expect(
      tester
          .widget<EditableText>(
            _editableWithin(const ValueKey('text-password-field')),
          )
          .obscureText,
      isTrue,
    );
    expect(
      tester
          .widget<EditableText>(
            _editableWithin(const ValueKey('text-multiline-field')),
          )
          .maxLines,
      4,
    );

    await _tap(tester, 'text-submit');
    final requiredLabel = tester.widget<FLabel>(
      find.byKey(const ValueKey('text-required-label')),
    );
    expect(requiredLabel.description, isNotNull);
    expect(requiredLabel.error, isNotNull);
    expect(requiredLabel.variants, contains(FFormFieldVariant.error));
    expect((requiredLabel.label! as Semantics).properties.label, '资料完整度，必填状态');

    final autocomplete = find.byWidgetPredicate(
      (widget) => widget is FAutocomplete<String>,
    );
    final autocompleteInput = find.descendant(
      of: autocomplete,
      matching: find.byType(EditableText),
    );
    await tester.ensureVisible(autocompleteInput);
    await tester.tap(autocompleteInput);
    await tester.enterText(autocompleteInput, '成');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('成都').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.widget<EditableText>(autocompleteInput).controller.text,
      '成都',
    );

    final required = _editableWithin(const ValueKey('text-form-field'));
    await tester.enterText(required, 'adopter@admin9.dev');
    final otp = find.byWidgetPredicate((widget) => widget is FOtpField);
    final otpInput = find.descendant(
      of: otp,
      matching: find.byType(EditableText),
    );
    await tester.ensureVisible(otpInput);
    await tester.tap(otpInput);
    await tester.enterText(otpInput, '123456');
    await tester.pump();
    expect(tester.widget<EditableText>(otpInput).focusNode.hasFocus, isTrue);
    expect(find.semantics.byLabel('验证码'), findsWidgets);

    await _tap(tester, 'text-submit');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('text-saved-value'))).data,
      'adopter@admin9.dev',
    );
    await tester.enterText(required, '键盘提交');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('text-submitted-value')))
          .data,
      '键盘提交',
    );

    await _tap(tester, 'text-size-lg');
    await _tap(tester, 'text-enabled-toggle');
    final field = tester.widget<FTextField>(
      find.byKey(const ValueKey('text-preview-field')),
    );
    expect(field.size, FTextFieldSizeVariant.lg);
    expect(field.enabled, isFalse);
    expect(_summary(tester), contains('enabled: false'));

    await _tapAction(tester, 'playground-reset');
    expect(
      tester
          .widget<FTextField>(find.byKey(const ValueKey('text-preview-field')))
          .enabled,
      isTrue,
    );
    expect(tester.widget<EditableText>(required).controller.text, isEmpty);
    semantics.dispose();
  });

  testWidgets('WF03/WF10/WF11/WF14 cover selection and form semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPage(tester, const SelectionControlsPlaygroundPage());

    final switchFinder = find.byKey(const ValueKey('selection-preview-switch'));
    expect(tester.widget<FSwitch>(switchFinder).value, isTrue);
    tester.widget<FSwitch>(switchFinder).onChange!(false);
    await tester.pump();
    expect(tester.widget<FSwitch>(switchFinder).value, isFalse);
    expect(
      find.semantics.byPredicate(
        (node) => node.flagsCollection.isToggled == ui.Tristate.isFalse,
      ),
      findsWidgets,
    );

    await _tap(tester, 'selection-error-toggle');
    expect(
      tester
          .widget<FCheckbox>(
            find.byKey(const ValueKey('selection-preview-checkbox')),
          )
          .error,
      isNotNull,
    );

    final radioGroup = find.byKey(const ValueKey('selection-radio-group'));
    final radios = find.descendant(
      of: radioGroup,
      matching: find.byType(FRadio),
    );
    expect(tester.widget<FRadio>(radios.last).enabled, isFalse);
    final dynamic radioControl = tester
        .widget<FSelectGroup<String>>(radioGroup)
        .control;
    radioControl.onChange({'weekly'});
    await tester.pump();
    expect(tester.widget<FRadio>(radios.at(1)).value, isTrue);

    final checkboxGroup = find.byKey(
      const ValueKey('selection-checkbox-group'),
    );
    final checkboxes = find.descendant(
      of: checkboxGroup,
      matching: find.byType(FCheckbox),
    );
    expect(tester.widget<FCheckbox>(checkboxes.last).enabled, isFalse);
    final dynamic checkboxControl = tester
        .widget<FSelectGroup<String>>(checkboxGroup)
        .control;
    checkboxControl.onChange({'email', 'push'});
    await tester.pump();
    expect(tester.widget<FCheckbox>(checkboxes.at(1)).value, isTrue);
    await _tap(tester, 'selection-save');
    expect(_status(tester), contains('保存'));

    await _tap(tester, 'selection-enabled-toggle');
    expect(
      tester
          .widget<FCheckbox>(
            find.byKey(const ValueKey('selection-preview-checkbox')),
          )
          .enabled,
      isFalse,
    );
    expect(
      tester
          .widget<FSwitch>(
            find.byKey(const ValueKey('selection-preview-switch')),
          )
          .enabled,
      isFalse,
    );
    expect(_summary(tester), contains('enabled: false'));
    expect(find.semantics.byLabel('接收活动消息'), findsWidgets);
    expect(find.semantics.byLabel('仅重要更新'), findsWidgets);

    await _tapAction(tester, 'playground-reset');
    expect(
      tester
          .widget<FSwitch>(
            find.byKey(const ValueKey('selection-preview-switch')),
          )
          .enabled,
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('WF07/WF12 cover selection, clear, async builders, and form', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPage(tester, const SelectsPlaygroundPage());

    final rich = find.byKey(const ValueKey('selects-priority'));
    await tester.tap(rich);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('高').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(_summary(tester), contains('priority: high'));
    expect(find.semantics.byLabel('清除'), findsWidgets);

    await _tap(tester, 'selects-state-error');
    expect(find.byKey(const ValueKey('selects-preview-error')), findsOneWidget);
    expect(_summary(tester), contains('state: error'));
    final search = find.byKey(const ValueKey('selects-search-priority'));
    final dynamic errorSearch = tester.widget<FSelect<String>>(search);
    expect(errorSearch.contentErrorBuilder, isNotNull);
    await tester.runAsync(
      () => expectLater(
        errorSearch.filter('高') as Future<Iterable<String>>,
        throwsA(isA<StateError>()),
      ),
    );

    await _tap(tester, 'selects-state-loading');
    expect(
      find.byKey(const ValueKey('selects-preview-loading')),
      findsOneWidget,
    );
    final dynamic loadingSearch = tester.widget<FSelect<String>>(search);
    expect(loadingSearch.contentLoadingBuilder, isNotNull);
    expect(
      await tester.runAsync(
        () => loadingSearch.filter('中') as Future<Iterable<String>>,
      ),
      contains('medium'),
    );

    await _tapAction(tester, 'playground-reset');
    expect(find.byKey(const ValueKey('selects-preview-ready')), findsOneWidget);
    final dynamic readySearch = tester.widget<FSelect<String>>(search);
    expect(await readySearch.filter('高'), contains('high'));
    final multi = find.byKey(const ValueKey('selects-channels'));
    final multiWidget = tester.widget<FMultiSelect<String>>(multi);
    expect(multiWidget.clearable, isTrue);
    final dynamic multiControl = multiWidget.control;
    multiControl.onChange({'email', 'push'});
    await tester.pump();
    expect(_summary(tester), contains('email,push'));
    await _tap(tester, 'selects-save');
    expect(_status(tester), contains('保存'));
    semantics.dispose();
  });

  testWidgets('WF09/WF13 cover bounded sliders and adjustable picker wheels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPage(tester, const ValueControlsPlaygroundPage());
    final before = _status(tester);
    final slider = find.byKey(const ValueKey('value-preview-slider'));
    await tester.ensureVisible(slider);
    final rect = tester.getRect(slider);
    await tester.tapAt(Offset(rect.left + rect.width * 0.8, rect.center.dy));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_status(tester), isNot(before));
    expect(_summary(tester), contains('value:'));
    expect(_summary(tester), contains('bounds: 25%-75%'));
    final sliderWidget = tester.widget<FSlider>(slider);
    expect(sliderWidget.marks, hasLength(3));
    final tappedStatus = _status(tester);
    await tester.dragFrom(
      Offset(rect.left + rect.width * 0.75, rect.center.dy),
      const Offset(-80, 0),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(_status(tester), isNot(tappedStatus));
    expect(
      find.semantics.byPredicate(
        (node) =>
            node.value.endsWith('%') &&
            node.increasedValue.isNotEmpty &&
            node.decreasedValue.isNotEmpty,
      ),
      findsWidgets,
    );

    await _tap(tester, 'value-range-toggle');
    expect(_summary(tester), contains('mode: range'));
    await _tapAction(tester, 'playground-reset');
    expect(_summary(tester), contains('value: 45%'));

    final period = find.semantics.byLabel('时间段');
    final channel = find.semantics.byLabel('通知渠道');
    await tester.ensureVisible(
      find.byKey(const ValueKey('value-preview-picker')),
    );
    await tester.pump();
    expect(period.evaluate().single.value, '下午');
    expect(period.evaluate().single.increasedValue, '晚上');
    expect(period.evaluate().single.decreasedValue, '上午');
    expect(
      period.evaluate().single.getSemanticsData().hasAction(
        ui.SemanticsAction.increase,
      ),
      isTrue,
    );
    final picker = tester.widget<FPicker>(
      find.byKey(const ValueKey('value-preview-picker')),
    );
    final control = picker.control as FPickerManagedControl;
    control.controller!.value = [2, 1];
    await tester.pump(const Duration(milliseconds: 300));
    expect(period.evaluate().single.value, '晚上');
    expect(channel.evaluate().single.value, '推送');
    expect(control.controller!.value, [2, 1]);
    final beforeWheel = control.controller!.value;
    await tester.drag(
      find.byType(ListWheelScrollView).first,
      const Offset(0, 80),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(control.controller!.value, isNot(beforeWheel));

    semantics.dispose();
  });

  testWidgets('WF04/WF05/WF17/WF18 cover temporal fields and wheels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPage(tester, const SchedulingPlaygroundPage());

    expect(
      find.byKey(const ValueKey('schedule-date-field-calendar')),
      findsOneWidget,
    );
    await _tap(tester, 'schedule-date-mode-input');
    final dateInput = find.byKey(const ValueKey('schedule-date-field-input'));
    expect(dateInput, findsOneWidget);
    expect(tester.widget<FDateField>(dateInput).validator(null), isNotNull);
    final dateEditable = find.descendant(
      of: dateInput,
      matching: find.byType(EditableText),
    );
    await tester.enterText(dateEditable, '2026/9/9');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.widget<FDateField>(dateInput).validator(DateTime(2026, 9, 9)),
      isNull,
    );

    final timeInput = tester.widget<FTimeField>(
      find.byKey(const ValueKey('schedule-time-field-input')),
    );
    final timeControl = timeInput.control as FTimeFieldManagedControl;
    timeControl.controller!.value = null;
    await tester.pump();
    expect(tester.state<FormState>(find.byType(Form)).validate(), isFalse);
    timeControl.controller!.value = const FTime(10, 15);
    await tester.pump();

    final pickerField = find.byKey(
      const ValueKey('schedule-time-field-picker'),
    );
    await tester.ensureVisible(pickerField);
    final timeField = tester.widget<FTimeField>(pickerField);
    final popover = timeField.popoverControl as FPopoverManagedControl;
    await popover.controller!.show(animated: false);
    await tester.pump();
    expect(_summary(tester), contains('popoverShown: true'));
    expect(find.byType(FTimePicker), findsNWidgets(2));
    await tester.tapAt(const Offset(8, 80));
    await tester.pump(const Duration(milliseconds: 300));

    await _tap(tester, 'schedule-hour24-toggle');
    await _tap(tester, 'schedule-minute-30');

    final picker = tester.widget<FDateTimePicker>(
      find.byKey(const ValueKey('schedule-preview-picker')),
    );
    expect(picker.hour24, isFalse);
    expect(picker.minuteInterval, 30);
    expect(_summary(tester), contains('minuteInterval: 30'));
    final timePicker = tester.widget<FTimePicker>(
      find.byKey(const ValueKey('schedule-preview-time-picker')),
    );
    expect(timePicker.hour24, isFalse);
    expect(timePicker.minuteInterval, 30);
    final dateTimeControl = picker.control as FDateTimePickerManagedControl;
    final dateTimeBefore = dateTimeControl.controller!.value;
    await tester.ensureVisible(
      find.byKey(const ValueKey('schedule-preview-picker')),
    );
    await tester.pump();
    final dateTimeWheel = find.semantics.byPredicate(
      (node) =>
          node.value.contains('2026') &&
          node.getSemanticsData().hasAction(ui.SemanticsAction.increase),
    );
    expect(dateTimeWheel, findsOneWidget);
    expect(dateTimeWheel.evaluate().single.increasedValue, isNotEmpty);
    dateTimeControl.controller!.value = dateTimeBefore.add(
      const Duration(days: 1),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(dateTimeControl.controller!.value, isNot(dateTimeBefore));
    final adjustable = find.semantics.byAction(ui.SemanticsAction.increase);
    expect(adjustable, findsWidgets);
    final before = _status(tester);
    tester.semantics.increase(adjustable.last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(_status(tester), isNot(before));

    await _tapAction(tester, 'playground-reset');
    expect(
      tester
          .widget<FDateTimePicker>(
            find.byKey(const ValueKey('schedule-preview-picker')),
          )
          .minuteInterval,
      15,
    );
    semantics.dispose();
  });

  for (final scenario in [
    (size: const Size(320, 844), scale: 2.0),
    (size: const Size(390, 844), scale: 1.0),
  ]) {
    testWidgets('all six direct playgrounds fit ${scenario.size.width}px '
        'at ${scenario.scale}x text', (tester) async {
      for (final page in const [
        ButtonsPlaygroundPage(),
        TextInputPlaygroundPage(),
        SelectionControlsPlaygroundPage(),
        SelectsPlaygroundPage(),
        ValueControlsPlaygroundPage(),
        SchedulingPlaygroundPage(),
      ]) {
        await _pumpPage(
          tester,
          page,
          size: scenario.size,
          textScale: scenario.scale,
        );
        expect(tester.takeException(), isNull, reason: '$page');
        expect(
          find.byType(PlaygroundCodePanel),
          findsOneWidget,
          reason: '$page',
        );
      }
    });
  }
}

String _summary(WidgetTester tester) => tester
    .widget<Text>(find.byKey(const ValueKey('playground-parameter-summary')))
    .data!;

String _status(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('playground-status'))).data!;

Finder _editableWithin(Key key) =>
    find.descendant(of: find.byKey(key), matching: find.byType(EditableText));

Future<void> _tapAction(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN')],
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: const Locale('zh', 'CN'),
      path: 'assets/translations',
      assetLoader: _Loader(_translations),
      saveLocale: false,
      child: _LocalizedApp(page: page, textScale: textScale),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

class _LocalizedApp extends StatelessWidget {
  const _LocalizedApp({required this.page, required this.textScale});

  final Widget page;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: [
      ...context.localizationDelegates,
      FLocalizations.delegate,
    ],
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: FTheme(
          data: lightTheme,
          child: FToaster(child: page),
        ),
      ),
    ),
  );
}

class _Loader extends AssetLoader {
  const _Loader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      Map.of(translations);
}

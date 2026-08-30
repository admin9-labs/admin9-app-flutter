import 'dart:convert';

import 'package:admin9_app_flutter/app/routing/app_router.dart';
import 'package:admin9_app_flutter/features/forms/presentation/pages/buttons_labels_page.dart';
import 'package:admin9_app_flutter/features/forms/presentation/pages/date_time_page.dart';
import 'package:admin9_app_flutter/features/forms/presentation/pages/forms_page.dart';
import 'package:admin9_app_flutter/features/forms/presentation/pages/select_range_page.dart';
import 'package:admin9_app_flutter/features/forms/presentation/pages/text_input_page.dart';
import 'package:admin9_app_flutter/features/forms/presentation/pages/toggles_groups_page.dart';
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

  testWidgets('forms catalog opens a typed detail route', (tester) async {
    final router = AppRouter();
    addTearDown(router.dispose);
    await _pumpRouter(tester, router);

    await tester.tap(find.text('表单'));
    await tester.pumpAndSettle();
    expect(find.byType(FormsPage), findsOneWidget);

    await tester.tap(find.text('文本输入'));
    await tester.pumpAndSettle();

    expect(find.byType(TextInputPage), findsOneWidget);
    expect(find.text('必填内容'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('enabled button examples expose observable callbacks', (
    tester,
  ) async {
    await _pumpPage(tester, const ButtonsLabelsPage());

    expect(find.text('已触发 0 次'), findsOneWidget);
    await tester.tap(find.text('主要'));
    await tester.pump();
    expect(find.text('已触发 1 次'), findsOneWidget);

    final semantics = tester.ensureSemantics();
    final iconButton = find.bySemanticsLabel('图标按钮');
    await tester.ensureVisible(iconButton);
    await tester.tap(iconButton);
    await tester.pump();
    expect(find.text('已触发 2 次'), findsOneWidget);
    await tester.pumpAndSettle();
    semantics.dispose();
  });

  testWidgets(
    'text fields validate, accept keyboard input, and keep selection',
    (tester) async {
      await _pumpPage(tester, const TextInputPage());

      final otpEditable = find.descendant(
        of: find.byType(FOtpField),
        matching: find.byType(EditableText),
      );
      expect(
        tester.widget<EditableText>(otpEditable).keyboardType,
        TextInputType.number,
      );

      final firstEditable = find.byType(EditableText).first;
      await tester.tap(firstEditable);
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.enterText(firstEditable, '中文输入');
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '中文输入',
          selection: TextSelection(baseOffset: 0, extentOffset: 2),
        ),
      );
      await tester.pump();

      expect(
        tester.widget<EditableText>(firstEditable).controller.selection,
        const TextSelection(baseOffset: 0, extentOffset: 2),
      );

      tester.testTextInput.hide();
      await tester.pump();
      final validate = find.text('验证');
      await tester.ensureVisible(validate);
      await tester.tap(validate);
      await tester.pumpAndSettle();

      expect(find.text('此项为必填项'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('toggle and select controls update from touch input', (
    tester,
  ) async {
    await _pumpPage(tester, const TogglesGroupsPage());

    final checkbox = find.byType(FCheckbox).first;
    expect(tester.widget<FSwitch>(find.byType(FSwitch)).value, isTrue);
    expect(tester.widget<FCheckbox>(checkbox).value, isFalse);

    final switchLabel = find.text('启用通知');
    final checkboxLabel = find.text('接收内容更新');
    await tester.ensureVisible(switchLabel);
    await tester.tap(switchLabel);
    await tester.ensureVisible(checkboxLabel);
    await tester.tap(checkboxLabel);
    await tester.pumpAndSettle();

    expect(tester.widget<FSwitch>(find.byType(FSwitch)).value, isFalse);
    expect(tester.widget<FCheckbox>(checkbox).value, isTrue);

    await _pumpPage(tester, const SelectRangePage());
    final select = find.byWidgetPredicate(
      (widget) => widget is FSelect<String>,
    );
    await tester.tap(select);
    await tester.pumpAndSettle();

    await tester.tap(find.text('高'));
    await tester.pumpAndSettle();

    expect(find.text('高'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is FMultiSelect<String>),
      findsOneWidget,
    );
    expect(find.byType(FSlider), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('date and time fields and mobile pickers render together', (
    tester,
  ) async {
    await _pumpPage(tester, const DateTimePage());

    final dateField = find.byWidgetPredicate((widget) => widget is FDateField);
    final timeField = find.byWidgetPredicate((widget) => widget is FTimeField);
    expect(dateField, findsOneWidget);
    expect(timeField, findsOneWidget);
    expect(find.byType(FPicker), findsWidgets);
    expect(find.byType(FDateTimePicker), findsOneWidget);
    expect(find.byType(FTimePicker), findsOneWidget);

    await tester.tap(dateField);
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    await tester.tap(dateField);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('时间选择器'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('generic picker exposes adjustable localized semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPage(tester, const DateTimePage());
    await tester.ensureVisible(find.text('滚轮选择器'));
    await tester.pumpAndSettle();

    final picker = find.semantics.byLabel('时间段');
    var node = picker.evaluate().single;
    expect(node.value, '下午');
    expect(node.increasedValue, '晚上');
    expect(node.decreasedValue, '上午');

    tester.semantics.increase(picker);
    await tester.pumpAndSettle();
    node = picker.evaluate().single;
    expect(node.value, '晚上');

    tester.semantics.decrease(picker);
    await tester.pumpAndSettle();
    expect(picker.evaluate().single.value, '下午');
    semantics.dispose();
  });

  testWidgets(
    'forms pages fit mobile widths, large text, dark theme, and insets',
    (tester) async {
      const pages = <({Widget page, String title})>[
        (page: FormsPage(), title: '表单'),
        (page: ButtonsLabelsPage(), title: '按钮与标签'),
        (page: TextInputPage(), title: '文本输入'),
        (page: TogglesGroupsPage(), title: '开关与选择组'),
        (page: SelectRangePage(), title: '选择与范围'),
        (page: DateTimePage(), title: '日期与时间'),
      ];
      const sizes = [Size(320, 844), Size(360, 800), Size(390, 844)];
      const insets = EdgeInsets.only(top: 44, bottom: 34);

      for (final size in sizes) {
        for (final (:page, :title) in pages) {
          await _pumpPage(
            tester,
            page,
            size: size,
            textScale: 2,
            theme: darkTheme,
            padding: insets,
          );

          expect(find.text(title), findsWidgets);
          expect(
            tester.getTopLeft(find.text(title).first).dy,
            greaterThanOrEqualTo(insets.top),
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '$title at ${size.width}px',
          );
        }
      }
    },
  );
}

Future<void> _pumpRouter(WidgetTester tester, AppRouter router) async {
  await _pumpLocalized(
    tester,
    _LocalizedApp.router(router: router),
    const Size(390, 844),
    1,
  );
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  Size size = const Size(390, 844),
  double textScale = 1,
  FThemeData? theme,
  EdgeInsets padding = EdgeInsets.zero,
}) async {
  await _pumpLocalized(
    tester,
    _LocalizedApp.page(
      page: page,
      textScale: textScale,
      theme: theme ?? lightTheme,
      padding: padding,
    ),
    size,
    textScale,
  );
}

Future<void> _pumpLocalized(
  WidgetTester tester,
  Widget child,
  Size size,
  double textScale,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN')],
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: const Locale('zh', 'CN'),
      path: 'assets/translations',
      assetLoader: _InMemoryAssetLoader(_translations),
      saveLocale: false,
      child: child,
    ),
  );
  await tester.pumpAndSettle();
}

class _LocalizedApp extends StatelessWidget {
  const _LocalizedApp.page({
    required this.page,
    required this.textScale,
    required this.theme,
    required this.padding,
  }) : router = null;

  const _LocalizedApp.router({required this.router})
    : page = null,
      textScale = 1,
      theme = null,
      padding = EdgeInsets.zero;

  final Widget? page;
  final AppRouter? router;
  final double textScale;
  final FThemeData? theme;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final delegates = [
      ...context.localizationDelegates,
      FLocalizations.delegate,
    ];

    if (router case final router?) {
      return MaterialApp.router(
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: delegates,
        routerConfig: router.config(),
        builder: _buildAppChild,
      );
    }

    return MaterialApp(
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: delegates,
      home: page,
      builder: _buildAppChild,
    );
  }

  Widget _buildAppChild(BuildContext context, Widget? child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      padding: padding,
      viewPadding: padding,
    ),
    child: FTheme(
      data: theme ?? lightTheme,
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      Future.value(Map.of(translations));
}

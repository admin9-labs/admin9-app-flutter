import 'dart:ui' as ui;

import 'package:admin9_app_flutter/app/brand/app_brand_theme.dart';
import 'package:admin9_app_flutter/core/design_system/components/app_form_components.dart';
import 'package:admin9_app_flutter/core/design_system/components/app_notice.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_contracts.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_design_tokens.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppButton uses one branded variant mapping on both platforms', (
    tester,
  ) async {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      for (final variant in AppButtonVariant.values) {
        var calls = 0;
        await _pumpDesign(
          tester,
          platform: platform,
          child: AppButton(
            label: '继续',
            variant: variant,
            icon: AppIconRole.success,
            onPressed: () => calls += 1,
          ),
        );

        final expectedType = switch (variant) {
          AppButtonVariant.primary ||
          AppButtonVariant.destructive => FilledButton,
          AppButtonVariant.secondary => OutlinedButton,
          AppButtonVariant.tertiary => TextButton,
        };
        expect(find.byType(expectedType), findsOneWidget);
        expect(find.byType(CupertinoButton), findsNothing);
        final semantics = tester.getSemantics(find.bySemanticsLabel('继续'));
        expect(semantics.flagsCollection.isButton, isTrue);
        expect(semantics.flagsCollection.isEnabled, ui.Tristate.isTrue);
        expect(
          tester.getSize(find.bySemanticsLabel('继续')).height,
          greaterThanOrEqualTo(48),
        );
        await tester.tap(find.bySemanticsLabel('继续'));
        await tester.pump();
        expect(calls, 1);
      }
    }
  });

  testWidgets('AppButton loading and disabled states lock dispatch and size', (
    tester,
  ) async {
    var calls = 0;
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      await _pumpDesign(
        tester,
        platform: platform,
        child: AppButton(
          key: const Key('button'),
          label: '提交注册信息',
          onPressed: () => calls += 1,
        ),
      );
      final enabledSize = tester.getSize(find.byKey(const Key('button')));

      await _pumpDesign(
        tester,
        platform: platform,
        child: AppButton(
          key: const Key('button'),
          label: '提交注册信息',
          loading: true,
          onPressed: () => calls += 1,
        ),
      );
      expect(tester.getSize(find.byKey(const Key('button'))), enabledSize);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      final loadingSemantics = tester.getSemantics(
        find.bySemanticsLabel('提交注册信息'),
      );
      expect(loadingSemantics.value, '加载中');
      expect(loadingSemantics.flagsCollection.isEnabled, ui.Tristate.isFalse);
      await tester.tap(find.byKey(const Key('button')));

      await _pumpDesign(
        tester,
        platform: platform,
        child: AppButton(
          key: const Key('button'),
          label: '提交注册信息',
          enabled: false,
          onPressed: () => calls += 1,
        ),
      );
      await tester.tap(find.byKey(const Key('button')));
      expect(calls, 0);
    }
  });

  testWidgets('AppTextField maps input metadata and force error priority', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      var validatorCalls = 0;
      String? changed;
      String? submitted;
      final formKey = GlobalKey<FormState>();
      await _pumpDesign(
        tester,
        platform: platform,
        child: Form(
          key: formKey,
          child: AppTextField(
            key: ValueKey(platform),
            controller: controller,
            focusNode: focusNode,
            label: '账号',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            prefixIcon: AppIconRole.account,
            forceErrorText: '服务端返回的账号错误',
            validator: (_) {
              validatorCalls += 1;
              return '本地错误';
            },
            onChanged: (value) => changed = value,
            onFieldSubmitted: (value) => submitted = value,
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      expect(validatorCalls, 0);
      expect(find.text('服务端返回的账号错误'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(CupertinoTextField), findsNothing);
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.focusNode, same(focusNode));
      expect(editable.keyboardType, TextInputType.emailAddress);
      expect(editable.textInputAction, TextInputAction.next);
      final autofillHints = tester
          .widget<TextField>(find.byType(TextField))
          .autofillHints;
      expect(autofillHints, contains(AutofillHints.username));
      final fieldSemantics = tester.getSemantics(find.byType(EditableText));
      expect(fieldSemantics.flagsCollection.isTextField, isTrue);
      expect(fieldSemantics.label, contains('账号'));

      await tester.enterText(find.byType(EditableText), 'admin9@example.com');
      expect(changed, 'admin9@example.com');
      focusNode.requestFocus();
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(submitted, 'admin9@example.com');
    }
    semantics.dispose();
  });

  testWidgets('AppTextField disabled state blocks focus and input', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      final controller = TextEditingController(text: '只读状态');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      await _pumpDesign(
        tester,
        platform: platform,
        child: AppTextField(
          key: ValueKey(platform),
          controller: controller,
          focusNode: focusNode,
          label: '不可编辑字段',
          enabled: false,
        ),
      );

      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      final fieldSemantics = tester.getSemantics(find.byType(EditableText));
      expect(fieldSemantics.flagsCollection.isEnabled, ui.Tristate.isFalse);
      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);
      expect(controller.text, '只读状态');
    }
    semantics.dispose();
  });

  testWidgets('AppTextField password toggle owns presentation state only', (
    tester,
  ) async {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      final controller = TextEditingController(text: 'Admin9-secret');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      await _pumpDesign(
        tester,
        platform: platform,
        child: AppTextField(
          key: ValueKey(platform),
          controller: controller,
          focusNode: focusNode,
          label: '密码',
          obscureText: true,
          showObscureToggle: true,
        ),
      );
      focusNode.requestFocus();
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );
      final toggle = find.byTooltip('显示密码');
      expect(tester.getSize(toggle).shortestSide, greaterThanOrEqualTo(48));
      await tester.tap(toggle);
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
      expect(controller.text, 'Admin9-secret');
      expect(focusNode.hasFocus, isTrue);
      expect(find.byTooltip('隐藏密码'), findsOneWidget);
    }
  });

  for (final row in _matrix) {
    testWidgets('Phase 4 form components A-L row ${row.name}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = row.size;
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final controller = TextEditingController(text: 'admin9-starter');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      await _pumpDesign(
        tester,
        platform: row.platform,
        brightness: row.brightness,
        highContrast: row.highContrast,
        textScaler: TextScaler.linear(row.systemScale * row.appScale),
        child: Scaffold(
          body: ListView(
            key: const Key('phase4-form-matrix-list'),
            padding: const EdgeInsets.all(16),
            children: [
              AppTextField(
                key: const Key('matrix-field'),
                controller: controller,
                focusNode: focusNode,
                label: '用于验证最长中文持续标签的注册账号输入字段',
                forceErrorText: '账号格式不正确，请检查后重新输入；错误出现后布局必须增长且不能遮挡后续操作。',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.username],
                prefixIcon: AppIconRole.account,
              ),
              const SizedBox(height: 16),
              const AppNotice(
                key: Key('matrix-notice'),
                tone: AppTone.error,
                title: '提交失败',
                message: '错误状态使用图标、标题和文字表达，并随内容完整增长。',
              ),
              const SizedBox(height: 16),
              const Text('用户协议与隐私政策参考正文随窗口宽度和系统字号完整重排。'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  key: const Key('matrix-button'),
                  label: '提交注册信息并验证当前版本服务尚未接入的真实边界',
                  variant: AppButtonVariant.primary,
                  onPressed: _noop,
                ),
              ),
              const SizedBox(key: Key('phase4-form-matrix-end'), height: 24),
            ],
          ),
        ),
      );

      const minimum = 48.0;
      final field = find.byType(TextField);
      expect(tester.getSize(field).height, greaterThanOrEqualTo(minimum));
      expect(
        tester
            .renderObject<RenderParagraph>(
              find.text('账号格式不正确，请检查后重新输入；错误出现后布局必须增长且不能遮挡后续操作。'),
            )
            .didExceedMaxLines,
        isFalse,
      );
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
      final scrollable = find
          .descendant(
            of: find.byKey(const Key('phase4-form-matrix-list')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.byKey(const Key('matrix-notice')),
        300,
        scrollable: scrollable,
      );
      expect(find.byKey(const Key('matrix-notice')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('matrix-button')),
        300,
        scrollable: scrollable,
      );
      expect(
        tester.getSize(find.byKey(const Key('matrix-button'))).height,
        greaterThanOrEqualTo(minimum),
      );
      expect(
        tester
            .renderObject<RenderParagraph>(
              find.text('提交注册信息并验证当前版本服务尚未接入的真实边界'),
            )
            .didExceedMaxLines,
        isFalse,
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('phase4-form-matrix-end')),
        300,
        scrollable: scrollable,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

void _noop() {}

Future<void> _pumpDesign(
  WidgetTester tester, {
  required TargetPlatform platform,
  required Widget child,
  Brightness brightness = Brightness.light,
  bool highContrast = false,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  final resolved = AppTheme.resolve(
    brightness: brightness,
    platform: platform,
    highContrast: highContrast,
    reduceMotion: false,
    boldText: false,
    brandPrimary: brightness == Brightness.dark
        ? appBrandTheme.primaryDark
        : appBrandTheme.primaryLight,
    brandSecondary: brightness == Brightness.dark
        ? appBrandTheme.secondaryDark
        : appBrandTheme.secondaryLight,
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: resolved.material,
      home: MediaQuery(
        data: MediaQueryData(
          size: tester.view.physicalSize,
          devicePixelRatio: 1,
          textScaler: textScaler,
          highContrast: highContrast,
        ),
        child: Theme(
          data: resolved.material,
          child: AppDesignScope(
            tokens: resolved.tokens,
            child: Material(child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

final _matrix = <_MatrixRow>[
  _MatrixRow('A', TargetPlatform.android, Size(320, 720), 1, 1),
  _MatrixRow('B', TargetPlatform.iOS, Size(320, 720), 1, 1.24),
  _MatrixRow(
    'C',
    TargetPlatform.android,
    Size(360, 800),
    1,
    1.12,
    brightness: Brightness.dark,
  ),
  _MatrixRow(
    'D',
    TargetPlatform.iOS,
    Size(360, 800),
    1,
    1,
    brightness: Brightness.dark,
  ),
  _MatrixRow('E', TargetPlatform.android, Size(390, 844), 1, 1.24),
  _MatrixRow(
    'F',
    TargetPlatform.iOS,
    Size(390, 844),
    1,
    1.24,
    brightness: Brightness.dark,
  ),
  _MatrixRow(
    'G',
    TargetPlatform.android,
    Size(600, 960),
    1,
    1,
    brightness: Brightness.dark,
    highContrast: true,
  ),
  _MatrixRow(
    'H',
    TargetPlatform.iOS,
    Size(600, 960),
    1,
    1.12,
    highContrast: true,
  ),
  _MatrixRow('I', TargetPlatform.android, Size(844, 390), 1, 1.12),
  _MatrixRow(
    'J',
    TargetPlatform.iOS,
    Size(844, 390),
    1,
    1.24,
    brightness: Brightness.dark,
  ),
  _MatrixRow(
    'K',
    TargetPlatform.android,
    Size(390, 844),
    2,
    1.24,
    highContrast: true,
  ),
  _MatrixRow(
    'L',
    TargetPlatform.iOS,
    Size(390, 844),
    3,
    1.24,
    brightness: Brightness.dark,
    highContrast: true,
  ),
];

class _MatrixRow {
  const _MatrixRow(
    this.name,
    this.platform,
    this.size,
    this.systemScale,
    this.appScale, {
    this.brightness = Brightness.light,
    this.highContrast = false,
  });

  final String name;
  final TargetPlatform platform;
  final Size size;
  final double systemScale;
  final double appScale;
  final Brightness brightness;
  final bool highContrast;
}

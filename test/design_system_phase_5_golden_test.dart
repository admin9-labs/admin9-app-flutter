import 'dart:io';

import 'package:admin9_app_flutter/admin9_ui.dart';
import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/brand/app_brand_theme.dart';
import 'package:admin9_app_flutter/core/design_system/components/app_feedback.dart';
import 'package:admin9_app_flutter/core/design_system/components/app_interaction.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_theme.dart';
import 'package:admin9_app_flutter/core/design_system/gallery/app_gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OffsetLayer;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadGoldenCjkFont);

  for (final row in _goldenRows) {
    testWidgets('Phase 5 component Gallery golden ${row.name}', (tester) async {
      final controller = TextEditingController(text: 'admin9@example.com');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      await _pumpComponentGolden(
        tester,
        row: row,
        controller: controller,
        focusNode: focusNode,
      );

      TestGesture? pressedGesture;
      if (row.name == 'A') {
        pressedGesture = await tester.startGesture(
          tester.getCenter(find.byKey(const Key('golden-primary-button'))),
        );
        await tester.pump();
      }
      if (row.name == 'F') {
        focusNode.requestFocus();
        await tester.pump();
      }
      await expectLater(
        find.byKey(const Key('component-golden-boundary')),
        matchesGoldenFile('goldens/components_${row.name}.png'),
      );
      await pressedGesture?.up();
    });
  }

  testWidgets(
    'Phase 5 Home page golden',
    (tester) async {
      await _pumpAppGolden(
        tester,
        preferences: {'admin9.privacy.accepted': true},
      );
      await expectLater(
        find.byKey(const Key('page-golden-boundary')),
        matchesGoldenFile('goldens/page_home_android.png'),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'Phase 5 Privacy page golden',
    (tester) async {
      await _pumpAppGolden(tester, preferences: const {});
      await expectLater(
        find.byKey(const Key('page-golden-boundary')),
        matchesGoldenFile('goldens/page_privacy_ios.png'),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'Phase 5 Settings page golden',
    (tester) async {
      await _pumpAppGolden(
        tester,
        preferences: {'admin9.privacy.accepted': true},
      );
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('设置'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(const Key('page-golden-boundary')),
        matchesGoldenFile('goldens/page_settings_ios.png'),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'Phase 5 Registration page golden',
    (tester) async {
      await _pumpAppGolden(
        tester,
        preferences: {'admin9.privacy.accepted': true},
      );
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('注册'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('auth-submit-button')));
      await tester.pump();
      await expectLater(
        find.byKey(const Key('page-golden-boundary')),
        matchesGoldenFile('goldens/page_registration_android.png'),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'Phase 5 exact E registration calibration golden',
    (tester) async {
      const row = _GoldenRow(
        'E',
        TargetPlatform.android,
        Size(390, 844),
        1,
        1.24,
      );
      await _pumpAppGolden(
        tester,
        preferences: const {'admin9.privacy.accepted': true},
        row: row,
      );
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('注册'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('auth-submit-button')));
      await tester.pump();
      expect(find.text('请输入手机号或邮箱'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('page-golden-boundary')),
        matchesGoldenFile('goldens/page_registration_E_android.png'),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'Phase 5 dark Extra Large F settings golden',
    (tester) async {
      const row = _GoldenRow(
        'F',
        TargetPlatform.iOS,
        Size(390, 844),
        1,
        1.24,
        brightness: Brightness.dark,
      );
      await _pumpAppGolden(
        tester,
        preferences: const {'admin9.privacy.accepted': true},
        row: row,
      );
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('设置'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('settings-theme')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('page-golden-boundary')),
        matchesGoldenFile('goldens/page_settings_F_ios.png'),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('Phase 5 actual Gallery feedback golden', (tester) async {
    await _pumpGalleryGolden(tester, platform: TargetPlatform.android);
    await tester.scrollUntilVisible(
      find.text('警告与撤销'),
      300,
      scrollable: _galleryScrollable,
    );
    await tester.ensureVisible(find.text('警告与撤销'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.tap(find.text('警告与撤销'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('撤销'), findsOneWidget);
    expect(tester.getCenter(find.text('撤销')).dy, greaterThan(56));
    expect(tester.takeException(), isNull);
    await _expectSurfaceGolden(tester, 'goldens/gallery_feedback_android.png');
  });

  testWidgets('Phase 5 actual Gallery action menu golden', (tester) async {
    await _pumpGalleryGolden(tester, platform: TargetPlatform.android);
    await tester.scrollUntilVisible(
      find.text('打开六项动作菜单'),
      300,
      scrollable: _galleryScrollable,
    );
    await tester.ensureVisible(find.text('打开六项动作菜单'));
    await tester.pump();
    await tester.tap(find.text('打开六项动作菜单'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('示例动作'), findsOneWidget);
    expect(tester.getCenter(find.text('示例动作')).dy, lessThan(700));
    expect(find.text('示例动作').hitTestable(), findsOneWidget);
    expect(find.text('删除'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _expectSurfaceGolden(
      tester,
      'goldens/gallery_action_menu_android.png',
    );
  });

  testWidgets('Phase 5 actual Gallery iOS dialog golden', (tester) async {
    await _pumpGalleryGolden(tester, platform: TargetPlatform.iOS);
    await tester.scrollUntilVisible(
      find.text('打开确认对话框'),
      300,
      scrollable: _galleryScrollable,
    );
    await tester.ensureVisible(find.text('打开确认对话框'));
    await tester.pump();
    await tester.tap(find.text('打开确认对话框'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('确认操作'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await _expectSurfaceGolden(tester, 'goldens/gallery_dialog_ios.png');
  });

  for (final row in _goldenRows) {
    testWidgets('Phase 5 actual Gallery matrix golden ${row.name}', (
      tester,
    ) async {
      await _pumpGalleryGolden(tester, row: row);
      final section = switch (row.name) {
        'A' => '平台骨架',
        'F' => '设置与列表',
        'G' || 'L' => '表单与动作',
        _ => throw StateError('Unmapped Gallery golden row ${row.name}'),
      };
      await tester.scrollUntilVisible(
        find.text(section),
        300,
        scrollable: _galleryScrollable,
      );
      await tester.ensureVisible(find.text(section));
      await tester.pump();
      expect(find.text(section).hitTestable(), findsOneWidget);
      if (row.name == 'G') {
        expect(find.text('账号格式不正确，错误出现后内容区域按需增长。'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                (widget.properties.label?.contains('操作失败') ?? false),
          ),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
      await _expectSurfaceGolden(tester, 'goldens/gallery_${row.name}.png');
    });
  }

  testWidgets('Phase 5 actual Gallery A long value reflow stress', (
    tester,
  ) async {
    await _pumpGalleryGolden(tester, row: _goldenRows.first);
    const longLabel = '这是用于验证长中文内容增长的设置名称';
    const trailingValue = '一个较长的当前值';
    await tester.scrollUntilVisible(
      find.text(longLabel),
      300,
      scrollable: _galleryScrollable,
    );
    await tester.ensureVisible(find.text(longLabel));
    await tester.pump();
    final labelRect = tester.getRect(find.text(longLabel));
    final valueRect = tester.getRect(find.textContaining(trailingValue));
    expect(labelRect.overlaps(valueRect), isFalse);
    expect(valueRect.top, greaterThanOrEqualTo(labelRect.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Phase 5 actual Gallery C error and disabled stress', (
    tester,
  ) async {
    const row = _GoldenRow(
      'C',
      TargetPlatform.android,
      Size(360, 800),
      1,
      1.12,
      brightness: Brightness.dark,
    );
    await _pumpGalleryGolden(tester, row: row);
    await tester.scrollUntilVisible(
      find.text('不可用'),
      300,
      scrollable: _galleryScrollable,
    );
    await tester.ensureVisible(find.text('不可用'));
    await tester.pump();
    expect(find.text('账号格式不正确，错误出现后内容区域按需增长。'), findsOneWidget);
    final disabledSemantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == '不可用' &&
            widget.properties.enabled == false,
      ),
    );
    expect(disabledSemantics.properties.enabled, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Phase 5 actual Gallery AppPage golden', (tester) async {
    await _pumpGalleryGolden(tester, platform: TargetPlatform.android);
    await tester.scrollUntilVisible(
      find.text('打开 AppPage 样例'),
      300,
      scrollable: _galleryScrollable,
    );
    await tester.ensureVisible(find.text('打开 AppPage 样例'));
    await tester.pump();
    await tester.tap(find.text('打开 AppPage 样例'));
    await tester.pumpAndSettle();
    expect(find.text('AppPage 子页'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _expectSurfaceGolden(tester, 'goldens/gallery_app_page_android.png');
  });

  testWidgets('Phase 5 actual Gallery single choice golden', (tester) async {
    await _pumpGalleryGolden(tester, platform: TargetPlatform.iOS);
    await tester.scrollUntilVisible(
      find.text('打开单选列表样例'),
      300,
      scrollable: _galleryScrollable,
    );
    await tester.ensureVisible(find.text('打开单选列表样例'));
    await tester.pump();
    await tester.tap(find.text('打开单选列表样例'));
    await tester.pumpAndSettle();
    expect(find.text('主题选择样例'), findsOneWidget);
    expect(find.text('跟随系统'), findsWidgets);
    expect(tester.takeException(), isNull);
    await _expectSurfaceGolden(tester, 'goldens/gallery_single_choice_ios.png');
  });
}

Finder get _galleryScrollable => find.descendant(
  of: find.byKey(const Key('gallery-scroll')),
  matching: find.byType(Scrollable),
);

Future<void> _expectSurfaceGolden(
  WidgetTester tester,
  String goldenPath,
) async {
  await tester.pump();
  final layer = tester.binding.renderViews.single.debugLayer! as OffsetLayer;
  final image = await layer.toImage(Offset.zero & tester.view.physicalSize);
  try {
    await expectLater(image, matchesGoldenFile(goldenPath));
  } finally {
    image.dispose();
  }
}

Future<void> _loadGoldenCjkFont() async {
  final bytes = await File(
    'test/assets/fonts/Admin9GoldenCJK-Regular.otf',
  ).readAsBytes();
  for (final family in const [
    'Roboto',
    'CupertinoSystemText',
    'CupertinoSystemDisplay',
  ]) {
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }
  await _loadBundledFont(
    family: 'MaterialIcons',
    asset: 'fonts/MaterialIcons-Regular.otf',
  );
  await _loadBundledFont(
    family: 'packages/cupertino_icons/CupertinoIcons',
    asset: 'packages/cupertino_icons/assets/CupertinoIcons.ttf',
  );
}

Future<void> _loadBundledFont({
  required String family,
  required String asset,
}) async {
  final loader = FontLoader(family)..addFont(rootBundle.load(asset));
  await loader.load();
}

Future<void> _pumpComponentGolden(
  WidgetTester tester, {
  required _GoldenRow row,
  required TextEditingController controller,
  required FocusNode focusNode,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = row.size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
  final resolved = AppTheme.resolve(
    brightness: row.brightness,
    platform: row.platform,
    highContrast: row.highContrast,
    reduceMotion: false,
    boldText: false,
    brandPrimary: row.brightness == Brightness.dark
        ? appBrandTheme.primaryDark
        : appBrandTheme.primaryLight,
    brandSecondary: row.brightness == Brightness.dark
        ? appBrandTheme.secondaryDark
        : appBrandTheme.secondaryLight,
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: resolved.material.copyWith(platform: row.platform),
      home: MediaQuery(
        data: MediaQueryData(
          size: row.size,
          devicePixelRatio: 1,
          textScaler: TextScaler.linear(row.systemScale * row.appScale),
          highContrast: row.highContrast,
        ),
        child: AppDesignScope(
          tokens: resolved.tokens,
          child: RepaintBoundary(
            key: const Key('component-golden-boundary'),
            child: Material(
              color: resolved.tokens.background,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton(
                        key: const Key('golden-primary-button'),
                        label: '主要操作',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      AppButton(label: '提交中', loading: true, onPressed: () {}),
                      const SizedBox(height: 12),
                      AppButton(
                        label: '不可用操作',
                        enabled: false,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        key: const Key('golden-field'),
                        controller: controller,
                        focusNode: focusNode,
                        label: '手机号或邮箱',
                        forceErrorText: '请输入有效的手机号或邮箱',
                        prefixIcon: AppIconRole.account,
                      ),
                      const SizedBox(height: 16),
                      const AppNotice(
                        tone: AppTone.warning,
                        title: '请检查输入',
                        message: '状态同时使用图标、标题和文字表达。',
                      ),
                      const SizedBox(height: 16),
                      AppSwitch(
                        label: '高对比度',
                        value: row.highContrast,
                        onChanged: (_) {},
                      ),
                      const AppListTile(
                        title: '当前主题',
                        currentValue: '跟随系统',
                        disclosure: true,
                      ),
                      const SizedBox(height: 16),
                      const AppProgressIndicator(
                        label: '已完成 45%',
                        kind: AppProgressKind.linear,
                        value: 0.45,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _pumpAppGolden(
  WidgetTester tester, {
  required Map<String, Object> preferences,
  _GoldenRow? row,
}) async {
  final size = row?.size ?? const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  if (row != null) {
    tester.platformDispatcher.textScaleFactorTestValue = row.systemScale;
  }
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  SharedPreferences.setMockInitialValues({
    ...preferences,
    if (row != null)
      'admin9.appearance.theme_mode': row.brightness == Brightness.dark
          ? 'dark'
          : 'light',
    if (row != null)
      'admin9.appearance.font_scale': switch (row.appScale) {
        1 => 'standard',
        1.12 => 'large',
        1.24 => 'extraLarge',
        _ => throw StateError('Unsupported App font factor ${row.appScale}'),
      },
    if (row != null) 'admin9.accessibility.high_contrast': row.highContrast,
  });
  final instance = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('page-golden-boundary'),
      child: Admin9App(preferences: instance),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _pumpGalleryGolden(
  WidgetTester tester, {
  TargetPlatform? platform,
  _GoldenRow? row,
}) async {
  assert(platform != null || row != null);
  final effectivePlatform = row?.platform ?? platform!;
  final size = row?.size ?? const Size(390, 844);
  final brightness = row?.brightness ?? Brightness.light;
  final highContrast = row?.highContrast ?? false;
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
  final resolved = AppTheme.resolve(
    brightness: brightness,
    platform: effectivePlatform,
    highContrast: highContrast,
    reduceMotion: true,
    boldText: false,
    brandPrimary: brightness == Brightness.dark
        ? appBrandTheme.primaryDark
        : appBrandTheme.primaryLight,
    brandSecondary: brightness == Brightness.dark
        ? appBrandTheme.secondaryDark
        : appBrandTheme.secondaryLight,
  );
  final navigatorKey = GlobalKey<NavigatorState>();
  final feedback = AppFeedbackPresenterController();
  final interaction = AppInteractionPresenterController(
    navigatorKey: navigatorKey,
  );
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('gallery-golden-boundary'),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: resolved.material.copyWith(platform: effectivePlatform),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: size,
            textScaler: TextScaler.linear(row?.systemScale ?? 1),
            highContrast: highContrast,
          ),
          child: AppDesignScope(
            tokens: resolved.tokens,
            child: AppInteractionHost(
              controller: interaction,
              child: AppFeedback(
                controller: feedback,
                navigatorKey: navigatorKey,
                child: child!,
              ),
            ),
          ),
        ),
        home: AppGalleryPage(
          initialBrightness: brightness,
          initialPlatform: effectivePlatform,
          initialFontScale: _fontScaleFor(row?.appScale ?? 1),
          initialHighContrast: highContrast,
          initialReduceMotion: true,
          resolveTheme:
              ({
                required brightness,
                required platform,
                required highContrast,
                required reduceMotion,
                required boldText,
              }) => AppTheme.resolve(
                brightness: brightness,
                platform: platform,
                highContrast: highContrast,
                reduceMotion: reduceMotion,
                boldText: boldText,
                brandPrimary: brightness == Brightness.dark
                    ? appBrandTheme.primaryDark
                    : appBrandTheme.primaryLight,
                brandSecondary: brightness == Brightness.dark
                    ? appBrandTheme.secondaryDark
                    : appBrandTheme.secondaryLight,
              ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

AppFontScale _fontScaleFor(double factor) => switch (factor) {
  1 => AppFontScale.standard,
  1.12 => AppFontScale.large,
  1.24 => AppFontScale.extraLarge,
  _ => throw StateError('Unsupported App font factor $factor'),
};

const _goldenRows = <_GoldenRow>[
  _GoldenRow('A', TargetPlatform.android, Size(320, 720), 1, 1),
  _GoldenRow(
    'F',
    TargetPlatform.iOS,
    Size(390, 844),
    1,
    1.24,
    brightness: Brightness.dark,
  ),
  _GoldenRow(
    'G',
    TargetPlatform.android,
    Size(600, 960),
    1,
    1,
    brightness: Brightness.dark,
    highContrast: true,
  ),
  _GoldenRow(
    'L',
    TargetPlatform.iOS,
    Size(390, 844),
    3,
    1.24,
    brightness: Brightness.dark,
    highContrast: true,
  ),
];

final class _GoldenRow {
  const _GoldenRow(
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

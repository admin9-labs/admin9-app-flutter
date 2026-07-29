import 'package:admin9_app_flutter/admin9_ui.dart';
import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/app_routes.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_theme.dart';
import 'package:admin9_app_flutter/core/design_system/gallery/app_gallery_page.dart';
import 'package:admin9_app_flutter/core/design_system/gallery/app_gallery_registry.dart';
import 'package:admin9_app_flutter/core/theme/app_appearance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AppResolvedTheme resolve({
    Brightness brightness = Brightness.light,
    TargetPlatform platform = TargetPlatform.android,
    bool highContrast = false,
    bool reduceMotion = false,
    bool boldText = false,
    int radiusDelta = 0,
  }) => AppTheme.resolve(
    brightness: brightness,
    platform: platform,
    highContrast: highContrast,
    reduceMotion: reduceMotion,
    boldText: boldText,
    brandPrimary: brightness == Brightness.light
        ? const Color(0xff2457a7)
        : const Color(0xffafc6ff),
    brandSecondary: brightness == Brightness.light
        ? const Color(0xff52606d)
        : const Color(0xffc4ccd5),
    brandRadiusDelta: radiusDelta,
  );

  test('frozen light and dark semantic palettes resolve exactly', () {
    final light = resolve().tokens;
    final dark = resolve(brightness: Brightness.dark).tokens;

    expect(light.background, const Color(0xfff7f8fa));
    expect(light.onBackground, const Color(0xff171a1f));
    expect(light.surface, const Color(0xffffffff));
    expect(light.primary, const Color(0xff2457a7));
    expect(light.warning, const Color(0xff714b00));
    expect(light.info, const Color(0xff245a7a));
    expect(light.success, const Color(0xff246b45));
    expect(dark.background, const Color(0xff111418));
    expect(dark.onBackground, const Color(0xfff2f4f7));
    expect(dark.surface, const Color(0xff191d22));
    expect(dark.primary, const Color(0xffafc6ff));
    expect(dark.warning, const Color(0xfff4c06a));
  });

  test('frozen spacing, radius, motion, and approved radius delta resolve', () {
    final tokens = resolve().tokens;
    expect(
      [
        tokens.space4,
        tokens.space8,
        tokens.space12,
        tokens.space16,
        tokens.space24,
        tokens.space32,
        tokens.space48,
      ],
      [4, 8, 12, 16, 24, 32, 48],
    );
    expect(tokens.fieldRadius, 6);
    expect(tokens.controlRadius, 8);
    expect(resolve(radiusDelta: 2).tokens.fieldRadius, 8);
    expect(resolve(radiusDelta: -2).tokens.controlRadius, 6);
    expect(tokens.stateMotion, const Duration(milliseconds: 120));
    expect(resolve(reduceMotion: true).tokens.enterMotion, Duration.zero);
  });

  test('App scale composes monotonically with system scaler without a cap', () {
    expect(AppFontScale.values.map((value) => value.factor), [1, 1.12, 1.24]);
    final extraLarge = AppTextScaler(
      system: TextScaler.linear(2),
      preferenceFactor: AppFontScale.extraLarge.factor,
    );
    final stress = AppTextScaler(
      system: TextScaler.linear(3),
      preferenceFactor: AppFontScale.extraLarge.factor,
    );
    expect(extraLarge.scale(16), closeTo(39.68, 0.0001));
    expect(extraLarge.textScaleFactor, closeTo(2.48, 0.0001));
    expect(stress.textScaleFactor, closeTo(3.72, 0.0001));
    expect(
      AppFontScale.values
          .map(
            (value) => AppTextScaler(
              system: TextScaler.linear(2),
              preferenceFactor: value.factor,
            ).scale(16),
          )
          .toList(),
      orderedEquals([32, 35.84, 39.68]),
    );
  });

  test('App scale preserves nonlinear system scaling for every font size', () {
    const system = _NonlinearTextScaler();
    final scaler = AppTextScaler(
      system: system,
      preferenceFactor: AppFontScale.extraLarge.factor,
    );

    expect(system.scale(12) / 12, isNot(system.scale(34) / 34));
    expect(scaler.scale(12), closeTo(system.scale(12) * 1.24, 0.0001));
    expect(scaler.scale(17), closeTo(system.scale(17) * 1.24, 0.0001));
    expect(scaler.scale(34), closeTo(system.scale(34) * 1.24, 0.0001));
    expect(scaler.scale(12) / 12, isNot(scaler.scale(34) / 34));
  });

  test(
    'system accessibility requirements can only strengthen App settings',
    () {
      const app = AppAppearance(
        fontScale: AppFontScale.large,
        grayscale: true,
        highContrast: false,
        reduceMotion: false,
      );
      final effective = EffectiveAppearance.resolve(
        app: app,
        system: const MediaQueryData(
          highContrast: true,
          disableAnimations: true,
          boldText: true,
        ),
        resolvedBrightness: Brightness.dark,
      );
      expect(effective.brightness, Brightness.dark);
      expect(effective.fontScale, AppFontScale.large);
      expect(effective.grayscale, isTrue);
      expect(effective.highContrast, isTrue);
      expect(effective.reduceMotion, isTrue);
      expect(effective.boldText, isTrue);
    },
  );

  test('Material and Cupertino bridges share semantic roles', () {
    final android = resolve(platform: TargetPlatform.android);
    final resolved = resolve(platform: TargetPlatform.iOS, boldText: true);
    final material = resolved.material;
    final cupertino = material.cupertinoOverrideTheme!;
    expect(material.useMaterial3, isTrue);
    expect(material.platform, TargetPlatform.iOS);
    expect(cupertino.primaryColor, resolved.tokens.primary);
    expect(cupertino.scaffoldBackgroundColor, resolved.tokens.background);
    expect(cupertino.barBackgroundColor, resolved.tokens.surface);
    expect(
      cupertino.textTheme!.textStyle.fontWeight,
      resolved.tokens.bodyTextStyle.fontWeight,
    );
    expect(material.pageTransitionsTheme.builders, isNotEmpty);
    expect(android.tokens.pageTitleTextStyle.fontSize, 22);
    expect(android.tokens.bodyTextStyle.fontSize, 16);
    expect(android.tokens.bodyTextStyle.height, 1.5);
    expect(resolved.tokens.displayTextStyle.fontSize, 34);
    expect(resolved.tokens.pageTitleTextStyle.fontSize, 17);
    expect(resolved.tokens.bodyTextStyle.fontSize, 17);
    expect(resolved.tokens.bodyTextStyle.height, closeTo(22 / 17, 0.0001));
    expect(resolved.tokens.bodyTextStyle.fontWeight, FontWeight.w500);
    expect(resolved.tokens.labelTextStyle.fontWeight, FontWeight.w600);
  });

  test(
    'Bold Text strengthens only approved roles and resolves idempotently',
    () {
      final regular = resolve(platform: TargetPlatform.iOS).tokens;
      final bold = resolve(platform: TargetPlatform.iOS, boldText: true).tokens;
      final repeated = resolve(
        platform: TargetPlatform.iOS,
        boldText: true,
      ).tokens;

      expect(bold.displayTextStyle.fontWeight, FontWeight.bold);
      expect(bold.pageTitleTextStyle.fontWeight, FontWeight.bold);
      expect(bold.sectionTitleTextStyle.fontWeight, FontWeight.bold);
      expect(regular.bodyTextStyle.fontWeight, FontWeight.normal);
      expect(regular.supportingTextStyle.fontWeight, FontWeight.normal);
      expect(regular.captionTextStyle.fontWeight, FontWeight.normal);
      expect(bold.bodyTextStyle.fontWeight, FontWeight.w500);
      expect(bold.supportingTextStyle.fontWeight, FontWeight.w500);
      expect(bold.captionTextStyle.fontWeight, FontWeight.w500);
      expect(bold.labelTextStyle.fontWeight, FontWeight.w600);
      expect(repeated.displayTextStyle, bold.displayTextStyle);
      expect(repeated.pageTitleTextStyle, bold.pageTitleTextStyle);
      expect(repeated.sectionTitleTextStyle, bold.sectionTitleTextStyle);
      expect(repeated.bodyTextStyle, bold.bodyTextStyle);
      expect(repeated.supportingTextStyle, bold.supportingTextStyle);
      expect(repeated.labelTextStyle, bold.labelTextStyle);
      expect(repeated.captionTextStyle, bold.captionTextStyle);
    },
  );

  test('invalid Brand focus color is rejected before rendering', () {
    expect(
      () => AppTheme.resolve(
        brightness: Brightness.light,
        highContrast: false,
        reduceMotion: false,
        boldText: false,
        brandPrimary: Colors.white,
        brandSecondary: const Color(0xff52606d),
      ),
      throwsArgumentError,
    );
  });

  testWidgets(
    'App host installs zh_CN delegates, effective scope, and scaler',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'admin9.privacy.accepted': true,
        'admin9.appearance.font_scale': 'extraLarge',
      });
      final preferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(Admin9App(preferences: preferences));
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.locale, const Locale('zh', 'CN'));
      expect(app.supportedLocales, const [Locale('zh', 'CN')]);
      expect(
        app.localizationsDelegates,
        contains(GlobalMaterialLocalizations.delegate),
      );
      expect(
        app.localizationsDelegates,
        contains(GlobalWidgetsLocalizations.delegate),
      );
      expect(
        app.localizationsDelegates,
        contains(GlobalCupertinoLocalizations.delegate),
      );
      final content = tester.element(find.text('暂无内容'));
      expect(AppDesignScope.of(content).fieldRadius, 6);
      expect(
        MediaQuery.textScalerOf(content).scale(16) / 16,
        closeTo(1.24, 0.001),
      );
    },
  );

  testWidgets('system accessibility changes rebuild effective appearance', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'admin9.privacy.accepted': true});
    final preferences = await SharedPreferences.getInstance();
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .themeAnimationDuration,
      const Duration(milliseconds: 200),
    );
    expect(
      AppDesignScope.of(tester.element(find.text('暂无内容'))).enterMotion,
      const Duration(milliseconds: 200),
    );
    final initialContent = tester.element(find.text('暂无内容'));
    final initialOutline = AppDesignScope.of(initialContent).outline;
    expect(
      AppDesignScope.of(initialContent).bodyTextStyle.fontWeight,
      FontWeight.normal,
    );

    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
          disableAnimations: true,
          highContrast: true,
          boldText: true,
        );
    await tester.pump();
    expect(
      tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .themeAnimationDuration,
      Duration.zero,
    );
    expect(
      AppDesignScope.of(tester.element(find.text('暂无内容'))).enterMotion,
      Duration.zero,
    );
    final strengthenedContent = tester.element(find.text('暂无内容'));
    expect(
      AppDesignScope.of(strengthenedContent).outline,
      isNot(initialOutline),
    );
    expect(
      AppDesignScope.of(strengthenedContent).bodyTextStyle.fontWeight,
      FontWeight.w500,
    );
  });

  testWidgets('Gallery route follows the compile-time release registry', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppGalleryRegistry.routeName,
        onGenerateRoute: AppRouteFactory.onGenerateRoute,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    if (kReleaseMode) {
      expect(find.byType(AppGalleryPage), findsNothing);
      expect(find.text('页面不存在'), findsOneWidget);
    } else {
      expect(find.byType(AppGalleryPage), findsOneWidget);
      expect(find.text('Admin9 Gallery'), findsOneWidget);
    }
  });

  testWidgets('Gallery remains scrollable at narrow Extra Large layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: AppGalleryPage(
          resolveTheme:
              ({
                required brightness,
                required platform,
                required highContrast,
                required reduceMotion,
                required boldText,
              }) => resolve(
                brightness: brightness,
                platform: platform,
                highContrast: highContrast,
                reduceMotion: reduceMotion,
                boldText: boldText,
              ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('gallery-font-scale')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('特大 1.24').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);
  });

  for (final fixture in _matrix) {
    testWidgets('Gallery foundation matrix ${fixture.id}', (tester) async {
      await tester.binding.setSurfaceSize(fixture.size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(fixture.systemScale),
          ),
          child: MaterialApp(
            home: AppGalleryPage(
              initialBrightness: fixture.brightness,
              initialPlatform: fixture.platform,
              initialFontScale: fixture.appScale,
              initialHighContrast: fixture.highContrast,
              resolveTheme:
                  ({
                    required brightness,
                    required platform,
                    required highContrast,
                    required reduceMotion,
                    required boldText,
                  }) => resolve(
                    brightness: brightness,
                    platform: platform,
                    highContrast: highContrast,
                    reduceMotion: reduceMotion,
                    boldText: boldText,
                  ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.dragUntilVisible(
        find.text('成功'),
        find.byKey(const Key('gallery-scroll')),
        const Offset(0, -240),
      );
      expect(find.text('成功'), findsOneWidget);
      final sampleContext = tester.element(find.text('成功'));
      final expected = resolve(
        brightness: fixture.brightness,
        platform: fixture.platform,
        highContrast: fixture.highContrast,
      );
      expect(Theme.of(sampleContext).platform, fixture.platform);
      expect(Theme.of(sampleContext).brightness, fixture.brightness);
      expect(AppDesignScope.of(sampleContext).outline, expected.tokens.outline);
      expect(
        MediaQuery.textScalerOf(sampleContext).scale(16),
        closeTo(16 * fixture.systemScale * fixture.appScale.factor, 0.0001),
      );
      expect(tester.takeException(), isNull);
    });
  }
}

final class _MatrixFixture {
  const _MatrixFixture(
    this.id,
    this.platform,
    this.size,
    this.brightness,
    this.highContrast,
    this.appScale,
    this.systemScale,
  );

  final String id;
  final TargetPlatform platform;
  final Size size;
  final Brightness brightness;
  final bool highContrast;
  final AppFontScale appScale;
  final double systemScale;
}

const _matrix = <_MatrixFixture>[
  _MatrixFixture(
    'A',
    TargetPlatform.android,
    Size(320, 720),
    Brightness.light,
    false,
    AppFontScale.standard,
    1,
  ),
  _MatrixFixture(
    'B',
    TargetPlatform.iOS,
    Size(320, 720),
    Brightness.light,
    false,
    AppFontScale.extraLarge,
    1,
  ),
  _MatrixFixture(
    'C',
    TargetPlatform.android,
    Size(360, 800),
    Brightness.dark,
    false,
    AppFontScale.large,
    1,
  ),
  _MatrixFixture(
    'D',
    TargetPlatform.iOS,
    Size(360, 800),
    Brightness.dark,
    false,
    AppFontScale.standard,
    1,
  ),
  _MatrixFixture(
    'E',
    TargetPlatform.android,
    Size(390, 844),
    Brightness.light,
    false,
    AppFontScale.extraLarge,
    1,
  ),
  _MatrixFixture(
    'F',
    TargetPlatform.iOS,
    Size(390, 844),
    Brightness.dark,
    false,
    AppFontScale.extraLarge,
    1,
  ),
  _MatrixFixture(
    'G',
    TargetPlatform.android,
    Size(600, 960),
    Brightness.dark,
    true,
    AppFontScale.standard,
    1,
  ),
  _MatrixFixture(
    'H',
    TargetPlatform.iOS,
    Size(600, 960),
    Brightness.light,
    true,
    AppFontScale.large,
    1,
  ),
  _MatrixFixture(
    'I',
    TargetPlatform.android,
    Size(844, 390),
    Brightness.light,
    false,
    AppFontScale.large,
    1,
  ),
  _MatrixFixture(
    'J',
    TargetPlatform.iOS,
    Size(844, 390),
    Brightness.dark,
    false,
    AppFontScale.extraLarge,
    1,
  ),
  _MatrixFixture(
    'K',
    TargetPlatform.android,
    Size(390, 844),
    Brightness.light,
    true,
    AppFontScale.extraLarge,
    2,
  ),
  _MatrixFixture(
    'L',
    TargetPlatform.iOS,
    Size(390, 844),
    Brightness.dark,
    true,
    AppFontScale.extraLarge,
    3,
  ),
];

@immutable
final class _NonlinearTextScaler implements TextScaler {
  const _NonlinearTextScaler();

  @override
  double scale(double fontSize) {
    final factor = fontSize <= 14
        ? 2.0
        : fontSize <= 20
        ? 1.8
        : 1.5;
    return fontSize * factor;
  }

  @override
  double get textScaleFactor => scale(16) / 16;

  @override
  TextScaler clamp({
    double minScaleFactor = 0,
    double maxScaleFactor = double.infinity,
  }) => this;
}

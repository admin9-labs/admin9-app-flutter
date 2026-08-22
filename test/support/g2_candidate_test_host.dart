import 'dart:io';

import 'package:admin9_app_flutter/app/brand/app_brand_theme.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_design_tokens.dart';
import 'package:admin9_app_flutter/core/design_system/foundation/app_theme.dart';
import 'package:admin9_app_flutter/core/design_system/poc/g2_candidate_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadG2GoldenFonts() async {
  final bytes = await File(
    'test/assets/fonts/Admin9GoldenCJK-Regular.otf',
  ).readAsBytes();
  for (final family in const [
    'Roboto',
    'CupertinoSystemText',
    'CupertinoSystemDisplay',
    '_Admin9SystemFont',
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
  await _loadBundledFont(
    family: 'packages/forui_assets/ForuiLucideIcons',
    asset: 'packages/forui_assets/assets/lucide.ttf',
  );
}

Future<void> pumpG2Candidate(
  WidgetTester tester, {
  required G2CandidateKind candidate,
  required G2CandidateScenario scenario,
  required TargetPlatform platform,
  G2CandidateEvidenceState evidenceState = G2CandidateEvidenceState.baseline,
  Size size = const Size(390, 844),
  Brightness brightness = Brightness.light,
  double textScale = 1,
  bool highContrast = false,
  bool focusAuth = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  final resolved = AppTheme.resolve(
    brightness: brightness,
    highContrast: highContrast,
    reduceMotion: true,
    boldText: false,
    brandPrimary: brightness == Brightness.dark
        ? appBrandTheme.primaryDark
        : appBrandTheme.primaryLight,
    brandSecondary: brightness == Brightness.dark
        ? appBrandTheme.secondaryDark
        : appBrandTheme.secondaryLight,
    brandFontFamily: appBrandTheme.fontFamily,
    brandRadiusDelta: appBrandTheme.radiusDelta,
    platform: platform,
  );
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('g2-golden-boundary'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('zh', 'CN'),
        theme: resolved.material.copyWith(platform: platform),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: size,
            textScaler: TextScaler.linear(textScale),
            highContrast: highContrast,
            disableAnimations: true,
          ),
          child: AppDesignScope(tokens: resolved.tokens, child: child!),
        ),
        home: Scaffold(
          body: G2CandidateHarness(
            key: ValueKey((candidate, scenario, platform, evidenceState)),
            candidate: candidate,
            scenario: scenario,
            evidenceState: evidenceState,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  if (focusAuth && scenario == G2CandidateScenario.auth) {
    final editable = find.descendant(
      of: find.byKey(const Key('g2-account-field')),
      matching: find.byType(EditableText),
    );
    tester.widget<EditableText>(editable).focusNode.requestFocus();
    await tester.pump();
  }
}

void resetG2TestView(WidgetTester tester) {
  tester.view.resetDevicePixelRatio();
  tester.view.resetPhysicalSize();
}

Future<void> expectG2Golden(WidgetTester tester, String goldenPath) async {
  final boundary = find.byKey(const Key('g2-golden-boundary'));
  await expectLater(boundary, matchesGoldenFile(goldenPath));
}

Future<void> _loadBundledFont({
  required String family,
  required String asset,
}) async {
  final loader = FontLoader(family)..addFont(rootBundle.load(asset));
  await loader.load();
}

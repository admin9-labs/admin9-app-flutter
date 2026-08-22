import 'dart:ui' show Tristate;

import 'package:admin9_app_flutter/core/design_system/poc/g2_candidate_harness.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/g2_candidate_test_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadG2GoldenFonts);

  for (final candidate in G2CandidateKind.values) {
    testWidgets('${candidate.name} renders the same four scenario contracts', (
      tester,
    ) async {
      addTearDown(() => resetG2TestView(tester));
      for (final scenario in G2CandidateScenario.values) {
        await pumpG2Candidate(
          tester,
          candidate: candidate,
          scenario: scenario,
          platform: TargetPlatform.android,
        );
        expect(find.text(_title(scenario)), findsWidgets);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('${candidate.name} keeps auth input and action semantics', (
      tester,
    ) async {
      addTearDown(() => resetG2TestView(tester));
      await pumpG2Candidate(
        tester,
        candidate: candidate,
        scenario: G2CandidateScenario.auth,
        platform: TargetPlatform.iOS,
      );
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.keyboardType, TextInputType.emailAddress);
      expect(editable.textInputAction, TextInputAction.next);
      final autofillHints = find.byType(CupertinoTextField).evaluate().isEmpty
          ? editable.autofillHints
          : tester
                .widget<CupertinoTextField>(find.byType(CupertinoTextField))
                .autofillHints;
      expect(autofillHints, contains(AutofillHints.username));
      expect(find.text('不可用'), findsOneWidget);
      expect(find.textContaining('账号格式不正确'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('${candidate.name} toggles the settings switch once', (
      tester,
    ) async {
      addTearDown(() => resetG2TestView(tester));
      await pumpG2Candidate(
        tester,
        candidate: candidate,
        scenario: G2CandidateScenario.settings,
        platform: TargetPlatform.android,
      );
      expect(find.text('高对比度'), findsOneWidget);
      await tester.tap(find.byKey(const Key('g2-notification-switch')));
      await tester.pump();
      final semantics = tester.getSemantics(
        find.byKey(const Key('g2-notification-switch')),
      );
      expect(semantics.flagsCollection.isToggled, Tristate.isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('${candidate.name} survives narrow maximum-text pressure', (
      tester,
    ) async {
      addTearDown(() => resetG2TestView(tester));
      for (final scenario in G2CandidateScenario.values) {
        await pumpG2Candidate(
          tester,
          candidate: candidate,
          scenario: scenario,
          platform: TargetPlatform.iOS,
          size: const Size(320, 720),
          brightness: Brightness.dark,
          textScale: 3,
          highContrast: true,
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('${candidate.name} keeps feedback and progress semantics', (
      tester,
    ) async {
      addTearDown(() => resetG2TestView(tester));
      final semanticsHandle = tester.ensureSemantics();
      try {
        await pumpG2Candidate(
          tester,
          candidate: candidate,
          scenario: G2CandidateScenario.account,
          platform: TargetPlatform.android,
        );
        final error = tester.getSemantics(
          find.bySemanticsLabel(RegExp(r'^错误.*操作失败')),
        );
        if (candidate == G2CandidateKind.control) {
          expect(error.label, startsWith('错误，操作失败，操作失败，请检查后重试。'));
        } else {
          expect(error.label, '错误，操作失败，操作失败，请检查后重试。');
        }
        expect(error.flagsCollection.isLiveRegion, isTrue);

        await pumpG2Candidate(
          tester,
          candidate: candidate,
          scenario: G2CandidateScenario.feedback,
          platform: TargetPlatform.iOS,
        );
        final loading = tester.getSemantics(find.bySemanticsLabel('提交中'));
        expect(loading.flagsCollection.isButton, isTrue);
        expect(loading.flagsCollection.isEnabled, Tristate.isFalse);
        expect(loading.value, '加载中');
        final progress = tester.getSemantics(find.bySemanticsLabel('已完成 45%'));
        expect(progress.value, '45%');
        expect(progress.flagsCollection.isLiveRegion, isTrue);
        expect(tester.takeException(), isNull);
      } finally {
        semanticsHandle.dispose();
      }
    });
  }

  testWidgets('Forui candidate does not render bundled Inter typography', (
    tester,
  ) async {
    addTearDown(() => resetG2TestView(tester));
    for (final scenario in G2CandidateScenario.values) {
      await pumpG2Candidate(
        tester,
        candidate: G2CandidateKind.forui,
        scenario: scenario,
        platform: TargetPlatform.android,
      );
      for (final richText in tester.widgetList<RichText>(
        find.byType(RichText),
      )) {
        expect(richText.text.style?.fontFamily, isNot('packages/forui/Inter'));
      }
      for (final editable in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(editable.style.fontFamily, isNot('packages/forui/Inter'));
      }
    }
  });
}

String _title(G2CandidateScenario scenario) => switch (scenario) {
  G2CandidateScenario.auth => '登录',
  G2CandidateScenario.account => '个人中心',
  G2CandidateScenario.settings => '设置',
  G2CandidateScenario.feedback => '警告与撤销',
};

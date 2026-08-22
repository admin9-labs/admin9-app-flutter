import 'dart:ui' show SemanticsAction, Tristate;

import 'package:admin9_app_flutter/core/design_system/poc/g2_candidate_harness.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/g2_candidate_test_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadG2GoldenFonts);

  for (final candidate in G2CandidateKind.values) {
    testWidgets(
      '${candidate.name} renders the same four scenarios and alternate states',
      (tester) async {
        addTearDown(() => resetG2TestView(tester));
        for (final state in G2CandidateEvidenceState.values) {
          for (final scenario in G2CandidateScenario.values) {
            await pumpG2Candidate(
              tester,
              candidate: candidate,
              scenario: scenario,
              evidenceState: state,
              platform: TargetPlatform.android,
            );
            expect(
              find.text(_title(scenario, state)),
              findsWidgets,
              reason: '${candidate.name}/${scenario.name}/${state.name}',
            );
            expect(tester.takeException(), isNull);
          }
        }
      },
    );

    testWidgets(
      '${candidate.name} keeps registration input and focus metadata',
      (tester) async {
        addTearDown(() => resetG2TestView(tester));
        await pumpG2Candidate(
          tester,
          candidate: candidate,
          scenario: G2CandidateScenario.auth,
          platform: TargetPlatform.iOS,
          focusAuth: true,
        );
        final accountEditable = tester.widget<EditableText>(
          find.descendant(
            of: find.byKey(const Key('g2-account-field')),
            matching: find.byType(EditableText),
          ),
        );
        final passwordEditable = tester.widget<EditableText>(
          find.descendant(
            of: find.byKey(const Key('g2-password-field')),
            matching: find.byType(EditableText),
          ),
        );
        expect(accountEditable.keyboardType, TextInputType.emailAddress);
        expect(accountEditable.textInputAction, TextInputAction.next);
        final accountCupertino = find.descendant(
          of: find.byKey(const Key('g2-account-field')),
          matching: find.byType(CupertinoTextField),
        );
        final accountHints = accountCupertino.evaluate().isEmpty
            ? accountEditable.autofillHints
            : tester.widget<CupertinoTextField>(accountCupertino).autofillHints;
        expect(accountHints, contains(AutofillHints.username));
        expect(accountEditable.focusNode.hasFocus, isTrue);
        expect(passwordEditable.obscureText, isTrue);
        final passwordCupertino = find.descendant(
          of: find.byKey(const Key('g2-password-field')),
          matching: find.byType(CupertinoTextField),
        );
        final passwordHints = passwordCupertino.evaluate().isEmpty
            ? passwordEditable.autofillHints
            : tester
                  .widget<CupertinoTextField>(passwordCupertino)
                  .autofillHints;
        expect(passwordHints, contains(AutofillHints.newPassword));
        expect(find.text('注册'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '${candidate.name} exposes executable button and switch semantics',
      (tester) async {
        addTearDown(() => resetG2TestView(tester));
        final semanticsHandle = tester.ensureSemantics();
        try {
          for (final platform in const [
            TargetPlatform.android,
            TargetPlatform.iOS,
          ]) {
            await pumpG2Candidate(
              tester,
              candidate: candidate,
              scenario: G2CandidateScenario.auth,
              platform: platform,
            );
            await _performSemanticsTap(tester, label: '注册');
            expect(find.text('主要操作触发 1 次'), findsOneWidget);

            final disabled = _semanticNode(label: '当前不可用');
            expect(
              disabled.getSemanticsData().hasAction(SemanticsAction.tap),
              isFalse,
            );

            await pumpG2Candidate(
              tester,
              candidate: candidate,
              scenario: G2CandidateScenario.settings,
              platform: platform,
            );
            final before = tester.getSemantics(
              find.byKey(const Key('g2-contrast-switch')),
            );
            expect(before.flagsCollection.isToggled, Tristate.isTrue);
            await _performSemanticsTap(tester, label: '高对比度');
            final after = tester.getSemantics(
              find.byKey(const Key('g2-contrast-switch')),
            );
            expect(after.flagsCollection.isToggled, Tristate.isFalse);
          }
        } finally {
          semanticsHandle.dispose();
        }
      },
    );

    testWidgets('${candidate.name} covers navigation, empty, menu and dialog', (
      tester,
    ) async {
      addTearDown(() => resetG2TestView(tester));
      await pumpG2Candidate(
        tester,
        candidate: candidate,
        scenario: G2CandidateScenario.account,
        platform: TargetPlatform.android,
      );
      expect(find.text('林晓'), findsOneWidget);
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('我的'), findsWidgets);
      final selectedAccount = find.semantics.byPredicate(
        (node) =>
            node.label.contains('我的') &&
            node.getSemanticsData().flagsCollection.isSelected ==
                Tristate.isTrue,
      );
      expect(selectedAccount.evaluate(), isNotEmpty);

      await pumpG2Candidate(
        tester,
        candidate: candidate,
        scenario: G2CandidateScenario.account,
        evidenceState: G2CandidateEvidenceState.alternate,
        platform: TargetPlatform.iOS,
      );
      expect(find.text('暂无可用账号能力'), findsOneWidget);
      expect(find.text('列表载入失败'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);

      await pumpG2Candidate(
        tester,
        candidate: candidate,
        scenario: G2CandidateScenario.feedback,
        platform: TargetPlatform.android,
      );
      expect(find.text('选择操作'), findsOneWidget);
      expect(find.text('暂时不可使用的操作'), findsOneWidget);
      expect(find.text('删除当前资料且无法撤销'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('正在同步'), findsOneWidget);

      await pumpG2Candidate(
        tester,
        candidate: candidate,
        scenario: G2CandidateScenario.feedback,
        evidenceState: G2CandidateEvidenceState.alternate,
        platform: TargetPlatform.iOS,
      );
      expect(find.text('确认继续当前操作'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('确认'), findsOneWidget);
      expect(find.text('显示失败反馈'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '${candidate.name} preserves content at narrow 3x dark high contrast',
      (tester) async {
        addTearDown(() => resetG2TestView(tester));
        for (final platform in const [
          TargetPlatform.android,
          TargetPlatform.iOS,
        ]) {
          for (final state in G2CandidateEvidenceState.values) {
            for (final scenario in G2CandidateScenario.values) {
              await pumpG2Candidate(
                tester,
                candidate: candidate,
                scenario: scenario,
                evidenceState: state,
                platform: platform,
                size: const Size(320, 720),
                brightness: Brightness.dark,
                textScale: 3,
                highContrast: true,
                focusAuth: scenario == G2CandidateScenario.auth,
              );
              expect(find.byKey(const Key('g2-page-title')), findsOneWidget);
              expect(find.text(_criticalText(scenario, state)), findsOneWidget);
              if (scenario == G2CandidateScenario.auth) {
                await tester.ensureVisible(
                  find.byKey(const Key('g2-primary-action')),
                );
                await tester.pump();
                expect(
                  tester
                      .getSize(find.byKey(const Key('g2-primary-action')))
                      .height,
                  greaterThanOrEqualTo(
                    platform == TargetPlatform.iOS ? 44 : 48,
                  ),
                );
              }
              expect(
                tester.takeException(),
                isNull,
                reason:
                    '${candidate.name}/${platform.name}/${scenario.name}/${state.name}',
              );
            }
          }
        }
      },
    );

    testWidgets('${candidate.name} keeps progress and loading semantics', (
      tester,
    ) async {
      addTearDown(() => resetG2TestView(tester));
      final semanticsHandle = tester.ensureSemantics();
      try {
        await pumpG2Candidate(
          tester,
          candidate: candidate,
          scenario: G2CandidateScenario.feedback,
          platform: TargetPlatform.iOS,
        );
        final loading = tester.getSemantics(
          find.byKey(const Key('g2-loading-action')),
        );
        expect(loading.flagsCollection.isButton, isTrue);
        expect(loading.flagsCollection.isEnabled, Tristate.isFalse);
        expect(loading.value, '加载中');
        final progress = tester.getSemantics(find.bySemanticsLabel('已完成 45%'));
        expect(progress.value, '45%');
        expect(progress.flagsCollection.isLiveRegion, isTrue);
        final indeterminate = tester.getSemantics(
          find.bySemanticsLabel('正在同步'),
        );
        expect(indeterminate.value, isEmpty);
        expect(indeterminate.flagsCollection.isLiveRegion, isTrue);
        expect(tester.takeException(), isNull);
      } finally {
        semanticsHandle.dispose();
      }
    });
  }

  for (final candidate in const [
    G2CandidateKind.firstParty,
    G2CandidateKind.forui,
  ]) {
    testWidgets(
      '${candidate.name} announces appearing feedback once without moving focus',
      (tester) async {
        addTearDown(() => resetG2TestView(tester));
        final semanticsHandle = tester.ensureSemantics();
        try {
          await pumpG2Candidate(
            tester,
            candidate: candidate,
            scenario: G2CandidateScenario.feedback,
            evidenceState: G2CandidateEvidenceState.alternate,
            platform: TargetPlatform.android,
          );
          final focus = tester.widget<Focus>(
            find.byKey(const Key('g2-feedback-trigger-focus')),
          );
          focus.focusNode!.requestFocus();
          await tester.pump();
          expect(focus.focusNode!.hasFocus, isTrue);
          final feedbackNodes = find.semantics.byPredicate(
            (node) =>
                node.label == '错误，操作失败，操作失败，请检查后重试。' &&
                node.getSemanticsData().flagsCollection.isLiveRegion,
          );
          expect(feedbackNodes.evaluate(), isEmpty);

          await _performSemanticsTap(tester, label: '显示失败反馈');
          expect(
            find.byKey(const Key('g2-transient-feedback')),
            findsOneWidget,
          );
          expect(feedbackNodes.evaluate(), hasLength(1));
          expect(focus.focusNode!.hasFocus, isTrue);

          await pumpG2Candidate(
            tester,
            candidate: candidate,
            scenario: G2CandidateScenario.feedback,
            evidenceState: G2CandidateEvidenceState.alternate,
            platform: TargetPlatform.android,
          );
          expect(feedbackNodes.evaluate(), hasLength(1));
          expect(focus.focusNode!.hasFocus, isTrue);
        } finally {
          semanticsHandle.dispose();
        }
      },
    );
  }

  testWidgets('Forui candidate does not render bundled Inter typography', (
    tester,
  ) async {
    addTearDown(() => resetG2TestView(tester));
    for (final state in G2CandidateEvidenceState.values) {
      for (final scenario in G2CandidateScenario.values) {
        await pumpG2Candidate(
          tester,
          candidate: G2CandidateKind.forui,
          scenario: scenario,
          evidenceState: state,
          platform: TargetPlatform.android,
        );
        for (final richText in tester.widgetList<RichText>(
          find.byType(RichText),
        )) {
          for (final style in _styles(richText.text)) {
            expect(_usesInter(style), isFalse);
          }
        }
        for (final editable in tester.widgetList<EditableText>(
          find.byType(EditableText),
        )) {
          expect(_usesInter(editable.style), isFalse);
        }
      }
    }
  });
}

Future<void> _performSemanticsTap(
  WidgetTester tester, {
  required String label,
}) async {
  final finder = find.semantics.byPredicate(
    (node) =>
        node.label == label &&
        node.getSemanticsData().hasAction(SemanticsAction.tap),
  );
  expect(finder.evaluate(), hasLength(1));
  tester.semantics.tap(finder);
  await tester.pumpAndSettle();
}

dynamic _semanticNode({required String label}) {
  final finder = find.semantics.byPredicate((node) => node.label == label);
  expect(finder.evaluate(), hasLength(1));
  return finder.evaluate().single;
}

String _title(G2CandidateScenario scenario, G2CandidateEvidenceState state) =>
    switch (scenario) {
      G2CandidateScenario.auth =>
        state == G2CandidateEvidenceState.alternate ? '登录' : '注册',
      G2CandidateScenario.account => '我的',
      G2CandidateScenario.settings => '设置',
      G2CandidateScenario.feedback => '操作与反馈',
    };

String _criticalText(
  G2CandidateScenario scenario,
  G2CandidateEvidenceState state,
) => switch ((scenario, state)) {
  (G2CandidateScenario.auth, G2CandidateEvidenceState.baseline) => '创建账号',
  (G2CandidateScenario.auth, G2CandidateEvidenceState.alternate) => '欢迎回来',
  (G2CandidateScenario.account, G2CandidateEvidenceState.baseline) => '林晓',
  (G2CandidateScenario.account, G2CandidateEvidenceState.alternate) =>
    '暂无可用账号能力',
  (G2CandidateScenario.settings, G2CandidateEvidenceState.baseline) => '当前有效设置',
  (G2CandidateScenario.settings, G2CandidateEvidenceState.alternate) =>
    '设置暂未保存',
  (G2CandidateScenario.feedback, G2CandidateEvidenceState.baseline) => '选择操作',
  (G2CandidateScenario.feedback, G2CandidateEvidenceState.alternate) =>
    '确认继续当前操作',
};

Iterable<TextStyle> _styles(InlineSpan span) sync* {
  if (span.style case final style?) yield style;
  if (span is TextSpan) {
    for (final child in span.children ?? const <InlineSpan>[]) {
      yield* _styles(child);
    }
  }
}

bool _usesInter(TextStyle style) {
  final families = <String>[?style.fontFamily, ...?style.fontFamilyFallback];
  return families.any((family) => family.toLowerCase().contains('inter'));
}

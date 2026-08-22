import 'package:admin9_app_flutter/core/design_system/poc/g2_candidate_harness.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/g2_candidate_test_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadG2GoldenFonts);

  const variants = [
    (
      name: 'baseline_light',
      state: G2CandidateEvidenceState.baseline,
      brightness: Brightness.light,
      textScale: 1.0,
    ),
    (
      name: 'baseline_dark',
      state: G2CandidateEvidenceState.baseline,
      brightness: Brightness.dark,
      textScale: 1.0,
    ),
    (
      name: 'baseline_text_124',
      state: G2CandidateEvidenceState.baseline,
      brightness: Brightness.light,
      textScale: 1.24,
    ),
    (
      name: 'alternate_light',
      state: G2CandidateEvidenceState.alternate,
      brightness: Brightness.light,
      textScale: 1.0,
    ),
  ];

  for (final candidate in G2CandidateKind.values) {
    for (final platform in const [TargetPlatform.android, TargetPlatform.iOS]) {
      for (final scenario in G2CandidateScenario.values) {
        for (final variant in variants) {
          testWidgets('G2 ${candidate.name} ${platform.name} ${scenario.name} '
              '${variant.name} golden', (tester) async {
            addTearDown(() => resetG2TestView(tester));
            await pumpG2Candidate(
              tester,
              candidate: candidate,
              scenario: scenario,
              platform: platform,
              evidenceState: variant.state,
              brightness: variant.brightness,
              textScale: variant.textScale,
              focusAuth:
                  scenario == G2CandidateScenario.auth &&
                  variant.state == G2CandidateEvidenceState.baseline,
            );
            await expectG2Golden(
              tester,
              'goldens/g2_${candidate.name}_${platform.name}_'
              '${scenario.name}_${variant.name}.png',
            );
          }, tags: 'golden');
        }
      }

      testWidgets(
        'G2 ${candidate.name} ${platform.name} auth pressed golden',
        (tester) async {
          addTearDown(() => resetG2TestView(tester));
          await pumpG2Candidate(
            tester,
            candidate: candidate,
            scenario: G2CandidateScenario.auth,
            platform: platform,
          );
          final keyed = find.byKey(const Key('g2-primary-action'));
          final target = switch ((candidate, platform)) {
            (G2CandidateKind.control, TargetPlatform.iOS) => find.descendant(
              of: keyed,
              matching: find.byType(CupertinoButton),
            ),
            (G2CandidateKind.control, _) || (G2CandidateKind.firstParty, _) =>
              find.descendant(of: keyed, matching: find.byType(FilledButton)),
            (G2CandidateKind.forui, _) => keyed,
          };
          final gesture = await tester.startGesture(tester.getCenter(target));
          await tester.pump(
            Duration(
              milliseconds: candidate == G2CandidateKind.forui ? 120 : 1,
            ),
          );
          await expectG2Golden(
            tester,
            'goldens/g2_${candidate.name}_${platform.name}_auth_pressed.png',
          );
          await gesture.up();
          await tester.pump(const Duration(milliseconds: 250));
        },
        tags: 'golden',
      );
    }
  }

  for (final platform in const [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final scenario in G2CandidateScenario.values) {
      testWidgets(
        'G2 firstParty ${platform.name} ${scenario.name} stress golden',
        (tester) async {
          addTearDown(() => resetG2TestView(tester));
          await pumpG2Candidate(
            tester,
            candidate: G2CandidateKind.firstParty,
            scenario: scenario,
            platform: platform,
            size: const Size(320, 720),
            brightness: Brightness.dark,
            textScale: 3,
            highContrast: true,
            focusAuth: scenario == G2CandidateScenario.auth,
          );
          await expectG2Golden(
            tester,
            'goldens/g2_firstParty_${platform.name}_'
            '${scenario.name}_stress_dark_hc_text_300.png',
          );
        },
        tags: 'golden',
      );
    }
  }
}

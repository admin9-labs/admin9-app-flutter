import 'package:admin9_app_flutter/core/design_system/poc/g2_candidate_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/g2_candidate_test_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadG2GoldenFonts);

  for (final candidate in G2CandidateKind.values) {
    for (final platform in const [TargetPlatform.android, TargetPlatform.iOS]) {
      for (final scenario in G2CandidateScenario.values) {
        testWidgets(
          'G2 ${candidate.name} ${platform.name} ${scenario.name} golden',
          (tester) async {
            addTearDown(() => resetG2TestView(tester));
            await pumpG2Candidate(
              tester,
              candidate: candidate,
              scenario: scenario,
              platform: platform,
            );
            await expectG2Golden(
              tester,
              'goldens/g2_${candidate.name}_${platform.name}_${scenario.name}.png',
            );
          },
          tags: 'golden',
        );
      }
    }
  }
}

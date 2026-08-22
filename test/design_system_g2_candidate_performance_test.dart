import 'package:admin9_app_flutter/core/design_system/poc/g2_candidate_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/g2_candidate_test_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadG2GoldenFonts);

  for (final candidate in G2CandidateKind.values) {
    testWidgets('${candidate.name} bounded local POC rendering cost', (
      tester,
    ) async {
      addTearDown(() => resetG2TestView(tester));
      final stopwatch = Stopwatch()..start();
      var maximumElements = 0;
      for (var iteration = 0; iteration < 10; iteration++) {
        for (final scenario in G2CandidateScenario.values) {
          await pumpG2Candidate(
            tester,
            candidate: candidate,
            scenario: scenario,
            platform: iteration.isEven
                ? TargetPlatform.android
                : TargetPlatform.iOS,
          );
          final elements = tester.allElements.length;
          if (elements > maximumElements) maximumElements = elements;
          expect(tester.takeException(), isNull);
        }
      }
      stopwatch.stop();
      debugPrint(
        'G2_PERF candidate=${candidate.name} '
        'elapsedMs=${stopwatch.elapsedMilliseconds} '
        'maxElements=$maximumElements',
      );
      expect(maximumElements, lessThan(2500));
    });
  }
}

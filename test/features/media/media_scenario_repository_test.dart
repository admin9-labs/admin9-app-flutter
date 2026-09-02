import 'dart:io';

import 'package:admin9_app_flutter/features/media/data/models/media_scenario.dart';
import 'package:admin9_app_flutter/features/media/data/repositories/local_media_scenario_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'local Scenario Repository defines complete image/video/audio coverage',
    () {
      final catalog = const LocalMediaScenarioRepository().load();

      expect(catalog.article.images, hasLength(3));
      expect(
        catalog.article.paragraphs,
        hasLength(catalog.article.images.length),
      );
      for (final image in catalog.article.images) {
        expect(image.semanticLabel, isNotEmpty);
        if (image.kind == MediaImageKind.asset) {
          expect(File(image.location).existsSync(), isTrue);
        }
      }

      expect(
        catalog.videos.map((scenario) => scenario.kind).toSet(),
        VideoScenarioKind.values.toSet(),
      );
      expect(catalog.videos.where((scenario) => scenario.isLive), hasLength(1));
      expect(File(catalog.videoById('local')!.location).existsSync(), isTrue);
      for (final scenario in catalog.videos.where(
        (scenario) => scenario.kind != VideoScenarioKind.local,
      )) {
        expect(Uri.parse(scenario.location).scheme, 'https');
      }

      expect(catalog.audio, hasLength(2));
      expect(catalog.audio.where((scenario) => scenario.isLive), hasLength(1));
      expect(
        File(catalog.audioById('local-audio')!.location).existsSync(),
        isTrue,
      );
      expect(
        Uri.parse(catalog.audioById('live-audio')!.location).scheme,
        'https',
      );
    },
  );
}

import 'package:flutter_test/flutter_test.dart';

import 'package:admin9_app_flutter/data/repositories/live_repository.dart';
import 'package:admin9_app_flutter/domain/models/live_program.dart';

void main() {
  const repository = LiveRepository();

  test(
    'LiveRepository exposes complete and internally consistent live data',
    () {
      expect(repository.tvChannels.length, greaterThanOrEqualTo(3));
      expect(repository.radioChannels.length, greaterThanOrEqualTo(3));
      expect(repository.featuredPrograms.length, greaterThanOrEqualTo(4));
      expect(repository.interactiveLives.length, greaterThanOrEqualTo(8));
      expect(repository.programs.length, greaterThanOrEqualTo(8));

      _expectUnique(repository.tvChannels.map((channel) => channel.id));
      _expectUnique(repository.radioChannels.map((channel) => channel.id));
      _expectUnique(repository.featuredPrograms.map((program) => program.id));
      _expectUnique(repository.interactiveLives.map((item) => item.id));
      _expectUnique(repository.programs.map((program) => program.id));

      for (final channel in repository.tvChannels) {
        expect(channel.name.trim(), isNotEmpty);
        expect(channel.logoLabel.trim(), isNotEmpty);
        expect(channel.nowTitle.trim(), isNotEmpty);
        expect(channel.nowSubtitle.trim(), isNotEmpty);
        _expectHttpStreamUrl(channel.streamUrl);
      }

      for (final channel in repository.radioChannels) {
        expect(channel.name.trim(), isNotEmpty);
        expect(channel.frequency.trim(), isNotEmpty);
        expect(channel.host.trim(), isNotEmpty);
        expect(channel.nowTitle.trim(), isNotEmpty);
        expect(channel.nextTitle.trim(), isNotEmpty);
        _expectHttpStreamUrl(channel.streamUrl);
      }

      for (final program in repository.featuredPrograms) {
        expect(program.title.trim(), isNotEmpty);
        expect(program.subtitle.trim(), isNotEmpty);
        expect(program.channelName.trim(), isNotEmpty);
        expect(program.airDate.trim(), isNotEmpty);
        expect(program.heroLabel.trim(), isNotEmpty);
        expect(program.schedule, isNotEmpty);
        _expectUnique(program.schedule.map((episode) => episode.id));
        for (final episode in program.schedule) {
          expect(episode.title.trim(), isNotEmpty);
          expect(episode.time.trim(), isNotEmpty);
          expect(episode.summary.trim(), isNotEmpty);
        }
      }

      for (final item in repository.interactiveLives) {
        expect(item.title.trim(), isNotEmpty);
        expect(item.source.trim(), isNotEmpty);
        expect(item.label.trim(), isNotEmpty);
        expect(
          item.kind == LivePlaybackKind.live,
          item.label.contains('直播'),
          reason: '${item.id} label should match playback kind',
        );
      }

      for (final program in repository.programs) {
        expect(program.title.trim(), isNotEmpty);
        expect(program.source.trim(), isNotEmpty);
        expect(program.time.trim(), isNotEmpty);
        expect(program.summary.trim(), isNotEmpty);
        expect(program.visualLabel.trim(), isNotEmpty);
      }
    },
  );
}

void _expectUnique(Iterable<String> ids) {
  final list = ids.toList(growable: false);
  expect(list.toSet(), hasLength(list.length));
  for (final id in list) {
    expect(id.trim(), isNotEmpty);
  }
}

void _expectHttpStreamUrl(String url) {
  final uri = Uri.parse(url);
  expect(uri.hasScheme, isTrue);
  expect(uri.scheme, anyOf('http', 'https'));
  expect(uri.host, isNotEmpty);
}

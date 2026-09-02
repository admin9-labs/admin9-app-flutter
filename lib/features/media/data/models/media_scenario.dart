enum MediaImageKind { asset, network }

final class MediaImageSource {
  const MediaImageSource({
    required this.kind,
    required this.location,
    required this.semanticLabel,
  });

  final MediaImageKind kind;
  final String location;
  final String semanticLabel;
}

final class ArticleScenario {
  const ArticleScenario({
    required this.id,
    required this.title,
    required this.summary,
    required this.paragraphs,
    required this.images,
  });

  final String id;
  final String title;
  final String summary;
  final List<String> paragraphs;
  final List<MediaImageSource> images;
}

enum VideoScenarioKind { local, networkMp4, hlsVod, hlsLive }

final class VideoScenario {
  const VideoScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.kind,
    required this.location,
  });

  final String id;
  final String title;
  final String description;
  final VideoScenarioKind kind;
  final String location;

  bool get isLive => kind == VideoScenarioKind.hlsLive;
}

enum AudioScenarioKind { onDemand, live }

final class AudioScenario {
  const AudioScenario({
    required this.id,
    required this.title,
    required this.artist,
    required this.kind,
    required this.location,
  });

  final String id;
  final String title;
  final String artist;
  final AudioScenarioKind kind;
  final String location;

  bool get isLive => kind == AudioScenarioKind.live;
}

final class MediaCatalog {
  const MediaCatalog({
    required this.article,
    required this.videos,
    required this.audio,
  });

  final ArticleScenario article;
  final List<VideoScenario> videos;
  final List<AudioScenario> audio;

  VideoScenario? videoById(String id) {
    for (final scenario in videos) {
      if (scenario.id == id) return scenario;
    }
    return null;
  }

  AudioScenario? audioById(String id) {
    for (final scenario in audio) {
      if (scenario.id == id) return scenario;
    }
    return null;
  }
}

enum LiveStatus { live, upcoming, replay }

enum LivePlaybackKind { live, replay }

class LiveProgram {
  const LiveProgram({
    required this.id,
    required this.title,
    required this.source,
    required this.time,
    required this.summary,
    required this.status,
    required this.visualLabel,
    this.duration,
  });

  final String id;
  final String title;
  final String source;
  final String time;
  final String summary;
  final LiveStatus status;
  final String visualLabel;
  final String? duration;
}

class LiveTvChannel {
  const LiveTvChannel({
    required this.id,
    required this.name,
    required this.logoLabel,
    required this.streamUrl,
    required this.nowTitle,
    required this.nowSubtitle,
    required this.accentColor,
    this.lockedPreview = false,
  });

  final String id;
  final String name;
  final String logoLabel;
  final String streamUrl;
  final String nowTitle;
  final String nowSubtitle;
  final int accentColor;
  final bool lockedPreview;
}

class LiveRadioChannel {
  const LiveRadioChannel({
    required this.id,
    required this.name,
    required this.frequency,
    required this.streamUrl,
    required this.host,
    required this.nowTitle,
    required this.nextTitle,
  });

  final String id;
  final String name;
  final String frequency;
  final String streamUrl;
  final String host;
  final String nowTitle;
  final String nextTitle;
}

class LiveFeaturedProgram {
  const LiveFeaturedProgram({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.channelName,
    required this.airDate,
    required this.heroLabel,
    required this.accentColor,
    required this.schedule,
  });

  final String id;
  final String title;
  final String subtitle;
  final String channelName;
  final String airDate;
  final String heroLabel;
  final int accentColor;
  final List<LiveProgramEpisode> schedule;
}

class LiveProgramEpisode {
  const LiveProgramEpisode({
    required this.id,
    required this.title,
    required this.time,
    required this.summary,
    required this.accentColor,
  });

  final String id;
  final String title;
  final String time;
  final String summary;
  final int accentColor;
}

class InteractiveLiveItem {
  const InteractiveLiveItem({
    required this.id,
    required this.title,
    required this.source,
    required this.label,
    required this.kind,
    required this.accentColor,
  });

  final String id;
  final String title;
  final String source;
  final String label;
  final LivePlaybackKind kind;
  final int accentColor;
}

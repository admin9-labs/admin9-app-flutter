enum ArticleVisualType { politics, city, service, sports, culture, live, rural }

enum ArticleMediaType { normal, video }

enum ArticleContentTag {
  politics,
  live,
  video,
  cultureTourism,
  sports,
  politicalVoice,
}

extension ArticleContentTagText on ArticleContentTag {
  String get label {
    return switch (this) {
      ArticleContentTag.politics => '时政',
      ArticleContentTag.live => '直播',
      ArticleContentTag.video => '视频',
      ArticleContentTag.cultureTourism => '文旅',
      ArticleContentTag.sports => '体育',
      ArticleContentTag.politicalVoice => '政声',
    };
  }
}

class ArticleVisualAsset {
  const ArticleVisualAsset({
    required this.label,
    required this.type,
    this.imageUrl,
  });

  final String label;
  final ArticleVisualType type;
  final String? imageUrl;
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.source,
    required this.time,
    required this.summary,
    required this.visuals,
    required this.paragraphs,
    this.contentTag,
    this.mediaType = ArticleMediaType.normal,
    this.duration,
  });

  final String id;
  final String title;
  final String source;
  final String time;
  final String summary;
  final List<ArticleVisualAsset> visuals;
  final List<String> paragraphs;
  final ArticleContentTag? contentTag;
  final ArticleMediaType mediaType;
  final String? duration;

  ArticleVisualAsset get primaryVisual => visuals.first;

  bool get isVideo => mediaType == ArticleMediaType.video;
}

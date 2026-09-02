enum AImageViewerSource { asset, network }

final class AImageViewerItem {
  const AImageViewerItem.asset({
    required String assetName,
    required this.semanticLabel,
  }) : source = AImageViewerSource.asset,
       location = assetName;

  const AImageViewerItem.network({
    required Uri uri,
    required this.semanticLabel,
  }) : source = AImageViewerSource.network,
       location = uri;

  final AImageViewerSource source;
  final Object location;
  final String semanticLabel;
}

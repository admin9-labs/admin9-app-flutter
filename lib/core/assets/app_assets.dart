import '../theme/app_appearance.dart';

abstract final class AppAssets {
  static const xichangPublishIcon = 'assets/images/xichang_publish_icon.png';
  static const topLevelJacarandaHeader =
      'assets/images/top_level_jacaranda_header.png';
  static const topLevelMainstreamRedHeader =
      'assets/images/top_level_mainstream_red_header.png';
  static const topLevelNewsBlueHeader =
      'assets/images/top_level_news_blue_header.png';
  static const topLevelLivelihoodGreenHeader =
      'assets/images/top_level_livelihood_green_header.png';
  static const topLevelHotOrangeHeader =
      'assets/images/top_level_hot_orange_header.png';
  static const topLevelCityGoldHeader =
      'assets/images/top_level_city_gold_header.png';
  static const homeImmersiveChannelDemo = topLevelJacarandaHeader;

  static String topLevelHeaderImage(AppBrandId id) {
    return switch (id) {
      AppBrandId.mainstreamRed => topLevelMainstreamRedHeader,
      AppBrandId.newsBlue => topLevelNewsBlueHeader,
      AppBrandId.livelihoodGreen => topLevelLivelihoodGreenHeader,
      AppBrandId.hotOrange => topLevelHotOrangeHeader,
      AppBrandId.cityGold => topLevelCityGoldHeader,
      AppBrandId.jacarandaBlue => topLevelJacarandaHeader,
    };
  }
}

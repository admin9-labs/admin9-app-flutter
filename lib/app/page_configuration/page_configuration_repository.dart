import 'dart:convert';

import 'package:flutter/services.dart';

import 'page_configuration.dart';

abstract interface class PageConfigurationRepository {
  Future<PageConfiguration> load();
}

final class AssetPageConfigurationRepository
    implements PageConfigurationRepository {
  const AssetPageConfigurationRepository({
    this.assetPath = 'assets/config/page_configuration.json',
  });

  final String assetPath;

  @override
  Future<PageConfiguration> load() async {
    final decoded = jsonDecode(await rootBundle.loadString(assetPath));
    final configuration = PageConfiguration.fromJson(decoded);
    if (configuration == null) {
      throw FormatException(
        'Invalid local page configuration: $assetPath. Check schemaVersion, unique pageId, registered pageType/icons, and page/tab fields.',
      );
    }
    return configuration;
  }
}

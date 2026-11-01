import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'page_configuration.dart';
import 'page_configuration_repository.dart';

final pageConfigurationRepositoryProvider =
    Provider<PageConfigurationRepository>(
      (ref) => const AssetPageConfigurationRepository(),
    );

final pageConfigurationProvider = FutureProvider<PageConfiguration>(
  (ref) => ref.watch(pageConfigurationRepositoryProvider).load(),
);

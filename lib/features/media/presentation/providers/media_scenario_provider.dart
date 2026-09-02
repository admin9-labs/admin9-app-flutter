import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/local_media_scenario_repository.dart';
import '../../data/repositories/media_scenario_repository.dart';

final mediaScenarioRepositoryProvider = Provider<MediaScenarioRepository>(
  (ref) => const LocalMediaScenarioRepository(),
);

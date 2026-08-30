import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/theme_preference.dart';
import '../../data/repositories/theme_preference_repository.dart';
import '../../data/services/theme_preference_service.dart';

final themePreferenceServiceProvider = Provider<ThemePreferenceService>(
  (ref) => ThemePreferenceService(SharedPreferencesAsync()),
);

final themePreferenceRepositoryProvider = Provider<ThemePreferenceRepository>(
  (ref) => SharedPreferencesThemePreferenceRepository(
    ref.watch(themePreferenceServiceProvider),
  ),
);

final themePreferenceProvider =
    AsyncNotifierProvider<ThemePreferenceNotifier, ThemePreference>(
      ThemePreferenceNotifier.new,
      retry: (retryCount, error) => null,
    );

final class ThemePreferenceNotifier extends AsyncNotifier<ThemePreference> {
  @override
  Future<ThemePreference> build() =>
      ref.watch(themePreferenceRepositoryProvider).load();

  Future<void> setPreference(ThemePreference preference) async {
    await ref.read(themePreferenceRepositoryProvider).save(preference);
    if (ref.mounted) {
      state = AsyncData(preference);
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      ref.read(themePreferenceRepositoryProvider).load,
    );
  }
}

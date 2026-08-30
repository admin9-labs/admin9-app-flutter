import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_appearance_preference.dart';
import 'app_appearance_repository.dart';
import 'app_appearance_service.dart';
import 'app_appearance_state.dart';

final appAppearanceServiceProvider = Provider<AppAppearanceService>(
  (ref) => AppAppearanceService(SharedPreferencesAsync()),
);

final appAppearanceRepositoryProvider = Provider<AppAppearanceRepository>(
  (ref) => SharedPreferencesAppAppearanceRepository(
    ref.watch(appAppearanceServiceProvider),
  ),
);

final appAppearanceProvider =
    AsyncNotifierProvider<AppAppearanceNotifier, AppAppearanceState>(
      AppAppearanceNotifier.new,
      retry: (retryCount, error) => null,
    );

final class AppAppearanceNotifier extends AsyncNotifier<AppAppearanceState> {
  @override
  Future<AppAppearanceState> build() async => AppAppearanceState(
    preference: await ref.watch(appAppearanceRepositoryProvider).load(),
  );

  Future<bool> savePreference(AppAppearancePreference preference) async {
    final previous = state.requireValue;
    if (previous.saving || previous.preference == preference) return false;

    state = AsyncData(AppAppearanceState(preference: preference, saving: true));
    try {
      await ref.read(appAppearanceRepositoryProvider).save(preference);
      if (ref.mounted) {
        state = AsyncData(AppAppearanceState(preference: preference));
      }
      return true;
    } on Object {
      if (ref.mounted) {
        state = AsyncData(previous.copyWith(saving: false));
      }
      rethrow;
    }
  }

  Future<bool> reset() => savePreference(AppAppearancePreference.defaults);

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => AppAppearanceState(
        preference: await ref.read(appAppearanceRepositoryProvider).load(),
      ),
    );
  }
}

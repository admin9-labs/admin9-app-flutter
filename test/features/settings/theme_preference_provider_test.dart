import 'package:admin9_app_flutter/features/settings/data/models/theme_preference.dart';
import 'package:admin9_app_flutter/features/settings/data/repositories/theme_preference_repository.dart';
import 'package:admin9_app_flutter/features/settings/presentation/providers/theme_preference_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads through an overridden repository', () async {
    final repository = _FakeThemePreferenceRepository(ThemePreference.dark);
    final container = ProviderContainer.test(
      overrides: [
        themePreferenceRepositoryProvider.overrideWithValue(repository),
      ],
    );

    expect(
      await container.read(themePreferenceProvider.future),
      ThemePreference.dark,
    );
    expect(repository.loadCalls, 1);
  });

  test('does not retry a failed initial load', () async {
    final failure = Exception('load failed');
    final repository = _FakeThemePreferenceRepository(
      ThemePreference.system,
      loadError: failure,
    );
    final container = ProviderContainer.test(
      overrides: [
        themePreferenceRepositoryProvider.overrideWithValue(repository),
      ],
    );

    await expectLater(
      container.read(themePreferenceProvider.future),
      throwsA(same(failure)),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));

    expect(repository.loadCalls, 1);
  });

  test('publishes a saved preference after persistence succeeds', () async {
    final repository = _FakeThemePreferenceRepository(ThemePreference.system);
    final container = ProviderContainer.test(
      overrides: [
        themePreferenceRepositoryProvider.overrideWithValue(repository),
      ],
    );
    await container.read(themePreferenceProvider.future);

    await container
        .read(themePreferenceProvider.notifier)
        .setPreference(ThemePreference.light);

    expect(repository.savedPreferences, [ThemePreference.light]);
    expect(
      container.read(themePreferenceProvider).requireValue,
      ThemePreference.light,
    );
  });

  test('keeps the previous preference when persistence fails', () async {
    final failure = Exception('save failed');
    final repository = _FakeThemePreferenceRepository(
      ThemePreference.dark,
      saveError: failure,
    );
    final container = ProviderContainer.test(
      overrides: [
        themePreferenceRepositoryProvider.overrideWithValue(repository),
      ],
    );
    await container.read(themePreferenceProvider.future);

    await expectLater(
      container
          .read(themePreferenceProvider.notifier)
          .setPreference(ThemePreference.light),
      throwsA(same(failure)),
    );

    expect(repository.savedPreferences, [ThemePreference.light]);
    expect(
      container.read(themePreferenceProvider).requireValue,
      ThemePreference.dark,
    );
  });

  test('reload replaces an error with the latest repository value', () async {
    final repository = _FakeThemePreferenceRepository(
      ThemePreference.system,
      loadError: Exception('load failed'),
    );
    final container = ProviderContainer.test(
      overrides: [
        themePreferenceRepositoryProvider.overrideWithValue(repository),
      ],
    );
    await expectLater(
      container.read(themePreferenceProvider.future),
      throwsException,
    );
    repository
      ..loadError = null
      ..value = ThemePreference.light;

    await container.read(themePreferenceProvider.notifier).reload();

    expect(
      container.read(themePreferenceProvider).requireValue,
      ThemePreference.light,
    );
    expect(repository.loadCalls, 2);
  });
}

final class _FakeThemePreferenceRepository
    implements ThemePreferenceRepository {
  _FakeThemePreferenceRepository(this.value, {this.loadError, this.saveError});

  ThemePreference value;
  Object? loadError;
  Object? saveError;
  int loadCalls = 0;
  final List<ThemePreference> savedPreferences = [];

  @override
  Future<ThemePreference> load() async {
    loadCalls++;
    if (loadError case final error?) {
      throw error;
    }
    return value;
  }

  @override
  Future<void> save(ThemePreference preference) async {
    savedPreferences.add(preference);
    if (saveError case final error?) {
      throw error;
    }
    value = preference;
  }
}

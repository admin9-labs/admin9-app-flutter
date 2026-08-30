import 'package:admin9_app_flutter/features/settings/data/models/theme_preference.dart';
import 'package:admin9_app_flutter/features/settings/data/repositories/theme_preference_repository.dart';
import 'package:admin9_app_flutter/features/settings/data/services/theme_preference_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late SharedPreferencesAsyncPlatform? previousPlatform;

  setUp(() {
    previousPlatform = SharedPreferencesAsyncPlatform.instance;
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = previousPlatform;
  });

  ThemePreferenceRepository repositoryWith(
    SharedPreferencesAsyncPlatform platform,
  ) {
    SharedPreferencesAsyncPlatform.instance = platform;
    return SharedPreferencesThemePreferenceRepository(
      ThemePreferenceService(SharedPreferencesAsync()),
    );
  }

  test('missing preference defaults to system', () async {
    final repository = repositoryWith(InMemorySharedPreferencesAsync.empty());

    expect(await repository.load(), ThemePreference.system);
  });

  test('invalid preference defaults to system', () async {
    final repository = repositoryWith(
      InMemorySharedPreferencesAsync.withData({
        ThemePreferenceService.key: 'sepia',
      }),
    );

    expect(await repository.load(), ThemePreference.system);
  });

  test('loads and saves supported preferences', () async {
    final platform = InMemorySharedPreferencesAsync.withData({
      ThemePreferenceService.key: 'light',
    });
    final repository = repositoryWith(platform);

    expect(await repository.load(), ThemePreference.light);

    await repository.save(ThemePreference.dark);

    expect(await repository.load(), ThemePreference.dark);
    expect(
      await platform.getString(
        ThemePreferenceService.key,
        const SharedPreferencesOptions(),
      ),
      'dark',
    );
  });

  test('read failures are exposed to the caller', () async {
    final repository = repositoryWith(
      _ThrowingPreferencesPlatform(throwOnRead: true),
    );

    await expectLater(repository.load(), throwsA(isA<StateError>()));
  });

  test('write failures are exposed to the caller', () async {
    final repository = repositoryWith(
      _ThrowingPreferencesPlatform(throwOnWrite: true),
    );

    await expectLater(
      () => repository.save(ThemePreference.dark),
      throwsA(isA<StateError>()),
    );
  });
}

base class _ThrowingPreferencesPlatform extends InMemorySharedPreferencesAsync {
  _ThrowingPreferencesPlatform({
    this.throwOnRead = false,
    this.throwOnWrite = false,
  }) : super.empty();

  final bool throwOnRead;
  final bool throwOnWrite;

  @override
  Future<String?> getString(String key, SharedPreferencesOptions options) {
    if (throwOnRead) {
      throw StateError('read failed');
    }
    return super.getString(key, options);
  }

  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) {
    if (throwOnWrite) {
      throw StateError('write failed');
    }
    return super.setString(key, value, options);
  }
}

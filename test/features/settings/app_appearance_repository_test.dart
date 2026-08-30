import 'dart:convert';

import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_repository.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late SharedPreferencesAsyncPlatform? previousPlatform;

  setUp(() => previousPlatform = SharedPreferencesAsyncPlatform.instance);
  tearDown(() => SharedPreferencesAsyncPlatform.instance = previousPlatform);

  AppAppearanceRepository repositoryWith(
    SharedPreferencesAsyncPlatform platform,
  ) {
    SharedPreferencesAsyncPlatform.instance = platform;
    return SharedPreferencesAppAppearanceRepository(
      AppAppearanceService(SharedPreferencesAsync()),
    );
  }

  test('missing and malformed preferences use the complete default', () async {
    final empty = repositoryWith(InMemorySharedPreferencesAsync.empty());
    expect(await empty.load(), AppAppearancePreference.defaults);

    final malformed = repositoryWith(
      InMemorySharedPreferencesAsync.withData({
        AppAppearanceService.key: '{not json',
      }),
    );
    expect(await malformed.load(), AppAppearancePreference.defaults);
  });

  test(
    'loads supported fields and defaults invalid fields independently',
    () async {
      final repository = repositoryWith(
        InMemorySharedPreferencesAsync.withData({
          AppAppearanceService.key: jsonEncode({
            'brightness': 'dark',
            'preset': 'unknown',
            'radius': 'large',
          }),
        }),
      );

      expect(
        await repository.load(),
        const AppAppearancePreference(
          brightness: AppBrightnessPreference.dark,
          preset: AppThemePreset.neutral,
          radius: AppRadiusPreference.large,
        ),
      );
    },
  );

  test('a new repository instance reloads the complete saved value', () async {
    final platform = InMemorySharedPreferencesAsync.empty();
    final repository = repositoryWith(platform);
    const expected = AppAppearancePreference(
      brightness: AppBrightnessPreference.dark,
      preset: AppThemePreset.forest,
      radius: AppRadiusPreference.small,
    );

    await repository.save(expected);
    final restarted = repositoryWith(platform);

    expect(await restarted.load(), expected);
    expect(
      jsonDecode(
        (await platform.getString(
          AppAppearanceService.key,
          const SharedPreferencesOptions(),
        ))!,
      ),
      {'brightness': 'dark', 'preset': 'forest', 'radius': 'small'},
    );
  });

  test('read and write failures remain visible to the notifier', () async {
    final reading = repositoryWith(
      _ThrowingPreferencesPlatform(throwOnRead: true),
    );
    await expectLater(reading.load(), throwsStateError);

    final writing = repositoryWith(
      _ThrowingPreferencesPlatform(throwOnWrite: true),
    );
    await expectLater(
      () => writing.save(AppAppearancePreference.defaults),
      throwsStateError,
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
    if (throwOnRead) throw StateError('read failed');
    return super.getString(key, options);
  }

  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) {
    if (throwOnWrite) throw StateError('write failed');
    return super.setString(key, value, options);
  }
}

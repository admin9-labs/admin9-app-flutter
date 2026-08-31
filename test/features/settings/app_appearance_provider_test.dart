import 'dart:async';

import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_provider.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'publishes immediately, disables overlap, and completes persistence',
    () async {
      final pending = Completer<void>();
      final repository = _FakeRepository(pendingSave: pending);
      final container = ProviderContainer.test(
        overrides: [
          appAppearanceRepositoryProvider.overrideWithValue(repository),
        ],
      );
      await container.read(appAppearanceProvider.future);
      final next = AppAppearancePreference.defaults.copyWith(
        preset: AppThemePreset.ocean,
        radius: AppRadiusPreference.large,
      );

      final save = container
          .read(appAppearanceProvider.notifier)
          .savePreference(next);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(appAppearanceProvider).requireValue.preference,
        next,
      );
      expect(container.read(appAppearanceProvider).requireValue.saving, isTrue);
      expect(
        await container
            .read(appAppearanceProvider.notifier)
            .savePreference(AppAppearancePreference.defaults),
        isFalse,
      );

      pending.complete();
      expect(await save, isTrue);
      expect(
        container.read(appAppearanceProvider).requireValue.saving,
        isFalse,
      );
      expect(repository.saved, [next]);
    },
  );

  test('rolls back an optimistic update when persistence fails', () async {
    final repository = _FakeRepository(saveError: StateError('write failed'));
    final container = ProviderContainer.test(
      overrides: [
        appAppearanceRepositoryProvider.overrideWithValue(repository),
      ],
    );
    await container.read(appAppearanceProvider.future);
    final next = AppAppearancePreference.defaults.copyWith(
      brightness: AppBrightnessPreference.dark,
    );

    await expectLater(
      container.read(appAppearanceProvider.notifier).savePreference(next),
      throwsStateError,
    );

    expect(
      container.read(appAppearanceProvider).requireValue.preference,
      AppAppearancePreference.defaults,
    );
    expect(container.read(appAppearanceProvider).requireValue.saving, isFalse);
  });

  test('retries a failed read and resets every appearance axis', () async {
    final repository = _FakeRepository(loadError: StateError('read failed'));
    final container = ProviderContainer.test(
      overrides: [
        appAppearanceRepositoryProvider.overrideWithValue(repository),
      ],
    );
    await expectLater(
      container.read(appAppearanceProvider.future),
      throwsStateError,
    );
    repository
      ..loadError = null
      ..value = const AppAppearancePreference(
        brightness: AppBrightnessPreference.light,
        preset: AppThemePreset.forest,
        fontSize: AppFontSizePreference.large,
        radius: AppRadiusPreference.large,
      );

    await container.read(appAppearanceProvider.notifier).reload();
    expect(
      container.read(appAppearanceProvider).requireValue.preference,
      repository.value,
    );

    await container.read(appAppearanceProvider.notifier).reset();
    expect(
      container.read(appAppearanceProvider).requireValue.preference,
      AppAppearancePreference.defaults,
    );
  });
}

final class _FakeRepository implements AppAppearanceRepository {
  _FakeRepository({this.loadError, this.saveError, this.pendingSave});

  AppAppearancePreference value = AppAppearancePreference.defaults;
  Object? loadError;
  Object? saveError;
  Completer<void>? pendingSave;
  final List<AppAppearancePreference> saved = [];

  @override
  Future<AppAppearancePreference> load() async {
    if (loadError case final error?) throw error;
    return value;
  }

  @override
  Future<void> save(AppAppearancePreference preference) async {
    saved.add(preference);
    if (saveError case final error?) throw error;
    if (pendingSave case final pending?) await pending.future;
    value = preference;
  }
}

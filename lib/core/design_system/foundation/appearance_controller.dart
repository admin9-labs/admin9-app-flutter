import '../../preferences/app_preferences.dart';
import 'app_appearance.dart';

class AppearanceController extends AppAppearanceController {
  AppearanceController(this._preferences)
    : _appearance = AppAppearance(
        theme: AppThemePreference.parse(_preferences.themeMode),
        fontScale: AppFontScale.parse(_preferences.fontScale),
        grayscale: _preferences.grayscale,
        highContrast: _preferences.highContrast,
        reduceMotion: _preferences.reduceMotion,
      );

  final AppPreferences _preferences;
  AppAppearance _appearance;
  Future<void> _pendingWrite = Future<void>.value();
  final Map<_AppearancePreferenceKey, int> _writeVersions = {};
  final Map<_AppearancePreferenceKey, _FailedAppearanceWrite> _failedWrites =
      {};

  @override
  AppAppearance get appearance => _appearance;
  @override
  bool get persistenceFailed => _failedWrites.isNotEmpty;

  @override
  Future<void> setTheme(AppThemePreference value) async {
    _appearance = _appearance.copyWith(theme: value);
    notifyListeners();
    await _enqueueWrite(
      _AppearancePreferenceKey.theme,
      () => _preferences.setThemeMode(value.name),
    );
  }

  @override
  Future<void> setFontScale(AppFontScale value) async {
    _appearance = _appearance.copyWith(fontScale: value);
    notifyListeners();
    await _enqueueWrite(
      _AppearancePreferenceKey.fontScale,
      () => _preferences.setFontScale(value.name),
    );
  }

  @override
  Future<void> setGrayscale(bool value) async {
    _appearance = _appearance.copyWith(grayscale: value);
    notifyListeners();
    await _enqueueWrite(
      _AppearancePreferenceKey.grayscale,
      () => _preferences.setGrayscale(value),
    );
  }

  @override
  Future<void> setHighContrast(bool value) async {
    _appearance = _appearance.copyWith(highContrast: value);
    notifyListeners();
    await _enqueueWrite(
      _AppearancePreferenceKey.highContrast,
      () => _preferences.setHighContrast(value),
    );
  }

  @override
  Future<void> setReduceMotion(bool value) async {
    _appearance = _appearance.copyWith(reduceMotion: value);
    notifyListeners();
    await _enqueueWrite(
      _AppearancePreferenceKey.reduceMotion,
      () => _preferences.setReduceMotion(value),
    );
  }

  @override
  Future<void> retryPersistence() async {
    for (final entry in _failedWrites.entries.toList(growable: false)) {
      final failure = entry.value;
      if (_writeVersions[entry.key] != failure.version ||
          !identical(_failedWrites[entry.key], failure)) {
        continue;
      }
      await _enqueueWrite(entry.key, failure.write, version: failure.version);
    }
  }

  Future<void> _enqueueWrite(
    _AppearancePreferenceKey key,
    Future<bool> Function() write, {
    int? version,
  }) {
    final effectiveVersion = version ?? ((_writeVersions[key] ?? 0) + 1);
    if (version == null) _writeVersions[key] = effectiveVersion;
    _pendingWrite = _pendingWrite.then((_) async {
      var failed = false;
      try {
        failed = !await write();
      } catch (_) {
        failed = true;
      }
      if (_writeVersions[key] != effectiveVersion) return;
      final wasFailed = _failedWrites.isNotEmpty;
      if (failed) {
        _failedWrites[key] = _FailedAppearanceWrite(effectiveVersion, write);
      } else {
        _failedWrites.remove(key);
      }
      if (wasFailed != _failedWrites.isNotEmpty || failed) {
        notifyListeners();
      }
    });
    return _pendingWrite;
  }
}

enum _AppearancePreferenceKey {
  theme,
  fontScale,
  grayscale,
  highContrast,
  reduceMotion,
}

final class _FailedAppearanceWrite {
  const _FailedAppearanceWrite(this.version, this.write);

  final int version;
  final Future<bool> Function() write;
}

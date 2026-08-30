import 'app_appearance_preference.dart';

final class AppAppearanceState {
  const AppAppearanceState({required this.preference, this.saving = false});

  final AppAppearancePreference preference;
  final bool saving;

  AppAppearanceState copyWith({
    AppAppearancePreference? preference,
    bool? saving,
  }) => AppAppearanceState(
    preference: preference ?? this.preference,
    saving: saving ?? this.saving,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppAppearanceState &&
          preference == other.preference &&
          saving == other.saving;

  @override
  int get hashCode => Object.hash(preference, saving);
}

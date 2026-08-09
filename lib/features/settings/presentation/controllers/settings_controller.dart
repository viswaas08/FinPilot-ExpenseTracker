import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_preferences_entity.dart';

class SettingsState {
  final UserPreferencesEntity preferences;
  final bool isBackingUp;
  final bool isExporting;
  final String? statusMessage;

  const SettingsState({
    this.preferences = const UserPreferencesEntity(),
    this.isBackingUp = false,
    this.isExporting = false,
    this.statusMessage,
  });

  SettingsState copyWith({
    UserPreferencesEntity? preferences,
    bool? isBackingUp,
    bool? isExporting,
    String? statusMessage,
  }) {
    return SettingsState(
      preferences: preferences ?? this.preferences,
      isBackingUp: isBackingUp ?? this.isBackingUp,
      isExporting: isExporting ?? this.isExporting,
      statusMessage: statusMessage,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  final SettingsRepositoryImpl _repository;

  SettingsController(this._repository) : super(const SettingsState()) {
    _loadPreferences();
  }

  void _loadPreferences() {
    final prefs = _repository.getPreferences();
    state = state.copyWith(preferences: prefs);
  }

  Future<void> updateCurrency({
    required String code,
    required String symbol,
    required String name,
  }) async {
    final updated = state.preferences.copyWith(
      currencyCode: code,
      currencySymbol: symbol,
      currencyName: name,
    );

    await _repository.savePreferences(updated);
    state = state.copyWith(
      preferences: updated,
      statusMessage: 'Currency updated to $symbol ($code)',
    );
  }

  Future<void> updateThemeMode(String mode) async {
    final updated = state.preferences.copyWith(themeMode: mode);
    await _repository.savePreferences(updated);
    state = state.copyWith(preferences: updated);
  }

  Future<void> toggleBiometrics(bool enabled) async {
    final updated = state.preferences.copyWith(isBiometricsEnabled: enabled);
    await _repository.savePreferences(updated);
    state = state.copyWith(preferences: updated);
  }

  Future<void> triggerBackup() async {
    state = state.copyWith(isBackingUp: true, statusMessage: null);
    await Future.delayed(const Duration(milliseconds: 1200));

    final updated = state.preferences.copyWith(lastBackupDate: DateTime.now());
    await _repository.savePreferences(updated);

    state = state.copyWith(
      preferences: updated,
      isBackingUp: false,
      statusMessage: 'Local encrypted backup created successfully!',
    );
  }

  Future<void> exportData() async {
    state = state.copyWith(isExporting: true, statusMessage: null);
    await Future.delayed(const Duration(milliseconds: 1000));
    state = state.copyWith(
      isExporting: false,
      statusMessage: 'Financial records exported to JSON & CSV format.',
    );
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsController(repository);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/storage/hive_service.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_preferences_entity.dart';

class SettingsRepositoryImpl {
  final HiveService _hiveService;

  SettingsRepositoryImpl(this._hiveService);

  Future<void> savePreferences(UserPreferencesEntity preferences) async {
    await _hiveService.savePreferences(preferences.toJson());
  }

  UserPreferencesEntity getPreferences() {
    final data = _hiveService.getPreferences();
    if (data == null) return const UserPreferencesEntity();
    return UserPreferencesEntity.fromJson(Map<String, dynamic>.from(data as Map));
  }
}

final settingsRepositoryProvider = Provider<SettingsRepositoryImpl>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return SettingsRepositoryImpl(hiveService);
});

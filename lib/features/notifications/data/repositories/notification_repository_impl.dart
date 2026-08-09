import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/storage/hive_service.dart';
import 'package:expense_tracker/features/notifications/domain/entities/notification_entity.dart';
import 'package:expense_tracker/features/notifications/domain/entities/notification_settings_entity.dart';

class NotificationRepositoryImpl {
  final HiveService _hiveService;

  NotificationRepositoryImpl(this._hiveService);

  Future<void> saveNotification(NotificationEntity notification) async {
    await _hiveService.saveNotification(notification.id, notification.toJson());
  }

  List<NotificationEntity> getAllNotifications() {
    final rawList = _hiveService.getAllNotifications();
    return rawList.map((e) => NotificationEntity.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> deleteNotification(String id) async {
    await _hiveService.deleteNotification(id);
  }

  Future<void> clearAllNotifications() async {
    await _hiveService.clearAllNotifications();
  }

  Future<void> saveSettings(NotificationSettingsEntity settings) async {
    await _hiveService.saveNotificationSettings(settings.toJson());
  }

  NotificationSettingsEntity getSettings() {
    final data = _hiveService.getNotificationSettings();
    if (data == null) return const NotificationSettingsEntity();
    return NotificationSettingsEntity.fromJson(Map<String, dynamic>.from(data as Map));
  }
}

final notificationRepositoryProvider = Provider<NotificationRepositoryImpl>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return NotificationRepositoryImpl(hiveService);
});

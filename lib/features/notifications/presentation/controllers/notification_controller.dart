import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:expense_tracker/features/notifications/domain/entities/notification_entity.dart';
import 'package:expense_tracker/features/notifications/domain/entities/notification_settings_entity.dart';

class NotificationState {
  final List<NotificationEntity> notifications;
  final NotificationCategory? selectedCategory; // null = ALL
  final NotificationSettingsEntity settings;
  final int unreadCount;
  final bool isLoading;

  const NotificationState({
    this.notifications = const [],
    this.selectedCategory,
    this.settings = const NotificationSettingsEntity(),
    this.unreadCount = 0,
    this.isLoading = false,
  });

  List<NotificationEntity> get filteredNotifications {
    if (selectedCategory == null) return notifications;
    return notifications.where((n) => n.category == selectedCategory).toList();
  }

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    NotificationCategory? selectedCategory,
    bool clearCategory = false,
    NotificationSettingsEntity? settings,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      settings: settings ?? this.settings,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationController extends StateNotifier<NotificationState> {
  final NotificationRepositoryImpl _repository;

  NotificationController(this._repository) : super(const NotificationState()) {
    _loadOrInitializeNotifications();
  }

  void _loadOrInitializeNotifications() {
    List<NotificationEntity> list = _repository.getAllNotifications();
    final settings = _repository.getSettings();

    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final unread = list.where((n) => !n.isRead).length;

    state = state.copyWith(
      notifications: list,
      settings: settings,
      unreadCount: unread,
    );
  }

  void setCategoryFilter(NotificationCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
  }

  Future<void> markAsRead(String id) async {
    final list = state.notifications.map((n) {
      if (n.id == id) {
        final updated = n.copyWith(isRead: true);
        _repository.saveNotification(updated);
        return updated;
      }
      return n;
    }).toList();

    final unread = list.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: list, unreadCount: unread);
  }

  Future<void> markAllAsRead() async {
    final list = state.notifications.map((n) {
      final updated = n.copyWith(isRead: true);
      _repository.saveNotification(updated);
      return updated;
    }).toList();

    state = state.copyWith(notifications: list, unreadCount: 0);
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
    _loadOrInitializeNotifications();
  }

  Future<void> clearAll() async {
    await _repository.clearAllNotifications();
    state = state.copyWith(notifications: [], unreadCount: 0);
  }

  Future<void> updateSettings(NotificationSettingsEntity newSettings) async {
    await _repository.saveSettings(newSettings);
    state = state.copyWith(settings: newSettings);
  }
}

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationController(repository);
});

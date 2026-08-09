enum NotificationCategory { bills, budgets, goals, recurring, aiInsights, system }

class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationCategory category;
  final bool isRead;
  final String? payload;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    this.isRead = false,
    this.payload,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationCategory? category,
    bool? isRead,
    String? payload,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      payload: payload ?? this.payload,
    );
  }

  factory NotificationEntity.fromJson(Map<String, dynamic> jsonInput) {
    final json = Map<String, dynamic>.from(jsonInput);
    return NotificationEntity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Notification Alert',
      body: json['body'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      category: NotificationCategory.values.firstWhere(
        (c) => c.name == (json['category'] as String? ?? 'system'),
        orElse: () => NotificationCategory.system,
      ),
      isRead: json['isRead'] as bool? ?? false,
      payload: json['payload'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'category': category.name,
      'isRead': isRead,
      'payload': payload,
    };
  }
}

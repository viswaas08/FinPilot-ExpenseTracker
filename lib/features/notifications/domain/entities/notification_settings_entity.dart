class NotificationSettingsEntity {
  final bool isDailyReminderEnabled;
  final bool isBillReminderEnabled;
  final bool isBudgetAlertEnabled;
  final bool isGoalReminderEnabled;
  final bool isAIInsightsEnabled;
  final String reminderTime; // e.g. "20:00"

  const NotificationSettingsEntity({
    this.isDailyReminderEnabled = true,
    this.isBillReminderEnabled = true,
    this.isBudgetAlertEnabled = true,
    this.isGoalReminderEnabled = true,
    this.isAIInsightsEnabled = true,
    this.reminderTime = '20:00',
  });

  NotificationSettingsEntity copyWith({
    bool? isDailyReminderEnabled,
    bool? isBillReminderEnabled,
    bool? isBudgetAlertEnabled,
    bool? isGoalReminderEnabled,
    bool? isAIInsightsEnabled,
    String? reminderTime,
  }) {
    return NotificationSettingsEntity(
      isDailyReminderEnabled: isDailyReminderEnabled ?? this.isDailyReminderEnabled,
      isBillReminderEnabled: isBillReminderEnabled ?? this.isBillReminderEnabled,
      isBudgetAlertEnabled: isBudgetAlertEnabled ?? this.isBudgetAlertEnabled,
      isGoalReminderEnabled: isGoalReminderEnabled ?? this.isGoalReminderEnabled,
      isAIInsightsEnabled: isAIInsightsEnabled ?? this.isAIInsightsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  factory NotificationSettingsEntity.fromJson(Map<String, dynamic> jsonInput) {
    final json = Map<String, dynamic>.from(jsonInput);
    return NotificationSettingsEntity(
      isDailyReminderEnabled: json['isDailyReminderEnabled'] as bool? ?? true,
      isBillReminderEnabled: json['isBillReminderEnabled'] as bool? ?? true,
      isBudgetAlertEnabled: json['isBudgetAlertEnabled'] as bool? ?? true,
      isGoalReminderEnabled: json['isGoalReminderEnabled'] as bool? ?? true,
      isAIInsightsEnabled: json['isAIInsightsEnabled'] as bool? ?? true,
      reminderTime: json['reminderTime'] as String? ?? '20:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDailyReminderEnabled': isDailyReminderEnabled,
      'isBillReminderEnabled': isBillReminderEnabled,
      'isBudgetAlertEnabled': isBudgetAlertEnabled,
      'isGoalReminderEnabled': isGoalReminderEnabled,
      'isAIInsightsEnabled': isAIInsightsEnabled,
      'reminderTime': reminderTime,
    };
  }
}

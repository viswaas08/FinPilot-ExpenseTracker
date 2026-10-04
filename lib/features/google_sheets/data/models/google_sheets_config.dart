class GoogleSheetsConfig {
  final bool isConnected;
  final String? accountEmail;
  final String? spreadsheetId;
  final String? spreadsheetUrl;
  final DateTime? lastSyncTime;
  final bool autoSyncEnabled;
  final List<String> activeSheets;

  const GoogleSheetsConfig({
    this.isConnected = false,
    this.accountEmail,
    this.spreadsheetId,
    this.spreadsheetUrl,
    this.lastSyncTime,
    this.autoSyncEnabled = false,
    this.activeSheets = const [
      'Dashboard',
      'Transactions',
      'Accounts',
      'Budgets',
      'Goals',
      'Subscriptions',
    ],
  });

  GoogleSheetsConfig copyWith({
    bool? isConnected,
    String? accountEmail,
    String? spreadsheetId,
    String? spreadsheetUrl,
    DateTime? lastSyncTime,
    bool? autoSyncEnabled,
    List<String>? activeSheets,
  }) {
    return GoogleSheetsConfig(
      isConnected: isConnected ?? this.isConnected,
      accountEmail: accountEmail ?? this.accountEmail,
      spreadsheetId: spreadsheetId ?? this.spreadsheetId,
      spreadsheetUrl: spreadsheetUrl ?? this.spreadsheetUrl,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      activeSheets: activeSheets ?? this.activeSheets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isConnected': isConnected,
      'accountEmail': accountEmail,
      'spreadsheetId': spreadsheetId,
      'spreadsheetUrl': spreadsheetUrl,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'autoSyncEnabled': autoSyncEnabled,
      'activeSheets': activeSheets,
    };
  }

  factory GoogleSheetsConfig.fromMap(Map<String, dynamic> map) {
    return GoogleSheetsConfig(
      isConnected: map['isConnected'] as bool? ?? false,
      accountEmail: map['accountEmail'] as String?,
      spreadsheetId: map['spreadsheetId'] as String?,
      spreadsheetUrl: map['spreadsheetUrl'] as String?,
      lastSyncTime: map['lastSyncTime'] != null ? DateTime.tryParse(map['lastSyncTime']) : null,
      autoSyncEnabled: map['autoSyncEnabled'] as bool? ?? false,
      activeSheets: (map['activeSheets'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [
        'Dashboard',
        'Transactions',
        'Accounts',
        'Budgets',
        'Goals',
        'Subscriptions',
      ],
    );
  }
}

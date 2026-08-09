class UserPreferencesEntity {
  final String currencyCode;
  final String currencySymbol;
  final String currencyName;
  final String themeMode; // 'dark', 'light', 'system'
  final bool isBiometricsEnabled;
  final String languageCode;
  final DateTime? lastBackupDate;

  const UserPreferencesEntity({
    this.currencyCode = 'INR',
    this.currencySymbol = '₹',
    this.currencyName = 'Indian Rupee',
    this.themeMode = 'dark',
    this.isBiometricsEnabled = true,
    this.languageCode = 'en',
    this.lastBackupDate,
  });

  UserPreferencesEntity copyWith({
    String? currencyCode,
    String? currencySymbol,
    String? currencyName,
    String? themeMode,
    bool? isBiometricsEnabled,
    String? languageCode,
    DateTime? lastBackupDate,
  }) {
    return UserPreferencesEntity(
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyName: currencyName ?? this.currencyName,
      themeMode: themeMode ?? this.themeMode,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      languageCode: languageCode ?? this.languageCode,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
    );
  }

  factory UserPreferencesEntity.fromJson(Map<String, dynamic> jsonInput) {
    final json = Map<String, dynamic>.from(jsonInput);
    return UserPreferencesEntity(
      currencyCode: json['currencyCode'] as String? ?? 'INR',
      currencySymbol: json['currencySymbol'] as String? ?? '₹',
      currencyName: json['currencyName'] as String? ?? 'Indian Rupee',
      themeMode: json['themeMode'] as String? ?? 'dark',
      isBiometricsEnabled: json['isBiometricsEnabled'] as bool? ?? true,
      languageCode: json['languageCode'] as String? ?? 'en',
      lastBackupDate: json['lastBackupDate'] != null
          ? DateTime.parse(json['lastBackupDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'currencyName': currencyName,
      'themeMode': themeMode,
      'isBiometricsEnabled': isBiometricsEnabled,
      'languageCode': languageCode,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
    };
  }
}

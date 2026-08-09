import 'package:flutter/material.dart';

class SavingsContribution {
  final String id;
  final double amount;
  final DateTime date;
  final String? note;

  const SavingsContribution({
    required this.id,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory SavingsContribution.fromJson(Map<String, dynamic> jsonInput) {
    final json = Map<String, dynamic>.from(jsonInput);
    return SavingsContribution(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      note: json['note'] as String?,
    );
  }
}

class SavingsGoalEntity {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final int iconCodePoint;
  final String? iconFontFamily;
  final int colorValue;
  final bool isCompleted;
  final List<SavingsContribution> contributions;

  const SavingsGoalEntity({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.targetDate,
    required this.createdAt,
    this.iconCodePoint = 0xe579, // Icons.savings_rounded
    this.iconFontFamily = 'MaterialIcons',
    this.colorValue = 0xFF2563EB,
    this.isCompleted = false,
    this.contributions = const [],
  });

  double get percentageSaved =>
      targetAmount > 0 ? (savedAmount / targetAmount * 100).clamp(0.0, 100.0) : 0.0;

  double get remainingAmount => (targetAmount - savedAmount).clamp(0.0, targetAmount);

  int get daysLeft => targetDate.difference(DateTime.now()).inDays.clamp(0, 9999);

  double get dailySavingsNeeded {
    final days = daysLeft;
    if (days <= 0 || remainingAmount <= 0) return 0.0;
    return remainingAmount / days;
  }

  bool get isOnTrack {
    final totalDays = targetDate.difference(createdAt).inDays;
    if (totalDays <= 0) return percentageSaved >= 100;
    final daysPassed = DateTime.now().difference(createdAt).inDays;
    final expectedPct = (daysPassed / totalDays * 100).clamp(0.0, 100.0);
    return percentageSaved >= expectedPct;
  }

  static const Map<int, IconData> _iconMap = {
    0xe579: Icons.savings_rounded,
    0xe39d: Icons.laptop_mac_rounded,
    0xe801: Icons.flight_takeoff_rounded,
    0xe1d7: Icons.directions_car_rounded,
    0xe88a: Icons.home_rounded,
    0xf016e: Icons.shopping_bag_rounded,
    0xe80c: Icons.school_rounded,
    0xeb43: Icons.fitness_center_rounded,
  };

  IconData get icon => _iconMap[iconCodePoint] ?? Icons.savings_rounded;
  Color get color => Color(colorValue);

  SavingsGoalEntity copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    int? iconCodePoint,
    String? iconFontFamily,
    int? colorValue,
    bool? isCompleted,
    List<SavingsContribution>? contributions,
  }) {
    return SavingsGoalEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      colorValue: colorValue ?? this.colorValue,
      isCompleted: isCompleted ?? this.isCompleted,
      contributions: contributions ?? this.contributions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'targetDate': targetDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'iconCodePoint': iconCodePoint,
        'iconFontFamily': iconFontFamily,
        'colorValue': colorValue,
        'isCompleted': isCompleted,
        'contributions': contributions.map((c) => c.toJson()).toList(),
      };

  factory SavingsGoalEntity.fromJson(Map<String, dynamic> jsonInput) {
    final json = Map<String, dynamic>.from(jsonInput);
    return SavingsGoalEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Custom Goal',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate'] as String) : DateTime.now(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      iconCodePoint: json['iconCodePoint'] as int? ?? 0xe579,
      iconFontFamily: json['iconFontFamily'] as String?,
      colorValue: json['colorValue'] as int? ?? 0xFF2563EB,
      isCompleted: json['isCompleted'] as bool? ?? false,
      contributions: (json['contributions'] as List<dynamic>?)
              ?.map((e) => SavingsContribution.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );
  }
}

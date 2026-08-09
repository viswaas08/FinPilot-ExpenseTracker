import 'package:flutter/material.dart';

class TransactionCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double monthlyBudget;
  final bool isCustom;

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.monthlyBudget = 0.0,
    this.isCustom = false,
  });

  TransactionCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    double? monthlyBudget,
    bool? isCustom,
  }) {
    return TransactionCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  factory TransactionCategory.fromJson(Map<String, dynamic> jsonInput) {
    final json = Map<String, dynamic>.from(jsonInput);
    final name = json['name'] as String? ?? 'Others';
    final match = defaultCategories.firstWhere(
      (c) => c.name == name,
      orElse: () => defaultCategories.last,
    );
    return match.copyWith(
      id: json['id'] as String? ?? match.id,
      name: name,
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble() ?? match.monthlyBudget,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'colorValue': color.toARGB32(),
      'monthlyBudget': monthlyBudget,
      'isCustom': isCustom,
    };
  }

  static const List<TransactionCategory> defaultCategories = [
    TransactionCategory(
      id: 'cat_food',
      name: 'Food',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF9F0A),
      monthlyBudget: 500.0,
      isCustom: false,
    ),
    TransactionCategory(
      id: 'cat_shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFFF3B30),
      monthlyBudget: 350.0,
      isCustom: false,
    ),
    TransactionCategory(
      id: 'cat_transport',
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF06B6D4),
      monthlyBudget: 200.0,
      isCustom: false,
    ),
    TransactionCategory(
      id: 'cat_bills',
      name: 'Bills',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF007AFF),
      monthlyBudget: 800.0,
      isCustom: false,
    ),
    TransactionCategory(
      id: 'cat_health',
      name: 'Health',
      icon: Icons.medical_services_rounded,
      color: Color(0xFFFF2D55),
      monthlyBudget: 150.0,
      isCustom: false,
    ),
    TransactionCategory(
      id: 'cat_education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF5856D6),
      monthlyBudget: 400.0,
      isCustom: false,
    ),
    TransactionCategory(
      id: 'cat_entertainment',
      name: 'Entertainment',
      icon: Icons.movie_creation_rounded,
      color: Color(0xFFAF52DE),
      monthlyBudget: 250.0,
      isCustom: false,
    ),
    TransactionCategory(
      id: 'cat_travel',
      name: 'Travel',
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF34C759),
      monthlyBudget: 600.0,
      isCustom: false,
    ),
    TransactionCategory(
      id: 'cat_others',
      name: 'Others',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF64D2FF),
      monthlyBudget: 100.0,
      isCustom: false,
    ),
  ];
}

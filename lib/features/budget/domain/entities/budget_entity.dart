class CategoryBudget {
  final String categoryName;
  final double limitAmount;
  final double spentAmount;

  const CategoryBudget({
    required this.categoryName,
    required this.limitAmount,
    this.spentAmount = 0.0,
  });

  double get remainingAmount => (limitAmount - spentAmount).clamp(0.0, double.infinity);
  double get percentageUsed => limitAmount > 0 ? (spentAmount / limitAmount) * 100 : 0.0;

  CategoryBudget copyWith({
    String? categoryName,
    double? limitAmount,
    double? spentAmount,
  }) {
    return CategoryBudget(
      categoryName: categoryName ?? this.categoryName,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }

  factory CategoryBudget.fromJson(Map<String, dynamic> jsonInput) {
    final json = Map<String, dynamic>.from(jsonInput);
    return CategoryBudget(
      categoryName: json['categoryName'] as String? ?? 'General',
      limitAmount: (json['limitAmount'] as num?)?.toDouble() ?? 500.0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
    };
  }
}

class BudgetEntity {
  final String id;
  final String monthYear; // e.g. "2026-08"
  final double totalLimit;
  final List<CategoryBudget> categoryBudgets;
  final bool isCarryForwardEnabled;
  final DateTime createdAt;

  const BudgetEntity({
    required this.id,
    required this.monthYear,
    required this.totalLimit,
    required this.categoryBudgets,
    this.isCarryForwardEnabled = false,
    required this.createdAt,
  });

  factory BudgetEntity.fromJson(Map<String, dynamic> jsonInput) {
    final json = Map<String, dynamic>.from(jsonInput);
    return BudgetEntity(
      id: json['id'] as String? ?? '',
      monthYear: json['monthYear'] as String? ?? '2026-08',
      totalLimit: (json['totalLimit'] as num?)?.toDouble() ?? 2500.0,
      categoryBudgets: (json['categoryBudgets'] as List?)
              ?.map((e) => CategoryBudget.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      isCarryForwardEnabled: json['isCarryForwardEnabled'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthYear': monthYear,
      'totalLimit': totalLimit,
      'categoryBudgets': categoryBudgets.map((e) => e.toJson()).toList(),
      'isCarryForwardEnabled': isCarryForwardEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  BudgetEntity copyWith({
    String? id,
    String? monthYear,
    double? totalLimit,
    List<CategoryBudget>? categoryBudgets,
    bool? isCarryForwardEnabled,
    DateTime? createdAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      monthYear: monthYear ?? this.monthYear,
      totalLimit: totalLimit ?? this.totalLimit,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      isCarryForwardEnabled: isCarryForwardEnabled ?? this.isCarryForwardEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

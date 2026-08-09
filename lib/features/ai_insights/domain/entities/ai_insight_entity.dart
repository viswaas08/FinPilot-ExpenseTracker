class SavingSuggestion {
  final String title;
  final String description;
  final double estimatedMonthlySavings;
  final String priority; // 'High', 'Medium', 'Low'
  final String categoryName;

  const SavingSuggestion({
    required this.title,
    required this.description,
    required this.estimatedMonthlySavings,
    required this.priority,
    required this.categoryName,
  });

  factory SavingSuggestion.fromJson(Map<String, dynamic> json) {
    return SavingSuggestion(
      title: json['title'] as String? ?? 'Optimize Expenses',
      description: json['description'] as String? ?? 'Review recent transactions.',
      estimatedMonthlySavings: (json['estimatedMonthlySavings'] as num?)?.toDouble() ?? 45.0,
      priority: json['priority'] as String? ?? 'Medium',
      categoryName: json['categoryName'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'estimatedMonthlySavings': estimatedMonthlySavings,
      'priority': priority,
      'categoryName': categoryName,
    };
  }
}

class SpendingHabit {
  final String habit;
  final String type; // 'warning', 'positive', 'neutral'
  final String impact;

  const SpendingHabit({
    required this.habit,
    required this.type,
    required this.impact,
  });

  factory SpendingHabit.fromJson(Map<String, dynamic> json) {
    return SpendingHabit(
      habit: json['habit'] as String? ?? 'Consistent Spending',
      type: json['type'] as String? ?? 'neutral',
      impact: json['impact'] as String? ?? 'Moderate',
    );
  }

  Map<String, dynamic> toJson() => {'habit': habit, 'type': type, 'impact': impact};
}

class BudgetWarning {
  final String warning;
  final String severity; // 'critical', 'warning', 'info'
  final double percentageIncrease;

  const BudgetWarning({
    required this.warning,
    required this.severity,
    required this.percentageIncrease,
  });

  factory BudgetWarning.fromJson(Map<String, dynamic> json) {
    return BudgetWarning(
      warning: json['warning'] as String? ?? 'Budget threshold alert',
      severity: json['severity'] as String? ?? 'warning',
      percentageIncrease: (json['percentageIncrease'] as num?)?.toDouble() ?? 12.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'warning': warning,
        'severity': severity,
        'percentageIncrease': percentageIncrease,
      };
}

class AIInsightEntity {
  final int financialScore; // 0 - 100
  final String healthLabel; // e.g. "Good Financial Health"
  final double predictedNextMonthSpending;
  final double predictedSavings;
  final String predictionRiskLevel; // 'Low', 'Moderate', 'High'
  final List<SavingSuggestion> savingSuggestions;
  final List<SpendingHabit> spendingHabits;
  final List<BudgetWarning> budgetWarnings;
  final List<String> positiveHabits;
  final List<String> areasForImprovement;
  final int confidenceScore; // 0 - 100
  final DateTime generatedAt;

  const AIInsightEntity({
    required this.financialScore,
    required this.healthLabel,
    required this.predictedNextMonthSpending,
    required this.predictedSavings,
    required this.predictionRiskLevel,
    required this.savingSuggestions,
    required this.spendingHabits,
    required this.budgetWarnings,
    required this.positiveHabits,
    required this.areasForImprovement,
    required this.confidenceScore,
    required this.generatedAt,
  });

  factory AIInsightEntity.fromJson(Map<String, dynamic> json) {
    return AIInsightEntity(
      financialScore: (json['financialScore'] as num?)?.toInt() ?? 82,
      healthLabel: json['healthLabel'] as String? ?? 'Good Financial Health',
      predictedNextMonthSpending:
          (json['predictedNextMonthSpending'] as num?)?.toDouble() ?? 1420.00,
      predictedSavings: (json['predictedSavings'] as num?)?.toDouble() ?? 380.00,
      predictionRiskLevel: json['predictionRiskLevel'] as String? ?? 'Low',
      savingSuggestions: (json['savingSuggestions'] as List?)
              ?.map((e) => SavingSuggestion.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      spendingHabits: (json['spendingHabits'] as List?)
              ?.map((e) => SpendingHabit.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      budgetWarnings: (json['budgetWarnings'] as List?)
              ?.map((e) => BudgetWarning.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      positiveHabits:
          (json['positiveHabits'] as List?)?.map((e) => e.toString()).toList() ?? [],
      areasForImprovement:
          (json['areasForImprovement'] as List?)?.map((e) => e.toString()).toList() ?? [],
      confidenceScore: (json['confidenceScore'] as num?)?.toInt() ?? 94,
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'financialScore': financialScore,
      'healthLabel': healthLabel,
      'predictedNextMonthSpending': predictedNextMonthSpending,
      'predictedSavings': predictedSavings,
      'predictionRiskLevel': predictionRiskLevel,
      'savingSuggestions': savingSuggestions.map((e) => e.toJson()).toList(),
      'spendingHabits': spendingHabits.map((e) => e.toJson()).toList(),
      'budgetWarnings': budgetWarnings.map((e) => e.toJson()).toList(),
      'positiveHabits': positiveHabits,
      'areasForImprovement': areasForImprovement,
      'confidenceScore': confidenceScore,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

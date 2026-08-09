import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/presentation/widgets/empty_state_view.dart';
import 'package:expense_tracker/core/presentation/widgets/error_banner.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/ai_insights/presentation/controllers/ai_insights_controller.dart';

import 'package:expense_tracker/features/ai_insights/presentation/widgets/ai_loading_orb_view.dart';
import 'package:expense_tracker/features/ai_insights/presentation/widgets/ai_score_hero_card.dart';
import 'package:expense_tracker/features/ai_insights/presentation/widgets/budget_warning_card.dart';
import 'package:expense_tracker/features/ai_insights/presentation/widgets/prediction_chart_card.dart';
import 'package:expense_tracker/features/ai_insights/presentation/widgets/saving_suggestion_card.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';

class AIInsightsScreen extends ConsumerWidget {
  const AIInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiInsightsControllerProvider);
    final controller = ref.read(aiInsightsControllerProvider.notifier);
    final expenseState = ref.watch(expenseControllerProvider);

    final insight = state.insight;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Financial Insights',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: textColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: textColor),
                onPressed: () {
                  controller.fetchInsights(expenseState.expenses);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
              if (state.isLoading)
                AILoadingOrbView(loadingMessage: state.loadingMessage)
              else if (state.errorMessage != null)
                ErrorBanner(
                  message: state.errorMessage!,
                  onRetry: () => controller.fetchInsights(expenseState.expenses),
                )
              else if (insight == null || expenseState.expenses.isEmpty)
                EmptyStateView(
                  title: 'Unlock AI Financial Insights',
                  description: 'Add your first transaction records to unlock Gemini AI-powered spending predictions and saving recommendations.',
                  buttonText: 'Add Expense',
                  icon: Icons.auto_awesome_rounded,
                  onAction: () => context.push('/add-expense'),
                )
              else ...[
                // 1. AI Score Hero Card
                AIScoreHeroCard(
                  score: insight.financialScore,
                  healthLabel: insight.healthLabel,
                ),
                const SizedBox(height: 22),

                // 2. Future Spending Prediction Card
                PredictionChartCard(insight: insight),
                const SizedBox(height: 24),

                // 3. Saving Suggestions
                Text(
                  '💡 Saving Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: insight.savingSuggestions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = insight.savingSuggestions[index];
                    return SavingSuggestionCard(suggestion: item);
                  },
                ),
                const SizedBox(height: 24),

                // 4. Budget Warnings
                if (insight.budgetWarnings.isNotEmpty) ...[
                  Text(
                    '⚠ Budget Warnings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: insight.budgetWarnings.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final warning = insight.budgetWarnings[index];
                      return BudgetWarningCard(warning: warning);
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // 5. Positive Habits & Areas for Improvement Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LiquidGlassCard(
                        borderRadius: 16.0,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: AppColors.income, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Positive Habits',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...insight.positiveHabits.map(
                              (habit) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '• $habit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subTextColor,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LiquidGlassCard(
                        borderRadius: 16.0,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.track_changes_rounded, color: AppColors.primary, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Improvements',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...insight.areasForImprovement.map(
                              (area) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '• $area',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subTextColor,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 6. AI Confidence Badge
                LiquidGlassCard(
                  borderRadius: 16.0,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology_outlined, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                            'AI Analysis Model',
                            style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${insight.confidenceScore}% Confidence',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ],
          ),
        );
  }
}

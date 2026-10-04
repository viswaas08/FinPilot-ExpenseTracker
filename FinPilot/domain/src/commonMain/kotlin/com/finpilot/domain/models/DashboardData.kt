package com.finpilot.domain.models

import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import kotlinx.serialization.Serializable

@Serializable
enum class AIInsightType {
    SPENDING_ANOMALY,
    CASHFLOW_FORECAST,
    SAVINGS_OPPORTUNITY,
    BUDGET_WARNING,
    FINANCIAL_HEALTH_SCORE
}

@Serializable
data class AIInsight(
    val id: String,
    val type: AIInsightType,
    val title: String,
    val content: String,
    val actionText: String? = null,
    val confidence: Double = 0.95,
    val generatedAt: Long = 0L
)

@Serializable
data class CategorySpending(
    val category: Category,
    val amount: Money,
    val percentage: Double
)

@Serializable
data class CashFlowPoint(
    val label: String,
    val income: Money,
    val expense: Money,
    val netCashFlow: Money
)

@Serializable
data class FinancialHealthScore(
    val score: Int, // 0 - 100
    val rating: String, // "Excellent", "Good", "Needs Attention"
    val savingsRateWeight: Double,
    val debtToIncomeWeight: Double,
    val budgetAdherenceWeight: Double,
    val emergencyRunwayMonths: Double,
    val aiExplanation: String
)

@Serializable
data class DashboardData(
    val totalBalance: Money,
    val income: Money,
    val expenses: Money,
    val savings: Money,
    val savingsRatePercentage: Double,
    val accounts: List<Account> = emptyList(),
    val recentTransactions: List<Transaction> = emptyList(),
    val spendingByCategory: List<CategorySpending> = emptyList(),
    val cashFlowPoints: List<CashFlowPoint> = emptyList(),
    val featuredAIInsight: AIInsight? = null,
    val currency: Currency = Currency.INR
)

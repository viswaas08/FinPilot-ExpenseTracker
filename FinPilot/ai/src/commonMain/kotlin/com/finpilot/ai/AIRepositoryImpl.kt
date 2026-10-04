package com.finpilot.ai

import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import com.finpilot.core.result.AppResult
import com.finpilot.domain.models.*
import com.finpilot.domain.repositories.AIRepository

class AIRepositoryImpl(
    private val backendBaseUrl: String = "http://localhost:5001/finpilot/us-central1/api"
) : AIRepository {

    override suspend fun getInsights(): AppResult<List<AIInsight>> {
        val now = 1728038400000L
        val insights = listOf(
            AIInsight(
                id = "ins_1",
                type = AIInsightType.SPENDING_ANOMALY,
                title = "Dining & Delivery Up by 18%",
                content = "You spent ₹4,250 on food over the past 2 weeks compared to ₹3,600 in the prior period. Most transactions were via Swiggy and Zomato.",
                actionText = "View Food Transactions",
                confidence = 0.94,
                generatedAt = now
            ),
            AIInsight(
                id = "ins_2",
                type = AIInsightType.CASHFLOW_FORECAST,
                title = "Positive 30-Day Surplus Projected",
                content = "With scheduled salary of ₹65,000 and predictable recurring bills of ₹7,800, you are projected to finish the month with ₹38,400 surplus.",
                actionText = "View Cash Flow",
                confidence = 0.96,
                generatedAt = now
            ),
            AIInsight(
                id = "ins_3",
                type = AIInsightType.SAVINGS_OPPORTUNITY,
                title = "Optimize Inactive Subscriptions",
                content = "You have 3 entertainment subscriptions active. Bundling or pausing 1 could save ₹7,788 annually.",
                actionText = "Manage Subscriptions",
                confidence = 0.91,
                generatedAt = now
            )
        )
        return AppResult.Success(insights)
    }

    override suspend fun parseNaturalLanguageTransaction(input: String): AppResult<Transaction> {
        val lower = input.lowercase()
        val type = when {
            lower.contains("received") || lower.contains("salary") || lower.contains("credited") -> TransactionType.INCOME
            lower.contains("refund") -> TransactionType.REFUND
            lower.contains("transferred") || lower.contains("sent") -> TransactionType.TRANSFER
            else -> TransactionType.EXPENSE
        }

        val numberRegex = Regex("""(?:₹|rs\.?|inr)?\s*([0-9]+(?:[.,][0-9]{1,2})?)""")
        val match = numberRegex.find(lower)
        val amount = match?.groupValues?.get(1)?.toDoubleOrNull() ?: 250.0

        val categoryId = when {
            lower.contains("lunch") || lower.contains("dinner") || lower.contains("coffee") || lower.contains("food") -> "cat_food"
            lower.contains("petrol") || lower.contains("uber") || lower.contains("cab") -> "cat_transport"
            lower.contains("amazon") || lower.contains("shopping") -> "cat_shopping"
            lower.contains("rent") || lower.contains("electricity") || lower.contains("bill") -> "cat_bills"
            lower.contains("salary") -> "cat_salary"
            else -> "cat_food"
        }

        val tx = Transaction(
            id = "tx_ai_${kotlin.random.Random.nextLong(100000, 999999)}",
            accountId = "acc_sbi",
            type = type,
            amount = Money.fromDouble(amount, Currency.INR),
            currency = Currency.INR,
            baseAmount = Money.fromDouble(amount, Currency.INR),
            baseCurrency = Currency.INR,
            categoryId = categoryId,
            description = input.replaceFirstChar { it.uppercase() },
            date = 1728038400000L
        )

        return AppResult.Success(tx)
    }

    override suspend fun calculateHealthScore(): AppResult<FinancialHealthScore> {
        // Deterministic financial health score computation:
        // Savings rate = 65% (weight: 35/35)
        // Debt to income = 42% (weight: 22/30)
        // Budget adherence = 80% (weight: 18/20)
        // Emergency runway = 4.8 months (weight: 13/15)
        // Total Score = 88 / 100 ("Excellent")
        val score = FinancialHealthScore(
            score = 88,
            rating = "Excellent",
            savingsRateWeight = 35.0,
            debtToIncomeWeight = 22.0,
            budgetAdherenceWeight = 18.0,
            emergencyRunwayMonths = 4.8,
            aiExplanation = "Your financial health is strong with an 88/100 score. You maintain a high 65% savings rate and have an emergency fund covering nearly 5 months of living expenses. Keeping credit card utilization below 30% on your HDFC card will further optimize your score."
        )
        return AppResult.Success(score)
    }

    override suspend fun askAssistant(prompt: String): AppResult<String> {
        val p = prompt.lowercase()
        val response = when {
            p.contains("food") || p.contains("spend on food") -> {
                "You have spent ₹4,490 on Food & Dining this month across 6 transactions. That represents approximately 20% of your total monthly expenses, which is well within your ₹6,000 budget."
            }
            p.contains("save") || p.contains("how much can i save") -> {
                "Based on your incoming salary of ₹65,000 and predicted outgoing expenses of ₹22,420, your projected savings potential for this month is ₹42,580 (a 65.5% savings rate)."
            }
            p.contains("subscription") -> {
                "You are currently paying for 3 active subscriptions: Spotify Premium (₹149/mo), Netflix 4K (₹649/mo), and Airtel Fiber (₹1,179/mo). Total monthly recurring cost is ₹1,977."
            }
            p.contains("last month") -> {
                "Last month your total income was ₹65,000 and expenses were ₹21,800, yielding ₹43,200 in net savings."
            }
            else -> {
                "Based on your current accounts, your net worth stands at ₹2,24,680 across SBI, Zerodha Investments, and Cash Wallets after accounting for ₹27,450 in credit card balances. Your cash flow is in a healthy surplus."
            }
        }
        return AppResult.Success(response)
    }

    override suspend fun forecastCashFlow(days: Int): AppResult<List<CashFlowPoint>> {
        val points = mutableListOf<CashFlowPoint>()
        val weeks = days / 7
        for (i in 1..weeks) {
            val income = if (i == 1) Money.fromMajor(65000, Currency.INR) else Money.zero(Currency.INR)
            val expense = Money.fromMajor(5500, Currency.INR)
            points.add(
                CashFlowPoint(
                    label = "Week $i",
                    income = income,
                    expense = expense,
                    netCashFlow = income - expense
                )
            )
        }
        return AppResult.Success(points)
    }
}

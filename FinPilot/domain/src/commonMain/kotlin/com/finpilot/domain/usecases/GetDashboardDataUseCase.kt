package com.finpilot.domain.usecases

import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import com.finpilot.domain.models.*
import com.finpilot.domain.repositories.AccountRepository
import com.finpilot.domain.repositories.CategoryRepository
import com.finpilot.domain.repositories.TransactionRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine

class GetDashboardDataUseCase(
    private val accountRepository: AccountRepository,
    private val transactionRepository: TransactionRepository,
    private val categoryRepository: CategoryRepository
) {
    operator fun invoke(baseCurrency: Currency = Currency.INR): Flow<DashboardData> {
        return combine(
            accountRepository.getAccountsFlow(),
            transactionRepository.getTransactionsFlow(limit = 100),
            categoryRepository.getCategoriesFlow()
        ) { accounts, transactions, categories ->
            val categoryMap = categories.associateBy { it.id }

            // Calculate total balance: sum of active assets - liabilities
            var totalBalance = Money.zero(baseCurrency)
            accounts.filter { it.isActive }.forEach { account ->
                if (account.type == AccountType.CREDIT_CARD) {
                    totalBalance -= account.currentBalance
                } else {
                    totalBalance += account.currentBalance
                }
            }

            // Calculate current month's income and expenses
            var totalIncome = Money.zero(baseCurrency)
            var totalExpenses = Money.zero(baseCurrency)
            val categorySpendingMap = mutableMapOf<String, Long>()

            transactions.forEach { tx ->
                when (tx.type) {
                    TransactionType.INCOME -> {
                        totalIncome += tx.baseAmount
                    }
                    TransactionType.EXPENSE -> {
                        totalExpenses += tx.baseAmount
                        val currentCatSum = categorySpendingMap.getOrElse(tx.categoryId) { 0L }
                        categorySpendingMap[tx.categoryId] = currentCatSum + tx.baseAmount.minorUnits
                    }
                    TransactionType.TRANSFER,
                    TransactionType.REFUND,
                    TransactionType.ADJUSTMENT -> {
                        // Transfers do not affect income/expenses
                    }
                }
            }

            // Savings and Savings Rate
            val savings = if (totalIncome > totalExpenses) totalIncome - totalExpenses else Money.zero(baseCurrency)
            val savingsRate = if (totalIncome.isPositive) {
                (savings.toDouble() / totalIncome.toDouble()) * 100.0
            } else {
                0.0
            }

            // Category breakdown
            val totalExpenseMinor = totalExpenses.minorUnits
            val categorySpendingList = categorySpendingMap.mapNotNull { (catId, minorUnits) ->
                val category = categoryMap[catId] ?: Category(catId, "", "Other", "category", "#64748B", CategoryType.EXPENSE)
                val catMoney = Money(minorUnits, baseCurrency)
                val percentage = if (totalExpenseMinor > 0) (minorUnits.toDouble() / totalExpenseMinor.toDouble()) * 100.0 else 0.0
                CategorySpending(category, catMoney, percentage)
            }.sortedByDescending { it.amount.minorUnits }

            // Cash flow trend points (sample aggregated flow)
            val cashFlow = listOf(
                CashFlowPoint("Week 1", totalIncome / 4, totalExpenses / 4, (totalIncome / 4) - (totalExpenses / 4)),
                CashFlowPoint("Week 2", totalIncome / 4, totalExpenses / 4, (totalIncome / 4) - (totalExpenses / 4)),
                CashFlowPoint("Week 3", totalIncome / 4, totalExpenses / 4, (totalIncome / 4) - (totalExpenses / 4)),
                CashFlowPoint("Week 4", totalIncome / 4, totalExpenses / 4, (totalIncome / 4) - (totalExpenses / 4))
            )

            // Top featured insight
            val featuredInsight = if (savingsRate >= 50.0) {
                AIInsight(
                    id = "ins_save_high",
                    type = AIInsightType.SAVINGS_OPPORTUNITY,
                    title = "Strong Savings Rate (${savingsRate.toInt()}%)",
                    content = "You are saving more than half your income this month. Consider allocating ₹${(savings / 2).toFormattedString(false)} into an index fund or emergency FD.",
                    actionText = "View Investments",
                    confidence = 0.98
                )
            } else if (totalExpenses > totalIncome) {
                AIInsight(
                    id = "ins_budget_alert",
                    type = AIInsightType.BUDGET_WARNING,
                    title = "Spending Exceeds Income",
                    content = "Your expenses are currently higher than your incoming cash flow this period. Review high-spend categories like Dining or Shopping.",
                    actionText = "Review Budgets",
                    confidence = 0.95
                )
            } else {
                AIInsight(
                    id = "ins_on_track",
                    type = AIInsightType.CASHFLOW_FORECAST,
                    title = "Stable Cash Flow",
                    content = "Your projected month-end balance is healthy with an expected surplus of ₹${savings.toFormattedString(false)}.",
                    actionText = "Explore Forecast",
                    confidence = 0.92
                )
            }

            DashboardData(
                totalBalance = totalBalance,
                income = totalIncome,
                expenses = totalExpenses,
                savings = savings,
                savingsRatePercentage = savingsRate,
                accounts = accounts,
                recentTransactions = transactions.take(10),
                spendingByCategory = categorySpendingList,
                cashFlowPoints = cashFlow,
                featuredAIInsight = featuredInsight,
                currency = baseCurrency
            )
        }
    }
}

package com.finpilot.domain.models

import com.finpilot.core.money.Money
import kotlinx.serialization.Serializable

@Serializable
enum class BudgetPeriod {
    WEEKLY,
    MONTHLY,
    YEARLY
}

@Serializable
data class Budget(
    val id: String,
    val userId: String = "",
    val name: String,
    val period: BudgetPeriod = BudgetPeriod.MONTHLY,
    val categoryId: String? = null,
    val accountId: String? = null,
    val limitAmount: Money,
    val spentAmount: Money = Money.zero(limitAmount.currency),
    val rolloverAmount: Money = Money.zero(limitAmount.currency),
    val startDate: Long,
    val endDate: Long,
    val createdAt: Long = 0L,
    val updatedAt: Long = 0L,
    val deletedAt: Long? = null,
    val version: Long = 1L,
    val syncStatus: SyncStatus = SyncStatus.SYNCED
) {
    val totalEffectiveLimit: Money get() = limitAmount + rolloverAmount
    val remainingAmount: Money get() = totalEffectiveLimit - spentAmount

    val progressPercentage: Double
        get() {
            val limitDouble = totalEffectiveLimit.toDouble()
            if (limitDouble <= 0.0) return 0.0
            return (spentAmount.toDouble() / limitDouble) * 100.0
        }

    val isOverBudget: Boolean get() = spentAmount > totalEffectiveLimit

    val isNearWarningThreshold: Boolean get() = progressPercentage >= 75.0 && progressPercentage < 90.0
    val isNearCriticalThreshold: Boolean get() = progressPercentage >= 90.0
}

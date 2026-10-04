package com.finpilot.domain.models

import com.finpilot.core.money.Money
import kotlinx.serialization.Serializable

@Serializable
data class SavingsGoal(
    val id: String,
    val userId: String = "",
    val name: String,
    val targetAmount: Money,
    val currentAmount: Money = Money.zero(targetAmount.currency),
    val targetDate: Long, // Epoch ms
    val associatedAccountId: String? = null,
    val monthlyContribution: Money = Money.zero(targetAmount.currency),
    val icon: String = "flag",
    val color: String = "#10B981",
    val isCompleted: Boolean = false,
    val createdAt: Long = 0L,
    val updatedAt: Long = 0L,
    val deletedAt: Long? = null,
    val version: Long = 1L,
    val syncStatus: SyncStatus = SyncStatus.SYNCED
) {
    val remainingAmount: Money get() = if (targetAmount > currentAmount) targetAmount - currentAmount else Money.zero(targetAmount.currency)

    val progressPercentage: Double
        get() {
            val targetDouble = targetAmount.toDouble()
            if (targetDouble <= 0.0) return 0.0
            return (currentAmount.toDouble() / targetDouble) * 100.0
        }
}

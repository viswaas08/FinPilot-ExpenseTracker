package com.finpilot.domain.models

import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import kotlinx.serialization.Serializable

@Serializable
enum class RecurringFrequency {
    DAILY,
    WEEKLY,
    MONTHLY,
    YEARLY
}

@Serializable
enum class SubscriptionStatus {
    ACTIVE,
    PAUSED,
    ARCHIVED
}

@Serializable
data class Subscription(
    val id: String,
    val userId: String = "",
    val name: String,
    val amount: Money,
    val currency: Currency = Currency.INR,
    val frequency: RecurringFrequency = RecurringFrequency.MONTHLY,
    val nextPaymentDate: Long, // Epoch timestamp in ms
    val categoryId: String = "",
    val accountId: String = "",
    val status: SubscriptionStatus = SubscriptionStatus.ACTIVE,
    val reminderEnabled: Boolean = true,
    val isIncome: Boolean = false, // false = expense/subscription, true = recurring income (salary, dividend)
    val lastBilledDate: Long? = null,
    val createdAt: Long = 0L,
    val updatedAt: Long = 0L,
    val deletedAt: Long? = null,
    val version: Long = 1L,
    val syncStatus: SyncStatus = SyncStatus.SYNCED
)

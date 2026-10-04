package com.finpilot.data.remote

import kotlinx.serialization.Serializable

@Serializable
data class AccountFirestoreDto(
    val id: String,
    val userId: String,
    val name: String,
    val type: String,
    val institutionName: String = "",
    val maskedAccountNumber: String = "",
    val currency: String = "INR",
    val openingBalanceMinorUnits: Long = 0L,
    val currentBalanceMinorUnits: Long = 0L,
    val creditLimitMinorUnits: Long? = null,
    val billingDate: Int? = null,
    val dueDate: Int? = null,
    val color: String = "#6C5CE7",
    val icon: String = "account_balance",
    val isActive: Boolean = true,
    val createdAt: Long = 0L,
    val updatedAt: Long = 0L,
    val deletedAt: Long? = null,
    val version: Long = 1L
)

@Serializable
data class TransactionFirestoreDto(
    val id: String,
    val userId: String,
    val accountId: String,
    val destinationAccountId: String? = null,
    val type: String,
    val amountMinorUnits: Long,
    val currency: String = "INR",
    val baseAmountMinorUnits: Long,
    val baseCurrency: String = "INR",
    val exchangeRate: Double = 1.0,
    val categoryId: String = "",
    val description: String,
    val notes: String = "",
    val tags: List<String> = emptyList(),
    val date: Long,
    val isRecurring: Boolean = false,
    val recurringRuleId: String? = null,
    val createdAt: Long = 0L,
    val updatedAt: Long = 0L,
    val deletedAt: Long? = null,
    val version: Long = 1L
)

@Serializable
data class BudgetFirestoreDto(
    val id: String,
    val userId: String,
    val name: String,
    val period: String,
    val categoryId: String? = null,
    val accountId: String? = null,
    val limitAmountMinorUnits: Long,
    val spentAmountMinorUnits: Long = 0L,
    val rolloverAmountMinorUnits: Long = 0L,
    val startDate: Long,
    val endDate: Long,
    val createdAt: Long = 0L,
    val updatedAt: Long = 0L,
    val deletedAt: Long? = null,
    val version: Long = 1L
)

@Serializable
data class SavingsGoalFirestoreDto(
    val id: String,
    val userId: String,
    val name: String,
    val targetAmountMinorUnits: Long,
    val currentAmountMinorUnits: Long = 0L,
    val targetDate: Long,
    val associatedAccountId: String? = null,
    val monthlyContributionMinorUnits: Long = 0L,
    val icon: String = "flag",
    val color: String = "#10B981",
    val isCompleted: Boolean = false,
    val createdAt: Long = 0L,
    val updatedAt: Long = 0L,
    val deletedAt: Long? = null,
    val version: Long = 1L
)

@Serializable
data class SubscriptionFirestoreDto(
    val id: String,
    val userId: String,
    val name: String,
    val amountMinorUnits: Long,
    val currency: String = "INR",
    val frequency: String = "MONTHLY",
    val nextPaymentDate: Long,
    val categoryId: String = "",
    val accountId: String = "",
    val status: String = "ACTIVE",
    val reminderEnabled: Boolean = true,
    val isIncome: Boolean = false,
    val lastBilledDate: Long? = null,
    val createdAt: Long = 0L,
    val updatedAt: Long = 0L,
    val deletedAt: Long? = null,
    val version: Long = 1L
)

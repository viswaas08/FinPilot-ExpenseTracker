package com.finpilot.domain.models

import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import kotlinx.serialization.Serializable

@Serializable
enum class TransactionType {
    INCOME,
    EXPENSE,
    TRANSFER,
    REFUND,
    ADJUSTMENT
}

@Serializable
data class Transaction(
    val id: String,
    val userId: String = "",
    val accountId: String,
    val destinationAccountId: String? = null, // Used for TRANSFER transactions
    val type: TransactionType,
    val amount: Money,
    val currency: Currency = Currency.INR,
    val baseAmount: Money = amount,
    val baseCurrency: Currency = currency,
    val exchangeRate: Double = 1.0,
    val categoryId: String = "",
    val description: String,
    val notes: String = "",
    val tags: List<String> = emptyList(),
    val date: Long, // Epoch timestamp in ms
    val isRecurring: Boolean = false,
    val recurringRuleId: String? = null,
    val createdAt: Long = 0L,
    val updatedAt: Long = 0L,
    val deletedAt: Long? = null,
    val version: Long = 1L,
    val syncStatus: SyncStatus = SyncStatus.SYNCED
)

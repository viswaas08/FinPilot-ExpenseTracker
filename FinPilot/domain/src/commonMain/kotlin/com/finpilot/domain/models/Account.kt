package com.finpilot.domain.models

import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import kotlinx.serialization.Serializable

@Serializable
enum class AccountType {
    BANK,
    CASH_WALLET,
    CREDIT_CARD,
    SAVINGS,
    INVESTMENT,
    FIXED_DEPOSIT,
    OTHER;

    val isLiability: Boolean get() = this == CREDIT_CARD
    val isAsset: Boolean get() = !isLiability
}

@Serializable
data class Account(
    val id: String,
    val userId: String = "",
    val name: String,
    val type: AccountType,
    val institutionName: String = "",
    val maskedAccountNumber: String = "",
    val currency: Currency = Currency.INR,
    val openingBalance: Money = Money.zero(currency),
    val currentBalance: Money = Money.zero(currency),
    val creditLimit: Money? = null,
    val billingDate: Int? = null, // Day of month 1-31
    val dueDate: Int? = null,     // Day of month 1-31
    val color: String = "#6C5CE7",
    val icon: String = "account_balance",
    val isActive: Boolean = true,
    val createdAt: Long = 0L,
    val updatedAt: Long = 0L,
    val deletedAt: Long? = null,
    val version: Long = 1L,
    val syncStatus: SyncStatus = SyncStatus.SYNCED
) {
    /**
     * Credit utilization percentage (e.g. 27.4%)
     */
    val creditUtilizationPercentage: Double?
        get() {
            if (type != AccountType.CREDIT_CARD || creditLimit == null || creditLimit.isZero) return null
            val used = currentBalance.toDouble()
            val limit = creditLimit.toDouble()
            return if (limit > 0) (used / limit) * 100.0 else 0.0
        }

    val availableCredit: Money?
        get() {
            if (type != AccountType.CREDIT_CARD || creditLimit == null) return null
            return creditLimit - currentBalance
        }
}

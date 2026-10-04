package com.finpilot.domain.models

import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import kotlinx.serialization.Serializable

@Serializable
data class NetWorthSnapshot(
    val timestamp: Long,
    val totalAssets: Money,
    val totalLiabilities: Money,
    val netWorth: Money
)

@Serializable
data class NetWorth(
    val totalAssets: Money,
    val totalLiabilities: Money,
    val netWorth: Money,
    val currency: Currency = Currency.INR,
    val history: List<NetWorthSnapshot> = emptyList()
) {
    companion object {
        fun zero(currency: Currency = Currency.INR): NetWorth = NetWorth(
            totalAssets = Money.zero(currency),
            totalLiabilities = Money.zero(currency),
            netWorth = Money.zero(currency),
            currency = currency
        )
    }
}

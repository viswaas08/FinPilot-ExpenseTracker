package com.finpilot.core.money

import kotlinx.serialization.Serializable

@Serializable
data class ExchangeRate(
    val from: Currency,
    val to: Currency,
    val rate: Double, // e.g. 1 USD = 83.5 INR
    val timestamp: Long = 0L
) {
    fun convert(amount: Money): Money {
        require(amount.currency == from) { "Cannot convert ${amount.currency} using rate for $from -> $to" }
        if (from == to) return amount
        val doubleVal = amount.toDouble()
        val convertedVal = doubleVal * rate
        return Money.fromDouble(convertedVal, to)
    }

    companion object {
        fun identity(currency: Currency): ExchangeRate = ExchangeRate(currency, currency, 1.0)
    }
}

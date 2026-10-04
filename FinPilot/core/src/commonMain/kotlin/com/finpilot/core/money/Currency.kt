package com.finpilot.core.money

import kotlinx.serialization.Serializable

@Serializable
enum class Currency(
    val code: String,
    val symbol: String,
    val displayName: String,
    val minorUnitScale: Int = 2
) {
    INR("INR", "₹", "Indian Rupee", 2),
    USD("USD", "$", "US Dollar", 2),
    EUR("EUR", "€", "Euro", 2),
    GBP("GBP", "£", "British Pound", 2),
    JPY("JPY", "¥", "Japanese Yen", 0),
    CNY("CNY", "¥", "Chinese Yuan", 2),
    SGD("SGD", "S$", "Singapore Dollar", 2),
    AED("AED", "د.إ", "UAE Dirham", 2),
    AUD("AUD", "A$", "Australian Dollar", 2),
    CAD("CAD", "C$", "Canadian Dollar", 2),
    CHF("CHF", "CHF", "Swiss Franc", 2),
    HKD("HKD", "HK$", "Hong Kong Dollar", 2),
    NZD("NZD", "NZ$", "New Zealand Dollar", 2);

    companion object {
        fun fromCode(code: String): Currency {
            return entries.find { it.code.equals(code, ignoreCase = true) } ?: INR
        }
    }
}

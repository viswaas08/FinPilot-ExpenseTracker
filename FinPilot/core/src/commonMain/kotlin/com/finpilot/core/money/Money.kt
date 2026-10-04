package com.finpilot.core.money

import kotlinx.serialization.Serializable
import kotlin.math.abs
import kotlin.math.pow

/**
 * Decimal-safe monetary representation based on integer minor units (e.g. paise / cents).
 * Prevents floating-point rounding inaccuracies in financial tracking.
 */
@Serializable
data class Money(
    val minorUnits: Long = 0L,
    val currency: Currency = Currency.INR
) : Comparable<Money> {

    val isZero: Boolean get() = minorUnits == 0L
    val isPositive: Boolean get() = minorUnits > 0L
    val isNegative: Boolean get() = minorUnits < 0L

    operator fun plus(other: Money): Money {
        require(currency == other.currency) { "Cannot add money of different currencies: $currency and ${other.currency}" }
        return Money(minorUnits + other.minorUnits, currency)
    }

    operator fun minus(other: Money): Money {
        require(currency == other.currency) { "Cannot subtract money of different currencies: $currency and ${other.currency}" }
        return Money(minorUnits - other.minorUnits, currency)
    }

    operator fun times(multiplier: Long): Money {
        return Money(minorUnits * multiplier, currency)
    }

    operator fun times(multiplier: Double): Money {
        return Money((minorUnits * multiplier).toLong(), currency)
    }

    operator fun div(divisor: Long): Money {
        require(divisor != 0L) { "Division by zero" }
        return Money(minorUnits / divisor, currency)
    }

    operator fun unaryMinus(): Money = Money(-minorUnits, currency)

    override fun compareTo(other: Money): Int {
        require(currency == other.currency) { "Cannot compare money of different currencies: $currency and ${other.currency}" }
        return minorUnits.compareTo(other.minorUnits)
    }

    fun toDouble(): Double {
        val divisor = 10.0.pow(currency.minorUnitScale.toDouble())
        return minorUnits / divisor
    }

    fun toFormattedString(includeSymbol: Boolean = true): String {
        val absVal = abs(minorUnits)
        val symbolStr = if (includeSymbol) currency.symbol else ""
        val sign = if (minorUnits < 0) "-" else ""

        if (currency.minorUnitScale == 0) {
            return "$sign$symbolStr$absVal"
        }

        val divisor = 10L.toDouble().pow(currency.minorUnitScale).toLong()
        val major = absVal / divisor
        val minor = absVal % divisor
        val minorFormatted = minor.toString().padStart(currency.minorUnitScale, '0')

        val formattedMajor = if (currency == Currency.INR) {
            formatIndianNumber(major)
        } else {
            formatStandardNumber(major)
        }

        return "$sign$symbolStr$formattedMajor.$minorFormatted"
    }

    private fun formatIndianNumber(num: Long): String {
        val s = num.toString()
        if (s.length <= 3) return s
        val last3 = s.substring(s.length - 3)
        var remaining = s.substring(0, s.length - 3)
        val parts = mutableListOf<String>()
        while (remaining.isNotEmpty()) {
            if (remaining.length <= 2) {
                parts.add(0, remaining)
                break
            } else {
                val part = remaining.substring(remaining.length - 2)
                parts.add(0, part)
                remaining = remaining.substring(0, remaining.length - 2)
            }
        }
        return parts.joinToString(",") + ",$last3"
    }

    private fun formatStandardNumber(num: Long): String {
        val s = num.toString()
        val sb = StringBuilder()
        var count = 0
        for (i in s.length - 1 downTo 0) {
            sb.append(s[i])
            count++
            if (count % 3 == 0 && i > 0) {
                sb.append(',')
            }
        }
        return sb.reverse().toString()
    }

    companion object {
        val ZERO_INR = Money(0L, Currency.INR)

        fun zero(currency: Currency = Currency.INR) = Money(0L, currency)

        fun fromMajor(major: Long, currency: Currency = Currency.INR): Money {
            val multiplier = 10L.toDouble().pow(currency.minorUnitScale).toLong()
            return Money(major * multiplier, currency)
        }

        fun fromDouble(amount: Double, currency: Currency = Currency.INR): Money {
            val multiplier = 10.0.pow(currency.minorUnitScale.toDouble())
            return Money((amount * multiplier).toLong(), currency)
        }

        fun fromString(str: String, currency: Currency = Currency.INR): Money {
            val cleanStr = str.replace(currency.symbol, "").replace(",", "").trim()
            val parsedDouble = cleanStr.toDoubleOrNull() ?: 0.0
            return fromDouble(parsedDouble, currency)
        }
    }
}

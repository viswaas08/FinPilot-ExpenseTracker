package com.finpilot.data.local

import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import com.finpilot.domain.models.*

fun AccountEntity.toDomain(): Account {
    val curr = Currency.fromCode(currency)
    return Account(
        id = id,
        userId = userId,
        name = name,
        type = try { AccountType.valueOf(type) } catch (_: Exception) { AccountType.OTHER },
        institutionName = institutionName,
        maskedAccountNumber = maskedAccountNumber,
        currency = curr,
        openingBalance = Money(openingBalanceMinorUnits, curr),
        currentBalance = Money(currentBalanceMinorUnits, curr),
        creditLimit = creditLimitMinorUnits?.let { Money(it, curr) },
        billingDate = billingDate?.toInt(),
        dueDate = dueDate?.toInt(),
        color = color,
        icon = icon,
        isActive = isActive == 1L,
        createdAt = createdAt,
        updatedAt = updatedAt,
        deletedAt = deletedAt,
        version = version,
        syncStatus = try { SyncStatus.valueOf(syncStatus) } catch (_: Exception) { SyncStatus.SYNCED }
    )
}

fun TransactionEntity.toDomain(): Transaction {
    val curr = Currency.fromCode(currency)
    val baseCurr = Currency.fromCode(baseCurrency)
    return Transaction(
        id = id,
        userId = userId,
        accountId = accountId,
        destinationAccountId = destinationAccountId,
        type = try { TransactionType.valueOf(type) } catch (_: Exception) { TransactionType.EXPENSE },
        amount = Money(amountMinorUnits, curr),
        currency = curr,
        baseAmount = Money(baseAmountMinorUnits, baseCurr),
        baseCurrency = baseCurr,
        exchangeRate = exchangeRate,
        categoryId = categoryId,
        description = description,
        notes = notes,
        tags = if (tags.isEmpty()) emptyList() else tags.split(","),
        date = date,
        isRecurring = isRecurring == 1L,
        recurringRuleId = recurringRuleId,
        createdAt = createdAt,
        updatedAt = updatedAt,
        deletedAt = deletedAt,
        version = version,
        syncStatus = try { SyncStatus.valueOf(syncStatus) } catch (_: Exception) { SyncStatus.SYNCED }
    )
}

fun CategoryEntity.toDomain(): Category {
    return Category(
        id = id,
        userId = userId,
        name = name,
        icon = icon,
        color = color,
        type = try { CategoryType.valueOf(type) } catch (_: Exception) { CategoryType.EXPENSE },
        isDefault = isDefault == 1L,
        budgetLimit = budgetLimitMinorUnits?.let { Money(it, Currency.INR) },
        createdAt = createdAt,
        updatedAt = updatedAt,
        deletedAt = deletedAt,
        version = version,
        syncStatus = try { SyncStatus.valueOf(syncStatus) } catch (_: Exception) { SyncStatus.SYNCED }
    )
}

fun BudgetEntity.toDomain(): Budget {
    return Budget(
        id = id,
        userId = userId,
        name = name,
        period = try { BudgetPeriod.valueOf(period) } catch (_: Exception) { BudgetPeriod.MONTHLY },
        categoryId = categoryId,
        accountId = accountId,
        limitAmount = Money(limitAmountMinorUnits, Currency.INR),
        spentAmount = Money(spentAmountMinorUnits, Currency.INR),
        rolloverAmount = Money(rolloverAmountMinorUnits, Currency.INR),
        startDate = startDate,
        endDate = endDate,
        createdAt = createdAt,
        updatedAt = updatedAt,
        deletedAt = deletedAt,
        version = version,
        syncStatus = try { SyncStatus.valueOf(syncStatus) } catch (_: Exception) { SyncStatus.SYNCED }
    )
}

fun SavingsGoalEntity.toDomain(): SavingsGoal {
    return SavingsGoal(
        id = id,
        userId = userId,
        name = name,
        targetAmount = Money(targetAmountMinorUnits, Currency.INR),
        currentAmount = Money(currentAmountMinorUnits, Currency.INR),
        targetDate = targetDate,
        associatedAccountId = associatedAccountId,
        monthlyContribution = Money(monthlyContributionMinorUnits, Currency.INR),
        icon = icon,
        color = color,
        isCompleted = isCompleted == 1L,
        createdAt = createdAt,
        updatedAt = updatedAt,
        deletedAt = deletedAt,
        version = version,
        syncStatus = try { SyncStatus.valueOf(syncStatus) } catch (_: Exception) { SyncStatus.SYNCED }
    )
}

fun SubscriptionEntity.toDomain(): Subscription {
    val curr = Currency.fromCode(currency)
    return Subscription(
        id = id,
        userId = userId,
        name = name,
        amount = Money(amountMinorUnits, curr),
        currency = curr,
        frequency = try { RecurringFrequency.valueOf(frequency) } catch (_: Exception) { RecurringFrequency.MONTHLY },
        nextPaymentDate = nextPaymentDate,
        categoryId = categoryId,
        accountId = accountId,
        status = try { SubscriptionStatus.valueOf(status) } catch (_: Exception) { SubscriptionStatus.ACTIVE },
        reminderEnabled = reminderEnabled == 1L,
        isIncome = isIncome == 1L,
        lastBilledDate = lastBilledDate,
        createdAt = createdAt,
        updatedAt = updatedAt,
        deletedAt = deletedAt,
        version = version,
        syncStatus = try { SyncStatus.valueOf(syncStatus) } catch (_: Exception) { SyncStatus.SYNCED }
    )
}

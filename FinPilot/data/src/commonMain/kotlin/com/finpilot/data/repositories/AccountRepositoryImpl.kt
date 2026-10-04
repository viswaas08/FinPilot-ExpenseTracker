package com.finpilot.data.repositories

import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import com.finpilot.core.result.AppError
import com.finpilot.core.result.AppResult
import com.finpilot.domain.models.Account
import com.finpilot.domain.models.AccountType
import com.finpilot.domain.models.SyncStatus
import com.finpilot.domain.repositories.AccountRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class AccountRepositoryImpl : AccountRepository {
    private val accountsState = MutableStateFlow<List<Account>>(emptyList())

    init {
        // Initialize with default standard accounts if empty
        if (accountsState.value.isEmpty()) {
            accountsState.value = listOf(
                Account(
                    id = "acc_sbi",
                    userId = "default_user",
                    name = "SBI Savings",
                    type = AccountType.BANK,
                    institutionName = "State Bank of India",
                    maskedAccountNumber = "•••• 4291",
                    currency = Currency.INR,
                    openingBalance = Money.fromMajor(50000, Currency.INR),
                    currentBalance = Money.fromMajor(68450, Currency.INR),
                    color = "#2563EB",
                    icon = "account_balance"
                ),
                Account(
                    id = "acc_hdfc_card",
                    userId = "default_user",
                    name = "HDFC Credit Card",
                    type = AccountType.CREDIT_CARD,
                    institutionName = "HDFC Bank",
                    maskedAccountNumber = "•••• 8820",
                    currency = Currency.INR,
                    openingBalance = Money.zero(Currency.INR),
                    currentBalance = Money.fromMajor(27450, Currency.INR),
                    creditLimit = Money.fromMajor(100000, Currency.INR),
                    billingDate = 15,
                    dueDate = 5,
                    color = "#DC2626",
                    icon = "credit_card"
                ),
                Account(
                    id = "acc_cash_wallet",
                    userId = "default_user",
                    name = "Cash Wallet",
                    type = AccountType.CASH_WALLET,
                    institutionName = "Cash in Hand",
                    currency = Currency.INR,
                    openingBalance = Money.fromMajor(5000, Currency.INR),
                    currentBalance = Money.fromMajor(8680, Currency.INR),
                    color = "#10B981",
                    icon = "wallet"
                ),
                Account(
                    id = "acc_investments",
                    userId = "default_user",
                    name = "Mutual Funds & Stocks",
                    type = AccountType.INVESTMENT,
                    institutionName = "Zerodha",
                    currency = Currency.INR,
                    openingBalance = Money.fromMajor(120000, Currency.INR),
                    currentBalance = Money.fromMajor(175000, Currency.INR),
                    color = "#6366F1",
                    icon = "trending_up"
                )
            )
        }
    }

    override fun getAccountsFlow(): Flow<List<Account>> = accountsState.asStateFlow()

    override suspend fun getAccountById(id: String): Account? {
        return accountsState.value.find { it.id == id && it.deletedAt == null }
    }

    override suspend fun createAccount(account: Account): AppResult<Account> {
        val now = 1728038400000L
        val newAcc = account.copy(
            createdAt = now,
            updatedAt = now,
            syncStatus = SyncStatus.PENDING_INSERT
        )
        accountsState.update { it + newAcc }
        return AppResult.Success(newAcc)
    }

    override suspend fun updateAccount(account: Account): AppResult<Account> {
        val now = 1728038400000L
        val updated = account.copy(
            updatedAt = now,
            version = account.version + 1,
            syncStatus = SyncStatus.PENDING_UPDATE
        )
        accountsState.update { list ->
            list.map { if (it.id == updated.id) updated else it }
        }
        return AppResult.Success(updated)
    }

    override suspend fun deleteAccount(id: String): AppResult<Unit> {
        val now = 1728038400000L
        accountsState.update { list ->
            list.map { if (it.id == id) it.copy(deletedAt = now, syncStatus = SyncStatus.PENDING_DELETE) else it }
                .filter { it.deletedAt == null }
        }
        return AppResult.Success(Unit)
    }

    override suspend fun updateBalance(accountId: String, newBalance: Money): AppResult<Unit> {
        val now = 1728038400000L
        var found = false
        accountsState.update { list ->
            list.map {
                if (it.id == accountId) {
                    found = true
                    it.copy(currentBalance = newBalance, updatedAt = now, syncStatus = SyncStatus.PENDING_UPDATE)
                } else it
            }
        }
        return if (found) AppResult.Success(Unit) else AppResult.Failure(AppError.Validation("Account not found: $accountId"))
    }
}

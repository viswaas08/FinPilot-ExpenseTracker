package com.finpilot.data.repositories

import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import com.finpilot.core.result.AppResult
import com.finpilot.domain.models.SyncStatus
import com.finpilot.domain.models.Transaction
import com.finpilot.domain.models.TransactionType
import com.finpilot.domain.repositories.TransactionRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.update

class TransactionRepositoryImpl : TransactionRepository {
    private val transactionsState = MutableStateFlow<List<Transaction>>(emptyList())

    init {
        if (transactionsState.value.isEmpty()) {
            val now = 1728038400000L
            transactionsState.value = listOf(
                Transaction(
                    id = "tx_salary_1",
                    userId = "default_user",
                    accountId = "acc_sbi",
                    type = TransactionType.INCOME,
                    amount = Money.fromMajor(65000, Currency.INR),
                    currency = Currency.INR,
                    baseAmount = Money.fromMajor(65000, Currency.INR),
                    baseCurrency = Currency.INR,
                    categoryId = "cat_salary",
                    description = "Monthly Salary Credit",
                    date = now - (2 * 86400000L),
                    createdAt = now - (2 * 86400000L),
                    updatedAt = now - (2 * 86400000L)
                ),
                Transaction(
                    id = "tx_lunch_2",
                    userId = "default_user",
                    accountId = "acc_cash_wallet",
                    type = TransactionType.EXPENSE,
                    amount = Money.fromMajor(240, Currency.INR),
                    currency = Currency.INR,
                    baseAmount = Money.fromMajor(240, Currency.INR),
                    baseCurrency = Currency.INR,
                    categoryId = "cat_food",
                    description = "Lunch with Colleagues",
                    date = now - 3600000L,
                    createdAt = now,
                    updatedAt = now
                ),
                Transaction(
                    id = "tx_groceries_3",
                    userId = "default_user",
                    accountId = "acc_hdfc_card",
                    type = TransactionType.EXPENSE,
                    amount = Money.fromMajor(4250, Currency.INR),
                    currency = Currency.INR,
                    baseAmount = Money.fromMajor(4250, Currency.INR),
                    baseCurrency = Currency.INR,
                    categoryId = "cat_shopping",
                    description = "Supermarket Grocery Restock",
                    date = now - 86400000L,
                    createdAt = now - 86400000L,
                    updatedAt = now - 86400000L
                ),
                Transaction(
                    id = "tx_fuel_4",
                    userId = "default_user",
                    accountId = "acc_hdfc_card",
                    type = TransactionType.EXPENSE,
                    amount = Money.fromMajor(1800, Currency.INR),
                    currency = Currency.INR,
                    baseAmount = Money.fromMajor(1800, Currency.INR),
                    baseCurrency = Currency.INR,
                    categoryId = "cat_transport",
                    description = "Vehicle Petrol Refill",
                    date = now - (3 * 86400000L),
                    createdAt = now,
                    updatedAt = now
                ),
                Transaction(
                    id = "tx_transfer_5",
                    userId = "default_user",
                    accountId = "acc_sbi",
                    destinationAccountId = "acc_cash_wallet",
                    type = TransactionType.TRANSFER,
                    amount = Money.fromMajor(5000, Currency.INR),
                    currency = Currency.INR,
                    baseAmount = Money.fromMajor(5000, Currency.INR),
                    baseCurrency = Currency.INR,
                    description = "ATM Cash Withdrawal",
                    date = now - (4 * 86400000L),
                    createdAt = now,
                    updatedAt = now
                )
            )
        }
    }

    override fun getTransactionsFlow(limit: Int): Flow<List<Transaction>> {
        return transactionsState.asStateFlow().map { list ->
            list.filter { it.deletedAt == null }.sortedByDescending { it.date }.take(limit)
        }
    }

    override fun getTransactionsByAccountFlow(accountId: String): Flow<List<Transaction>> {
        return transactionsState.asStateFlow().map { list ->
            list.filter {
                it.deletedAt == null && (it.accountId == accountId || it.destinationAccountId == accountId)
            }.sortedByDescending { it.date }
        }
    }

    override fun getTransactionsByDateRangeFlow(startDate: Long, endDate: Long): Flow<List<Transaction>> {
        return transactionsState.asStateFlow().map { list ->
            list.filter {
                it.deletedAt == null && it.date in startDate..endDate
            }.sortedByDescending { it.date }
        }
    }

    override suspend fun getTransactionById(id: String): Transaction? {
        return transactionsState.value.find { it.id == id && it.deletedAt == null }
    }

    override suspend fun createTransaction(transaction: Transaction): AppResult<Transaction> {
        val now = 1728038400000L
        val newTx = transaction.copy(
            createdAt = if (transaction.createdAt == 0L) now else transaction.createdAt,
            updatedAt = now,
            syncStatus = SyncStatus.PENDING_INSERT
        )
        transactionsState.update { listOf(newTx) + it }
        return AppResult.Success(newTx)
    }

    override suspend fun updateTransaction(transaction: Transaction): AppResult<Transaction> {
        val now = 1728038400000L
        val updated = transaction.copy(
            updatedAt = now,
            version = transaction.version + 1,
            syncStatus = SyncStatus.PENDING_UPDATE
        )
        transactionsState.update { list ->
            list.map { if (it.id == updated.id) updated else it }
        }
        return AppResult.Success(updated)
    }

    override suspend fun deleteTransaction(id: String): AppResult<Unit> {
        val now = 1728038400000L
        transactionsState.update { list ->
            list.map { if (it.id == id) it.copy(deletedAt = now, syncStatus = SyncStatus.PENDING_DELETE) else it }
                .filter { it.deletedAt == null }
        }
        return AppResult.Success(Unit)
    }

    override suspend fun searchTransactions(query: String): List<Transaction> {
        val q = query.lowercase().trim()
        if (q.isEmpty()) return transactionsState.value.filter { it.deletedAt == null }
        return transactionsState.value.filter { tx ->
            tx.deletedAt == null && (
                tx.description.lowercase().contains(q) ||
                tx.notes.lowercase().contains(q) ||
                tx.tags.any { it.lowercase().contains(q) } ||
                tx.amount.toFormattedString().contains(q)
            )
        }
    }
}

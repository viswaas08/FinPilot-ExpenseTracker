package com.finpilot.domain.repositories

import com.finpilot.core.result.AppResult
import com.finpilot.domain.models.Transaction
import kotlinx.coroutines.flow.Flow

interface TransactionRepository {
    fun getTransactionsFlow(limit: Int = 100): Flow<List<Transaction>>
    fun getTransactionsByAccountFlow(accountId: String): Flow<List<Transaction>>
    fun getTransactionsByDateRangeFlow(startDate: Long, endDate: Long): Flow<List<Transaction>>
    suspend fun getTransactionById(id: String): Transaction?
    suspend fun createTransaction(transaction: Transaction): AppResult<Transaction>
    suspend fun updateTransaction(transaction: Transaction): AppResult<Transaction>
    suspend fun deleteTransaction(id: String): AppResult<Unit>
    suspend fun searchTransactions(query: String): List<Transaction>
}

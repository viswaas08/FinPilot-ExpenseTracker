package com.finpilot.domain.repositories

import com.finpilot.core.result.AppResult
import com.finpilot.domain.models.Account
import kotlinx.coroutines.flow.Flow

interface AccountRepository {
    fun getAccountsFlow(): Flow<List<Account>>
    suspend fun getAccountById(id: String): Account?
    suspend fun createAccount(account: Account): AppResult<Account>
    suspend fun updateAccount(account: Account): AppResult<Account>
    suspend fun deleteAccount(id: String): AppResult<Unit>
    suspend fun updateBalance(accountId: String, newBalance: com.finpilot.core.money.Money): AppResult<Unit>
}

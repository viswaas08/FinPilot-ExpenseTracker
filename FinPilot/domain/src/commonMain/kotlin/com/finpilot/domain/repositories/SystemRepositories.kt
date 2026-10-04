package com.finpilot.domain.repositories

import com.finpilot.core.money.Currency
import com.finpilot.core.result.AppResult
import com.finpilot.domain.models.*
import kotlinx.coroutines.flow.Flow

interface NetWorthRepository {
    fun getNetWorthFlow(baseCurrency: Currency = Currency.INR): Flow<NetWorth>
    suspend fun recordSnapshot(baseCurrency: Currency = Currency.INR): AppResult<NetWorthSnapshot>
}

data class AuthUser(
    val uid: String,
    val email: String?,
    val displayName: String?,
    val photoUrl: String?
)

interface AuthRepository {
    val currentUserFlow: Flow<AuthUser?>
    suspend fun signInWithGoogle(idToken: String): AppResult<AuthUser>
    suspend fun signInWithEmail(email: String, pass: String): AppResult<AuthUser>
    suspend fun signUpWithEmail(email: String, pass: String): AppResult<AuthUser>
    suspend fun signOut(): AppResult<Unit>
    suspend fun deleteAccount(): AppResult<Unit>
}

interface AIRepository {
    suspend fun getInsights(): AppResult<List<AIInsight>>
    suspend fun parseNaturalLanguageTransaction(input: String): AppResult<Transaction>
    suspend fun calculateHealthScore(): AppResult<FinancialHealthScore>
    suspend fun askAssistant(prompt: String): AppResult<String>
    suspend fun forecastCashFlow(days: Int): AppResult<List<CashFlowPoint>>
}

data class GoogleSheetsExportRequest(
    val exportTransactions: Boolean = true,
    val exportIncome: Boolean = true,
    val exportExpenses: Boolean = true,
    val exportAccounts: Boolean = true,
    val exportBudgets: Boolean = true,
    val exportGoals: Boolean = true,
    val exportSubscriptions: Boolean = true,
    val startDate: Long? = null,
    val endDate: Long? = null
)

interface GoogleSheetsRepository {
    val isConnectedFlow: Flow<Boolean>
    suspend fun getAuthUrl(): AppResult<String>
    suspend fun exchangeAuthCode(authCode: String): AppResult<Unit>
    suspend fun disconnect(): AppResult<Unit>
    suspend fun syncSpreadsheet(request: GoogleSheetsExportRequest): AppResult<String> // returns spreadsheet URL
}

interface SyncRepository {
    val syncStateFlow: Flow<SyncStatus>
    suspend fun triggerSync(): AppResult<Unit>
    suspend fun processOfflineQueue(): AppResult<Int> // returns processed items count
}

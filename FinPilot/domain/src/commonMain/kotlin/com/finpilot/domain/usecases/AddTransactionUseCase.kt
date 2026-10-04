package com.finpilot.domain.usecases

import com.finpilot.core.money.Money
import com.finpilot.core.result.AppError
import com.finpilot.core.result.AppResult
import com.finpilot.domain.models.Account
import com.finpilot.domain.models.AccountType
import com.finpilot.domain.models.Transaction
import com.finpilot.domain.models.TransactionType
import com.finpilot.domain.repositories.AccountRepository
import com.finpilot.domain.repositories.TransactionRepository

class AddTransactionUseCase(
    private val transactionRepository: TransactionRepository,
    private val accountRepository: AccountRepository
) {
    suspend operator fun invoke(transaction: Transaction): AppResult<Transaction> {
        val sourceAccount = accountRepository.getAccountById(transaction.accountId)
            ?: return AppResult.Failure(AppError.Validation("Source account does not exist"))

        when (transaction.type) {
            TransactionType.INCOME -> {
                val updatedBalance = if (sourceAccount.type == AccountType.CREDIT_CARD) {
                    sourceAccount.currentBalance - transaction.amount
                } else {
                    sourceAccount.currentBalance + transaction.amount
                }
                accountRepository.updateBalance(sourceAccount.id, updatedBalance)
            }
            TransactionType.EXPENSE -> {
                val updatedBalance = if (sourceAccount.type == AccountType.CREDIT_CARD) {
                    sourceAccount.currentBalance + transaction.amount // Credit card balance is debt/used credit
                } else {
                    sourceAccount.currentBalance - transaction.amount
                }
                accountRepository.updateBalance(sourceAccount.id, updatedBalance)
            }
            TransactionType.TRANSFER -> {
                val destAccountId = transaction.destinationAccountId
                    ?: return AppResult.Failure(AppError.Validation("Destination account required for transfer"))
                if (destAccountId == transaction.accountId) {
                    return AppResult.Failure(AppError.Validation("Source and destination accounts must be different"))
                }
                val destAccount = accountRepository.getAccountById(destAccountId)
                    ?: return AppResult.Failure(AppError.Validation("Destination account does not exist"))

                // Debit source account
                val newSourceBal = if (sourceAccount.type == AccountType.CREDIT_CARD) {
                    sourceAccount.currentBalance + transaction.amount
                } else {
                    sourceAccount.currentBalance - transaction.amount
                }
                accountRepository.updateBalance(sourceAccount.id, newSourceBal)

                // Credit destination account
                val newDestBal = if (destAccount.type == AccountType.CREDIT_CARD) {
                    destAccount.currentBalance - transaction.amount
                } else {
                    destAccount.currentBalance + transaction.amount
                }
                accountRepository.updateBalance(destAccount.id, newDestBal)
            }
            TransactionType.REFUND -> {
                val updatedBalance = if (sourceAccount.type == AccountType.CREDIT_CARD) {
                    sourceAccount.currentBalance - transaction.amount
                } else {
                    sourceAccount.currentBalance + transaction.amount
                }
                accountRepository.updateBalance(sourceAccount.id, updatedBalance)
            }
            TransactionType.ADJUSTMENT -> {
                // Adjustment sets account balance directly or offsets
                accountRepository.updateBalance(sourceAccount.id, transaction.amount)
            }
        }

        return transactionRepository.createTransaction(transaction)
    }
}

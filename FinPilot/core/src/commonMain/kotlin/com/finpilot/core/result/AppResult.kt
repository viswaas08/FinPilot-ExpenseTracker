package com.finpilot.core.result

sealed interface AppError {
    val message: String

    data class Network(override val message: String = "Network connection unavailable") : AppError
    data class Auth(override val message: String = "Authentication failed") : AppError
    data class Database(override val message: String = "Local storage error") : AppError
    data class SyncConflict(override val message: String = "Data synchronization conflict") : AppError
    data class Validation(override val message: String = "Invalid input data") : AppError
    data class SheetsIntegration(override val message: String = "Google Sheets export failed") : AppError
    data class AIService(override val message: String = "AI intelligence service temporarily unavailable") : AppError
    data class Unknown(override val message: String = "An unexpected error occurred") : AppError
}

sealed class AppResult<out T> {
    data class Success<out T>(val data: T) : AppResult<T>()
    data class Failure(val error: AppError) : AppResult<Nothing>()

    val isSuccess: Boolean get() = this is Success
    val isFailure: Boolean get() = this is Failure

    fun getOrNull(): T? = when (this) {
        is Success -> data
        is Failure -> null
    }

    inline fun <R> map(transform: (T) -> R): AppResult<R> = when (this) {
        is Success -> Success(transform(data))
        is Failure -> this
    }

    inline fun onSuccess(action: (T) -> Unit): AppResult<T> {
        if (this is Success) action(data)
        return this
    }

    inline fun onFailure(action: (AppError) -> Unit): AppResult<T> {
        if (this is Failure) action(error)
        return this
    }
}

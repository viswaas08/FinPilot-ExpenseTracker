package com.finpilot.domain.repositories

import com.finpilot.core.result.AppResult
import com.finpilot.domain.models.Budget
import com.finpilot.domain.models.Category
import com.finpilot.domain.models.SavingsGoal
import com.finpilot.domain.models.Subscription
import kotlinx.coroutines.flow.Flow

interface BudgetRepository {
    fun getBudgetsFlow(): Flow<List<Budget>>
    suspend fun getBudgetById(id: String): Budget?
    suspend fun saveBudget(budget: Budget): AppResult<Budget>
    suspend fun deleteBudget(id: String): AppResult<Unit>
}

interface SavingsGoalRepository {
    fun getGoalsFlow(): Flow<List<SavingsGoal>>
    suspend fun getGoalById(id: String): SavingsGoal?
    suspend fun saveGoal(goal: SavingsGoal): AppResult<SavingsGoal>
    suspend fun deleteGoal(id: String): AppResult<Unit>
}

interface SubscriptionRepository {
    fun getSubscriptionsFlow(): Flow<List<Subscription>>
    suspend fun getSubscriptionById(id: String): Subscription?
    suspend fun saveSubscription(subscription: Subscription): AppResult<Subscription>
    suspend fun deleteSubscription(id: String): AppResult<Unit>
}

interface CategoryRepository {
    fun getCategoriesFlow(): Flow<List<Category>>
    suspend fun getCategoryById(id: String): Category?
    suspend fun saveCategory(category: Category): AppResult<Category>
    suspend fun seedDefaultCategories(): AppResult<Unit>
}

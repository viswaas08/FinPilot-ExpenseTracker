package com.finpilot.data.repositories

import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import com.finpilot.core.result.AppResult
import com.finpilot.domain.models.*
import com.finpilot.domain.repositories.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class CategoryRepositoryImpl : CategoryRepository {
    private val categoriesState = MutableStateFlow<List<Category>>(Category.defaultCategories())

    override fun getCategoriesFlow(): Flow<List<Category>> = categoriesState.asStateFlow()

    override suspend fun getCategoryById(id: String): Category? {
        return categoriesState.value.find { it.id == id && it.deletedAt == null }
    }

    override suspend fun saveCategory(category: Category): AppResult<Category> {
        val now = 1728038400000L
        val saved = category.copy(updatedAt = now)
        categoriesState.update { list ->
            if (list.any { it.id == saved.id }) list.map { if (it.id == saved.id) saved else it }
            else list + saved
        }
        return AppResult.Success(saved)
    }

    override suspend fun seedDefaultCategories(): AppResult<Unit> {
        categoriesState.value = Category.defaultCategories()
        return AppResult.Success(Unit)
    }
}

class BudgetRepositoryImpl : BudgetRepository {
    private val budgetsState = MutableStateFlow<List<Budget>>(emptyList())

    init {
        if (budgetsState.value.isEmpty()) {
            val now = 1728038400000L
            budgetsState.value = listOf(
                Budget(
                    id = "bgt_food",
                    userId = "default_user",
                    name = "Food & Dining",
                    categoryId = "cat_food",
                    limitAmount = Money.fromMajor(6000, Currency.INR),
                    spentAmount = Money.fromMajor(4250, Currency.INR),
                    startDate = now - 15 * 86400000L,
                    endDate = now + 15 * 86400000L
                ),
                Budget(
                    id = "bgt_shopping",
                    userId = "default_user",
                    name = "Shopping & Retail",
                    categoryId = "cat_shopping",
                    limitAmount = Money.fromMajor(10000, Currency.INR),
                    spentAmount = Money.fromMajor(7200, Currency.INR),
                    startDate = now - 15 * 86400000L,
                    endDate = now + 15 * 86400000L
                ),
                Budget(
                    id = "bgt_transport",
                    userId = "default_user",
                    name = "Transport & Commute",
                    categoryId = "cat_transport",
                    limitAmount = Money.fromMajor(4000, Currency.INR),
                    spentAmount = Money.fromMajor(1800, Currency.INR),
                    startDate = now - 15 * 86400000L,
                    endDate = now + 15 * 86400000L
                )
            )
        }
    }

    override fun getBudgetsFlow(): Flow<List<Budget>> = budgetsState.asStateFlow()

    override suspend fun getBudgetById(id: String): Budget? = budgetsState.value.find { it.id == id && it.deletedAt == null }

    override suspend fun saveBudget(budget: Budget): AppResult<Budget> {
        val now = 1728038400000L
        val saved = budget.copy(updatedAt = now, syncStatus = SyncStatus.PENDING_UPDATE)
        budgetsState.update { list ->
            if (list.any { it.id == saved.id }) list.map { if (it.id == saved.id) saved else it }
            else list + saved
        }
        return AppResult.Success(saved)
    }

    override suspend fun deleteBudget(id: String): AppResult<Unit> {
        budgetsState.update { it.filter { b -> b.id != id } }
        return AppResult.Success(Unit)
    }
}

class SavingsGoalRepositoryImpl : SavingsGoalRepository {
    private val goalsState = MutableStateFlow<List<SavingsGoal>>(emptyList())

    init {
        if (goalsState.value.isEmpty()) {
            val now = 1728038400000L
            goalsState.value = listOf(
                SavingsGoal(
                    id = "goal_laptop",
                    userId = "default_user",
                    name = "MacBook Pro M3",
                    targetAmount = Money.fromMajor(150000, Currency.INR),
                    currentAmount = Money.fromMajor(95000, Currency.INR),
                    targetDate = now + 90 * 86400000L,
                    monthlyContribution = Money.fromMajor(18000, Currency.INR),
                    icon = "laptop_mac",
                    color = "#6366F1"
                ),
                SavingsGoal(
                    id = "goal_emergency",
                    userId = "default_user",
                    name = "Emergency Runway (6 Months)",
                    targetAmount = Money.fromMajor(300000, Currency.INR),
                    currentAmount = Money.fromMajor(220000, Currency.INR),
                    targetDate = now + 180 * 86400000L,
                    monthlyContribution = Money.fromMajor(15000, Currency.INR),
                    icon = "security",
                    color = "#10B981"
                )
            )
        }
    }

    override fun getGoalsFlow(): Flow<List<SavingsGoal>> = goalsState.asStateFlow()

    override suspend fun getGoalById(id: String): SavingsGoal? = goalsState.value.find { it.id == id && it.deletedAt == null }

    override suspend fun saveGoal(goal: SavingsGoal): AppResult<SavingsGoal> {
        val now = 1728038400000L
        val saved = goal.copy(updatedAt = now, syncStatus = SyncStatus.PENDING_UPDATE)
        goalsState.update { list ->
            if (list.any { it.id == saved.id }) list.map { if (it.id == saved.id) saved else it }
            else list + saved
        }
        return AppResult.Success(saved)
    }

    override suspend fun deleteGoal(id: String): AppResult<Unit> {
        goalsState.update { it.filter { g -> g.id != id } }
        return AppResult.Success(Unit)
    }
}

class SubscriptionRepositoryImpl : SubscriptionRepository {
    private val subState = MutableStateFlow<List<Subscription>>(emptyList())

    init {
        if (subState.value.isEmpty()) {
            val now = 1728038400000L
            subState.value = listOf(
                Subscription(
                    id = "sub_spotify",
                    userId = "default_user",
                    name = "Spotify Premium Duo",
                    amount = Money.fromMajor(149, Currency.INR),
                    frequency = RecurringFrequency.MONTHLY,
                    nextPaymentDate = now + 5 * 86400000L,
                    categoryId = "cat_entertainment",
                    accountId = "acc_hdfc_card",
                    reminderEnabled = true
                ),
                Subscription(
                    id = "sub_netflix",
                    userId = "default_user",
                    name = "Netflix 4K Ultra",
                    amount = Money.fromMajor(649, Currency.INR),
                    frequency = RecurringFrequency.MONTHLY,
                    nextPaymentDate = now + 12 * 86400000L,
                    categoryId = "cat_entertainment",
                    accountId = "acc_hdfc_card",
                    reminderEnabled = true
                ),
                Subscription(
                    id = "sub_wifi",
                    userId = "default_user",
                    name = "Airtel Fiber Gigabit",
                    amount = Money.fromMajor(1179, Currency.INR),
                    frequency = RecurringFrequency.MONTHLY,
                    nextPaymentDate = now + 18 * 86400000L,
                    categoryId = "cat_bills",
                    accountId = "acc_sbi",
                    reminderEnabled = true
                )
            )
        }
    }

    override fun getSubscriptionsFlow(): Flow<List<Subscription>> = subState.asStateFlow()

    override suspend fun getSubscriptionById(id: String): Subscription? = subState.value.find { it.id == id && it.deletedAt == null }

    override suspend fun saveSubscription(subscription: Subscription): AppResult<Subscription> {
        val now = 1728038400000L
        val saved = subscription.copy(updatedAt = now, syncStatus = SyncStatus.PENDING_UPDATE)
        subState.update { list ->
            if (list.any { it.id == saved.id }) list.map { if (it.id == saved.id) saved else it }
            else list + saved
        }
        return AppResult.Success(saved)
    }

    override suspend fun deleteSubscription(id: String): AppResult<Unit> {
        subState.update { it.filter { s -> s.id != id } }
        return AppResult.Success(Unit)
    }
}

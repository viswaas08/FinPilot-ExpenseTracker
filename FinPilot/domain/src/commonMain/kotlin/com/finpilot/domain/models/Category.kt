package com.finpilot.domain.models

import com.finpilot.core.money.Money
import kotlinx.serialization.Serializable

@Serializable
enum class CategoryType {
    EXPENSE,
    INCOME,
    ALL
}

@Serializable
data class Category(
    val id: String,
    val userId: String = "",
    val name: String,
    val icon: String = "category",
    val color: String = "#6C5CE7",
    val type: CategoryType = CategoryType.EXPENSE,
    val isDefault: Boolean = false,
    val budgetLimit: Money? = null,
    val createdAt: Long = 0L,
    val updatedAt: Long = 0L,
    val deletedAt: Long? = null,
    val version: Long = 1L,
    val syncStatus: SyncStatus = SyncStatus.SYNCED
) {
    companion object {
        fun defaultCategories(): List<Category> = listOf(
            Category("cat_food", "", "Food & Dining", "restaurant", "#F59E0B", CategoryType.EXPENSE, true),
            Category("cat_shopping", "", "Shopping", "shopping_bag", "#EC4899", CategoryType.EXPENSE, true),
            Category("cat_transport", "", "Transport & Fuel", "directions_car", "#38BDF8", CategoryType.EXPENSE, true),
            Category("cat_bills", "", "Bills & Utilities", "receipt_long", "#8B5CF6", CategoryType.EXPENSE, true),
            Category("cat_entertainment", "", "Entertainment", "movie", "#F43F5E", CategoryType.EXPENSE, true),
            Category("cat_health", "", "Health & Medical", "medical_services", "#10B981", CategoryType.EXPENSE, true),
            Category("cat_investment", "", "Investments", "trending_up", "#6366F1", CategoryType.EXPENSE, true),
            Category("cat_education", "", "Education", "school", "#14B8A6", CategoryType.EXPENSE, true),
            Category("cat_salary", "", "Salary", "work", "#22C55E", CategoryType.INCOME, true),
            Category("cat_freelance", "", "Freelance & Consulting", "laptop", "#0EA5E9", CategoryType.INCOME, true),
            Category("cat_invest_return", "", "Dividends & Interest", "account_balance", "#84CC16", CategoryType.INCOME, true)
        )
    }
}

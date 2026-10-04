package com.finpilot.notifications

import com.finpilot.core.logging.AppLogger
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

enum class NotificationCategory {
    BUDGET,
    SUBSCRIPTION,
    CREDIT_CARD,
    SAVINGS_GOAL,
    AI_ALERT,
    SYNC
}

data class FinPilotNotification(
    val id: String,
    val title: String,
    val body: String,
    val category: NotificationCategory,
    val timestamp: Long,
    val isRead: Boolean = false,
    val actionDeepLink: String? = null
)

class NotificationManager {
    private val _notifications = MutableStateFlow<List<FinPilotNotification>>(emptyList())
    val notificationsFlow: Flow<List<FinPilotNotification>> = _notifications.asStateFlow()

    init {
        val now = 1728038400000L
        _notifications.value = listOf(
            FinPilotNotification(
                id = "notif_budget_food",
                title = "Budget Threshold Alert (70.8%)",
                body = "Food & Dining spending reached ₹4,250 of your ₹6,000 monthly budget.",
                category = NotificationCategory.BUDGET,
                timestamp = now - 3600000L
            ),
            FinPilotNotification(
                id = "notif_sub_spotify",
                title = "Subscription Due Tomorrow",
                body = "Spotify Premium Duo (₹149) will be charged to your HDFC Credit Card in 24 hours.",
                category = NotificationCategory.SUBSCRIPTION,
                timestamp = now - 7200000L
            ),
            FinPilotNotification(
                id = "notif_cc_bill",
                title = "HDFC Credit Card Bill Generated",
                body = "Statement balance: ₹27,450. Due date is in 15 days.",
                category = NotificationCategory.CREDIT_CARD,
                timestamp = now - 86400000L
            )
        )
    }

    fun dispatch(title: String, body: String, category: NotificationCategory, deepLink: String? = null) {
        val notif = FinPilotNotification(
            id = "notif_${kotlin.random.Random.nextLong(100000, 999999)}",
            title = title,
            body = body,
            category = category,
            timestamp = 1728038400000L,
            actionDeepLink = deepLink
        )
        _notifications.update { listOf(notif) + it }
        AppLogger.i("Notifications", "Dispatched: $title - $body")
    }

    fun markAsRead(id: String) {
        _notifications.update { list ->
            list.map { if (it.id == id) it.copy(isRead = true) else it }
        }
    }

    fun clearAll() {
        _notifications.value = emptyList()
    }
}

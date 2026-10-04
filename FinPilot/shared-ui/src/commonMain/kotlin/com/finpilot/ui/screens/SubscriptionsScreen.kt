package com.finpilot.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.AppTypography
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.domain.models.Subscription
import com.finpilot.domain.models.SubscriptionStatus
import com.finpilot.ui.components.CurrencyText
import com.finpilot.ui.components.LiquidCard

@Composable
fun SubscriptionsScreen(
    subscriptions: List<Subscription>,
    onToggleStatus: (Subscription) -> Unit,
    modifier: Modifier = Modifier
) {
    val colors = FinPilotTheme.colors

    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .background(colors.background)
            .padding(horizontal = AppTokens.Space20),
        verticalArrangement = Arrangement.spacedBy(AppTokens.Space16),
        contentPadding = PaddingValues(top = AppTokens.Space16, bottom = AppTokens.Space48)
    ) {
        item {
            Text(
                text = "Subscriptions & Bills",
                style = MaterialTheme.typography.headlineLarge,
                color = colors.textPrimary,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "Automated recurring tracking with 24h advance notifications",
                style = MaterialTheme.typography.labelSmall,
                color = colors.textSecondary
            )
        }

        items(subscriptions) { sub ->
            val isActive = sub.status == SubscriptionStatus.ACTIVE

            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = sub.name,
                            style = MaterialTheme.typography.titleLarge,
                            color = colors.textPrimary,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "${sub.frequency.name} • Next: in 5 days",
                            style = MaterialTheme.typography.labelSmall,
                            color = colors.textMuted
                        )
                    }
                    CurrencyText(
                        money = sub.amount,
                        style = AppTypography.CurrencyDisplaySmall,
                        color = if (sub.isIncome) colors.success else colors.danger
                    )
                }

                Spacer(modifier = Modifier.height(AppTokens.Space12))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = if (sub.reminderEnabled) "🔔 24h Reminder Active" else "🔕 Reminder Off",
                            style = MaterialTheme.typography.labelSmall,
                            color = colors.textSecondary
                        )
                    }

                    TextButton(onClick = { onToggleStatus(sub) }) {
                        Text(
                            text = if (isActive) "Pause" else "Resume",
                            color = if (isActive) colors.warning else colors.success,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                }
            }
        }
    }
}

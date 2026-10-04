package com.finpilot.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.finpilot.core.money.Money
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.AppTypography
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.domain.models.*
import com.finpilot.sync.SyncState
import com.finpilot.ui.components.*

@Composable
fun DashboardScreen(
    dashboardData: DashboardData,
    syncState: SyncState,
    onAddTransactionClick: () -> Unit,
    onViewAllTransactions: () -> Unit,
    onAccountClick: (Account) -> Unit,
    onInsightActionClick: (AIInsight) -> Unit,
    modifier: Modifier = Modifier
) {
    val colors = FinPilotTheme.colors

    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .background(colors.background)
            .padding(horizontal = AppTokens.Space20),
        verticalArrangement = Arrangement.spacedBy(AppTokens.Space20),
        contentPadding = PaddingValues(top = AppTokens.Space16, bottom = AppTokens.Space48)
    ) {
        // Header with Sync Badge
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "FinPilot 2.0",
                        style = MaterialTheme.typography.headlineLarge,
                        color = colors.textPrimary,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Financial Control Center",
                        style = MaterialTheme.typography.labelSmall,
                        color = colors.textSecondary
                    )
                }
                SyncBadge(syncState = syncState)
            }
        }

        // Hero Card: Total Balance & Net Worth Overview
        item {
            LiquidCard(
                modifier = Modifier.fillMaxWidth(),
                cornerRadius = AppTokens.RadiusCard
            ) {
                Text(
                    text = "TOTAL LIQUID BALANCE",
                    style = MaterialTheme.typography.labelSmall,
                    color = colors.textSecondary,
                    letterSpacing = 1.sp
                )
                Spacer(modifier = Modifier.height(AppTokens.Space8))
                CurrencyText(
                    money = dashboardData.totalBalance,
                    style = AppTypography.CurrencyDisplayLarge,
                    color = colors.textPrimary
                )
                Spacer(modifier = Modifier.height(AppTokens.Space16))
                Divider(color = colors.border.copy(alpha = 0.5f))
                Spacer(modifier = Modifier.height(AppTokens.Space16))

                // Income, Expense, Savings grid
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column {
                        Text("Income", style = MaterialTheme.typography.labelSmall, color = colors.textSecondary)
                        Spacer(modifier = Modifier.height(AppTokens.Space4))
                        CurrencyText(dashboardData.income, style = AppTypography.CurrencyDisplaySmall, color = colors.success)
                    }
                    Column {
                        Text("Expenses", style = MaterialTheme.typography.labelSmall, color = colors.textSecondary)
                        Spacer(modifier = Modifier.height(AppTokens.Space4))
                        CurrencyText(dashboardData.expenses, style = AppTypography.CurrencyDisplaySmall, color = colors.danger)
                    }
                    Column {
                        Text("Savings (${dashboardData.savingsRatePercentage.toInt()}%)", style = MaterialTheme.typography.labelSmall, color = colors.textSecondary)
                        Spacer(modifier = Modifier.height(AppTokens.Space4))
                        CurrencyText(dashboardData.savings, style = AppTypography.CurrencyDisplaySmall, color = colors.secondary)
                    }
                }
            }
        }

        // Featured AI Insight Card
        item {
            dashboardData.featuredAIInsight?.let { insight ->
                LiquidCard(
                    modifier = Modifier.fillMaxWidth(),
                    cornerRadius = AppTokens.RadiusCard
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(
                                modifier = Modifier
                                    .size(8.dp)
                                    .background(colors.primary, CircleShape)
                            )
                            Spacer(modifier = Modifier.width(AppTokens.Space8))
                            Text(
                                text = "GEMINI FINANCIAL INTELLIGENCE",
                                style = MaterialTheme.typography.labelSmall,
                                color = colors.primary,
                                fontWeight = FontWeight.Bold,
                                letterSpacing = 0.5.sp
                            )
                        }
                        Text(
                            text = "${(insight.confidence * 100).toInt()}% confidence",
                            style = MaterialTheme.typography.labelSmall,
                            color = colors.textMuted
                        )
                    }
                    Spacer(modifier = Modifier.height(AppTokens.Space8))
                    Text(
                        text = insight.title,
                        style = MaterialTheme.typography.headlineMedium,
                        color = colors.textPrimary,
                        fontWeight = FontWeight.SemiBold
                    )
                    Spacer(modifier = Modifier.height(AppTokens.Space4))
                    Text(
                        text = insight.content,
                        style = MaterialTheme.typography.bodyMedium,
                        color = colors.textSecondary
                    )
                    if (insight.actionText != null) {
                        Spacer(modifier = Modifier.height(AppTokens.Space12))
                        Text(
                            text = "${insight.actionText} →",
                            style = MaterialTheme.typography.titleLarge,
                            color = colors.primary,
                            fontWeight = FontWeight.SemiBold,
                            modifier = Modifier.clickable { onInsightActionClick(insight) }
                        )
                    }
                }
            }
        }

        // Account Cards Carousel
        item {
            Column {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Accounts & Wallets",
                        style = MaterialTheme.typography.headlineMedium,
                        color = colors.textPrimary,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "${dashboardData.accounts.size} Active",
                        style = MaterialTheme.typography.labelSmall,
                        color = colors.textSecondary
                    )
                }
                Spacer(modifier = Modifier.height(AppTokens.Space12))
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(AppTokens.Space12),
                    contentPadding = PaddingValues(horizontal = 2.dp)
                ) {
                    items(dashboardData.accounts) { acc ->
                        LiquidCard(
                            modifier = Modifier
                                .width(220.dp)
                                .clickable { onAccountClick(acc) }
                        ) {
                            Text(
                                text = acc.name,
                                style = MaterialTheme.typography.titleLarge,
                                color = colors.textPrimary,
                                fontWeight = FontWeight.SemiBold
                            )
                            Text(
                                text = acc.institutionName,
                                style = MaterialTheme.typography.labelSmall,
                                color = colors.textMuted
                            )
                            Spacer(modifier = Modifier.height(AppTokens.Space12))
                            CurrencyText(
                                money = acc.currentBalance,
                                style = AppTypography.CurrencyDisplaySmall,
                                color = if (acc.type == AccountType.CREDIT_CARD) colors.danger else colors.textPrimary
                            )
                            if (acc.type == AccountType.CREDIT_CARD && acc.creditLimit != null) {
                                Spacer(modifier = Modifier.height(AppTokens.Space8))
                                acc.creditUtilizationPercentage?.let { util ->
                                    CustomProgressBar(
                                        progressPercentage = util,
                                        barColor = if (util > 30) colors.danger else colors.secondary
                                    )
                                    Spacer(modifier = Modifier.height(AppTokens.Space4))
                                    Text(
                                        text = "${util.toInt()}% used of ${acc.creditLimit.toFormattedString()}",
                                        style = MaterialTheme.typography.labelSmall,
                                        color = colors.textMuted
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }

        // Spending by Category Breakdown
        item {
            Column {
                Text(
                    text = "Spending Breakdown",
                    style = MaterialTheme.typography.headlineMedium,
                    color = colors.textPrimary,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(AppTokens.Space12))
                LiquidCard(modifier = Modifier.fillMaxWidth()) {
                    if (dashboardData.spendingByCategory.isEmpty()) {
                        EmptyStateView(
                            title = "No expenses recorded",
                            message = "Log your transactions to see category insights."
                        )
                    } else {
                        dashboardData.spendingByCategory.take(5).forEach { catSpend ->
                            Column(modifier = Modifier.padding(vertical = AppTokens.Space4)) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(
                                        text = catSpend.category.name,
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = colors.textPrimary
                                    )
                                    CurrencyText(
                                        money = catSpend.amount,
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = colors.textPrimary
                                    )
                                }
                                Spacer(modifier = Modifier.height(AppTokens.Space4))
                                CustomProgressBar(
                                    progressPercentage = catSpend.percentage,
                                    barColor = try { Color(android.graphics.Color.parseColor(catSpend.category.color)) } catch (_: Exception) { colors.primary }
                                )
                            }
                        }
                    }
                }
            }
        }

        // Recent Transactions
        item {
            Column {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Recent Transactions",
                        style = MaterialTheme.typography.headlineMedium,
                        color = colors.textPrimary,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "View All →",
                        style = MaterialTheme.typography.titleLarge,
                        color = colors.primary,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.clickable { onViewAllTransactions() }
                    )
                }
                Spacer(modifier = Modifier.height(AppTokens.Space12))
                LiquidCard(modifier = Modifier.fillMaxWidth()) {
                    if (dashboardData.recentTransactions.isEmpty()) {
                        EmptyStateView(
                            title = "No transactions yet",
                            message = "Start tracking your first expense to understand where your money goes.",
                            actionButtonText = "Add Transaction",
                            onActionClick = onAddTransactionClick
                        )
                    } else {
                        dashboardData.recentTransactions.forEach { tx ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = AppTokens.Space8),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Box(
                                        modifier = Modifier
                                            .size(36.dp)
                                            .clip(CircleShape)
                                            .background(colors.elevated)
                                            .border(1.dp, colors.border, CircleShape),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Text(
                                            text = if (tx.type == TransactionType.INCOME) "↓" else if (tx.type == TransactionType.TRANSFER) "⇄" else "↑",
                                            color = if (tx.type == TransactionType.INCOME) colors.success else if (tx.type == TransactionType.TRANSFER) colors.secondary else colors.danger,
                                            fontWeight = FontWeight.Bold
                                        )
                                    }
                                    Spacer(modifier = Modifier.width(AppTokens.Space12))
                                    Column {
                                        Text(
                                            text = tx.description,
                                            style = MaterialTheme.typography.bodyLarge,
                                            color = colors.textPrimary,
                                            fontWeight = FontWeight.Medium
                                        )
                                        Text(
                                            text = tx.type.name,
                                            style = MaterialTheme.typography.labelSmall,
                                            color = colors.textMuted
                                        )
                                    }
                                }
                                CurrencyText(
                                    money = tx.amount,
                                    style = MaterialTheme.typography.bodyLarge,
                                    color = if (tx.type == TransactionType.INCOME) colors.success else if (tx.type == TransactionType.TRANSFER) colors.secondary else colors.textPrimary
                                )
                            }
                            Divider(color = colors.border.copy(alpha = 0.3f))
                        }
                    }
                }
            }
        }
    }
}

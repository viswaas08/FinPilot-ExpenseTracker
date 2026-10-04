package com.finpilot.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.AppTypography
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.domain.models.CategorySpending
import com.finpilot.domain.models.DashboardData
import com.finpilot.domain.models.NetWorth
import com.finpilot.ui.components.CurrencyText
import com.finpilot.ui.components.CustomProgressBar
import com.finpilot.ui.components.LiquidCard

@Composable
fun AnalyticsScreen(
    dashboardData: DashboardData,
    netWorth: NetWorth,
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
        item {
            Text(
                text = "Financial Analytics",
                style = MaterialTheme.typography.headlineLarge,
                color = colors.textPrimary,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "Cash flow, Net worth trajectory, and Spending breakdowns",
                style = MaterialTheme.typography.labelSmall,
                color = colors.textSecondary
            )
        }

        // Net Worth Trajectory Card
        item {
            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "TOTAL NET WORTH",
                    style = MaterialTheme.typography.labelSmall,
                    color = colors.textSecondary,
                    letterSpacing = 1.sp
                )
                Spacer(modifier = Modifier.height(AppTokens.Space8))
                CurrencyText(
                    money = netWorth.netWorth,
                    style = AppTypography.CurrencyDisplayLarge,
                    color = colors.textPrimary
                )
                Spacer(modifier = Modifier.height(AppTokens.Space16))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column {
                        Text("Gross Assets", style = MaterialTheme.typography.labelSmall, color = colors.textSecondary)
                        CurrencyText(netWorth.totalAssets, style = AppTypography.CurrencyDisplaySmall, color = colors.success)
                    }
                    Column(horizontalAlignment = Alignment.End) {
                        Text("Total Liabilities", style = MaterialTheme.typography.labelSmall, color = colors.textSecondary)
                        CurrencyText(netWorth.totalLiabilities, style = AppTypography.CurrencyDisplaySmall, color = colors.danger)
                    }
                }
            }
        }

        // Cash Flow Overview
        item {
            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Monthly Cash Flow",
                    style = MaterialTheme.typography.titleLarge,
                    color = colors.textPrimary,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(AppTokens.Space12))
                dashboardData.cashFlowPoints.forEach { point ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(point.label, color = colors.textSecondary, style = MaterialTheme.typography.bodyMedium)
                        Row(horizontalArrangement = Arrangement.spacedBy(AppTokens.Space12)) {
                            Text("+${point.income.toFormattedString()}", color = colors.success, fontSize = 12.sp)
                            Text("-${point.expense.toFormattedString()}", color = colors.danger, fontSize = 12.sp)
                        }
                    }
                }
            }
        }

        // Category Breakdown
        item {
            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Expense Distribution",
                    style = MaterialTheme.typography.titleLarge,
                    color = colors.textPrimary,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(AppTokens.Space12))
                dashboardData.spendingByCategory.forEach { item ->
                    Column(modifier = Modifier.padding(vertical = AppTokens.Space4)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(item.category.name, color = colors.textPrimary)
                            CurrencyText(item.amount, color = colors.textPrimary, style = MaterialTheme.typography.bodyMedium)
                        }
                        Spacer(modifier = Modifier.height(4.dp))
                        CustomProgressBar(progressPercentage = item.percentage, barColor = colors.primary)
                    }
                }
            }
        }
    }
}

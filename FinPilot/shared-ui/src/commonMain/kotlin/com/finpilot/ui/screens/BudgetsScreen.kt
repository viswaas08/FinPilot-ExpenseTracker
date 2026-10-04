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
import com.finpilot.domain.models.Budget
import com.finpilot.ui.components.CurrencyText
import com.finpilot.ui.components.CustomProgressBar
import com.finpilot.ui.components.LiquidCard

@Composable
fun BudgetsScreen(
    budgets: List<Budget>,
    onAddBudget: () -> Unit,
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
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Smart Budgets",
                        style = MaterialTheme.typography.headlineLarge,
                        color = colors.textPrimary,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Threshold monitoring & monthly rollover",
                        style = MaterialTheme.typography.labelSmall,
                        color = colors.textSecondary
                    )
                }
            }
        }

        items(budgets) { budget ->
            val progress = budget.progressPercentage
            val barColor = when {
                progress >= 100.0 -> colors.danger
                progress >= 90.0 -> colors.danger
                progress >= 75.0 -> colors.warning
                else -> colors.success
            }

            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = budget.name,
                            style = MaterialTheme.typography.titleLarge,
                            color = colors.textPrimary,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "${budget.period.name} BUDGET",
                            style = MaterialTheme.typography.labelSmall,
                            color = colors.textMuted,
                            letterSpacing = 0.5.sp
                        )
                    }
                    Text(
                        text = "${progress.toInt()}%",
                        style = MaterialTheme.typography.titleLarge,
                        color = barColor,
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.height(AppTokens.Space12))

                CustomProgressBar(
                    progressPercentage = progress,
                    barColor = barColor,
                    height = 8.dp
                )

                Spacer(modifier = Modifier.height(AppTokens.Space12))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column {
                        Text("Spent", style = MaterialTheme.typography.labelSmall, color = colors.textSecondary)
                        Spacer(modifier = Modifier.height(2.dp))
                        CurrencyText(budget.spentAmount, style = AppTypography.CurrencyDisplaySmall, color = colors.textPrimary)
                    }
                    Column(horizontalAlignment = Alignment.End) {
                        Text("Budget Limit", style = MaterialTheme.typography.labelSmall, color = colors.textSecondary)
                        Spacer(modifier = Modifier.height(2.dp))
                        CurrencyText(budget.totalEffectiveLimit, style = AppTypography.CurrencyDisplaySmall, color = colors.textSecondary)
                    }
                }
            }
        }
    }
}

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
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.AppTypography
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.domain.models.SavingsGoal
import com.finpilot.ui.components.CurrencyText
import com.finpilot.ui.components.CustomProgressBar
import com.finpilot.ui.components.LiquidCard

@Composable
fun SavingsGoalsScreen(
    goals: List<SavingsGoal>,
    onAddGoal: () -> Unit,
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
                text = "Savings Goals",
                style = MaterialTheme.typography.headlineLarge,
                color = colors.textPrimary,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "Target tracking and recommended monthly contributions",
                style = MaterialTheme.typography.labelSmall,
                color = colors.textSecondary
            )
        }

        items(goals) { goal ->
            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = goal.name,
                            style = MaterialTheme.typography.titleLarge,
                            color = colors.textPrimary,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "Monthly Contribution: ${goal.monthlyContribution.toFormattedString()}",
                            style = MaterialTheme.typography.labelSmall,
                            color = colors.textMuted
                        )
                    }
                    Text(
                        text = "${goal.progressPercentage.toInt()}%",
                        style = MaterialTheme.typography.titleLarge,
                        color = colors.success,
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.height(AppTokens.Space12))

                CustomProgressBar(
                    progressPercentage = goal.progressPercentage,
                    barColor = colors.success,
                    height = 8.dp
                )

                Spacer(modifier = Modifier.height(AppTokens.Space12))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column {
                        Text("Current Savings", style = MaterialTheme.typography.labelSmall, color = colors.textSecondary)
                        CurrencyText(goal.currentAmount, style = AppTypography.CurrencyDisplaySmall, color = colors.success)
                    }
                    Column(horizontalAlignment = Alignment.End) {
                        Text("Target Amount", style = MaterialTheme.typography.labelSmall, color = colors.textSecondary)
                        CurrencyText(goal.targetAmount, style = AppTypography.CurrencyDisplaySmall, color = colors.textPrimary)
                    }
                }
            }
        }
    }
}

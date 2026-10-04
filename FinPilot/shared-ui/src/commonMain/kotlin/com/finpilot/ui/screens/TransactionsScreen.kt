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
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.AppTypography
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.domain.models.Transaction
import com.finpilot.domain.models.TransactionType
import com.finpilot.ui.components.CurrencyText
import com.finpilot.ui.components.EmptyStateView
import com.finpilot.ui.components.LiquidCard

@Composable
fun TransactionsScreen(
    transactions: List<Transaction>,
    onAddTransaction: () -> Unit,
    modifier: Modifier = Modifier
) {
    val colors = FinPilotTheme.colors
    var searchQuery by remember { mutableStateOf("") }
    var selectedFilter by remember { mutableStateOf<TransactionType?>(null) }

    val filteredTransactions = remember(transactions, searchQuery, selectedFilter) {
        transactions.filter { tx ->
            val matchesFilter = selectedFilter == null || tx.type == selectedFilter
            val matchesSearch = searchQuery.isBlank() ||
                tx.description.contains(searchQuery, ignoreCase = true) ||
                tx.notes.contains(searchQuery, ignoreCase = true) ||
                tx.amount.toFormattedString().contains(searchQuery, ignoreCase = true)
            matchesFilter && matchesSearch
        }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(colors.background)
            .padding(horizontal = AppTokens.Space20)
    ) {
        Spacer(modifier = Modifier.height(AppTokens.Space16))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Transactions",
                style = MaterialTheme.typography.headlineLarge,
                color = colors.textPrimary,
                fontWeight = FontWeight.Bold
            )
            Button(
                onClick = onAddTransaction,
                colors = ButtonDefaults.buttonColors(containerColor = colors.primary),
                shape = RoundedCornerShape(AppTokens.RadiusButton)
            ) {
                Text("+ New", color = Color.White, fontWeight = FontWeight.SemiBold)
            }
        }

        Spacer(modifier = Modifier.height(AppTokens.Space12))

        // Search Bar
        OutlinedTextField(
            value = searchQuery,
            onValueChange = { searchQuery = it },
            placeholder = { Text("Search Swiggy, Food, SBI, ₹500...") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(AppTokens.RadiusButton),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = colors.primary,
                unfocusedBorderColor = colors.border,
                focusedContainerColor = colors.elevated,
                unfocusedContainerColor = colors.elevated
            )
        )

        Spacer(modifier = Modifier.height(AppTokens.Space12))

        // Type Filter Chips
        LazyRow(horizontalArrangement = Arrangement.spacedBy(AppTokens.Space8)) {
            item {
                FilterChip(
                    selected = selectedFilter == null,
                    onClick = { selectedFilter = null },
                    label = { Text("All") }
                )
            }
            items(listOf(TransactionType.EXPENSE, TransactionType.INCOME, TransactionType.TRANSFER)) { type ->
                FilterChip(
                    selected = selectedFilter == type,
                    onClick = { selectedFilter = if (selectedFilter == type) null else type },
                    label = { Text(type.name) }
                )
            }
        }

        Spacer(modifier = Modifier.height(AppTokens.Space16))

        // Transaction List
        if (filteredTransactions.isEmpty()) {
            EmptyStateView(
                title = "No transactions found",
                message = if (searchQuery.isNotBlank()) "No records match '$searchQuery'." else "You haven't logged any transactions under this filter.",
                actionButtonText = if (searchQuery.isBlank()) "Add Transaction" else null,
                onActionClick = onAddTransaction
            )
        } else {
            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(AppTokens.Space8),
                contentPadding = PaddingValues(bottom = AppTokens.Space48)
            ) {
                items(filteredTransactions) { tx ->
                    LiquidCard(modifier = Modifier.fillMaxWidth()) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Box(
                                    modifier = Modifier
                                        .size(40.dp)
                                        .clip(CircleShape)
                                        .background(colors.elevated)
                                        .border(1.dp, colors.border, CircleShape),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = when (tx.type) {
                                            TransactionType.INCOME -> "↓"
                                            TransactionType.TRANSFER -> "⇄"
                                            else -> "↑"
                                        },
                                        color = when (tx.type) {
                                            TransactionType.INCOME -> colors.success
                                            TransactionType.TRANSFER -> colors.secondary
                                            else -> colors.danger
                                        },
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 18.sp
                                    )
                                }
                                Spacer(modifier = Modifier.width(AppTokens.Space12))
                                Column {
                                    Text(
                                        text = tx.description,
                                        style = MaterialTheme.typography.bodyLarge,
                                        color = colors.textPrimary,
                                        fontWeight = FontWeight.SemiBold
                                    )
                                    Text(
                                        text = "${tx.type.name} • ${tx.currency.code}",
                                        style = MaterialTheme.typography.labelSmall,
                                        color = colors.textMuted
                                    )
                                }
                            }
                            CurrencyText(
                                money = tx.amount,
                                style = AppTypography.CurrencyDisplaySmall,
                                color = when (tx.type) {
                                    TransactionType.INCOME -> colors.success
                                    TransactionType.TRANSFER -> colors.secondary
                                    else -> colors.textPrimary
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}

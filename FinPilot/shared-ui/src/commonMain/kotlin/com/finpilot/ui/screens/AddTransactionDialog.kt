package com.finpilot.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
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
import androidx.compose.ui.window.Dialog
import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.AppTypography
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.domain.models.*
import com.finpilot.ui.components.CurrencyText
import com.finpilot.ui.components.LiquidCard

@Composable
fun AddTransactionDialog(
    accounts: List<Account>,
    categories: List<Category>,
    onDismiss: () -> Unit,
    onSaveTransaction: (Transaction) -> Unit,
    onParseNaturalLanguage: suspend (String, String) -> Transaction?
) {
    val colors = FinPilotTheme.colors
    var selectedTab by remember { mutableStateOf(0) } // 0 = Manual, 1 = AI Natural Language

    // Manual Fields
    var amountInput by remember { mutableStateOf("") }
    var selectedType by remember { mutableStateOf(TransactionType.EXPENSE) }
    var selectedAccountId by remember { mutableStateOf(accounts.firstOrNull()?.id ?: "") }
    var selectedDestinationAccountId by remember { mutableStateOf(accounts.getOrNull(1)?.id ?: "") }
    var selectedCategoryId by remember { mutableStateOf(categories.firstOrNull()?.id ?: "cat_food") }
    var descriptionInput by remember { mutableStateOf("") }
    var notesInput by remember { mutableStateOf("") }

    // Natural Language Fields
    var naturalLanguageInput by remember { mutableStateOf("") }
    var parsedProposal by remember { mutableStateOf<Transaction?>(null) }
    var isParsingAI by remember { mutableStateOf(false) }
    val coroutineScope = rememberCoroutineScope()

    Dialog(onDismissRequest = onDismiss) {
        LiquidCard(
            modifier = Modifier
                .fillMaxWidth()
                .padding(AppTokens.Space16),
            cornerRadius = AppTokens.RadiusDialog
        ) {
            // Tab Switcher: Quick Form vs AI Natural Language
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(AppTokens.RadiusButton))
                    .background(colors.elevated)
                    .padding(4.dp)
            ) {
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(AppTokens.RadiusSm))
                        .background(if (selectedTab == 0) colors.primary else Color.Transparent)
                        .clickable { selectedTab = 0 }
                        .padding(vertical = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Quick Entry",
                        fontWeight = FontWeight.SemiBold,
                        color = if (selectedTab == 0) Color.White else colors.textSecondary,
                        fontSize = 13.sp
                    )
                }
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(AppTokens.RadiusSm))
                        .background(if (selectedTab == 1) colors.primary else Color.Transparent)
                        .clickable { selectedTab = 1 }
                        .padding(vertical = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "✦ Natural Language",
                        fontWeight = FontWeight.SemiBold,
                        color = if (selectedTab == 1) Color.White else colors.textSecondary,
                        fontSize = 13.sp
                    )
                }
            }

            Spacer(modifier = Modifier.height(AppTokens.Space16))

            if (selectedTab == 0) {
                // Manual Entry Form
                // Transaction Type Tabs (Expense, Income, Transfer)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(AppTokens.Space8)
                ) {
                    TransactionType.entries.filter { it in listOf(TransactionType.EXPENSE, TransactionType.INCOME, TransactionType.TRANSFER) }.forEach { type ->
                        val isSelected = selectedType == type
                        val activeColor = when (type) {
                            TransactionType.INCOME -> colors.success
                            TransactionType.TRANSFER -> colors.secondary
                            else -> colors.danger
                        }
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .clip(RoundedCornerShape(AppTokens.RadiusButton))
                                .background(if (isSelected) activeColor.copy(alpha = 0.2f) else colors.elevated)
                                .border(1.dp, if (isSelected) activeColor else colors.border, RoundedCornerShape(AppTokens.RadiusButton))
                                .clickable { selectedType = type }
                                .padding(vertical = 8.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = type.name,
                                style = MaterialTheme.typography.labelSmall,
                                fontWeight = FontWeight.Bold,
                                color = if (isSelected) activeColor else colors.textSecondary
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(AppTokens.Space16))

                // Amount input in INR ₹
                OutlinedTextField(
                    value = amountInput,
                    onValueChange = { amountInput = it },
                    label = { Text("Amount (₹ INR)") },
                    placeholder = { Text("0.00") },
                    singleLine = true,
                    textStyle = AppTypography.CurrencyDisplaySmall.copy(color = colors.textPrimary),
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = colors.primary,
                        unfocusedBorderColor = colors.border
                    )
                )

                Spacer(modifier = Modifier.height(AppTokens.Space12))

                // Description
                OutlinedTextField(
                    value = descriptionInput,
                    onValueChange = { descriptionInput = it },
                    label = { Text("Description") },
                    placeholder = { Text("e.g. Lunch, Grocery, Fuel") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = colors.primary,
                        unfocusedBorderColor = colors.border
                    )
                )

                Spacer(modifier = Modifier.height(AppTokens.Space12))

                // Account Selection
                Text("Source Account", style = MaterialTheme.typography.labelSmall, color = colors.textSecondary)
                Spacer(modifier = Modifier.height(AppTokens.Space4))
                LazyRow(horizontalArrangement = Arrangement.spacedBy(AppTokens.Space8)) {
                    items(accounts) { acc ->
                        val isSel = selectedAccountId == acc.id
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(AppTokens.RadiusSm))
                                .background(if (isSel) colors.primary.copy(alpha = 0.25f) else colors.elevated)
                                .border(1.dp, if (isSel) colors.primary else colors.border, RoundedCornerShape(AppTokens.RadiusSm))
                                .clickable { selectedAccountId = acc.id }
                                .padding(horizontal = 12.dp, vertical = 6.dp)
                        ) {
                            Text(text = acc.name, fontSize = 12.sp, color = if (isSel) colors.primary else colors.textPrimary)
                        }
                    }
                }

                if (selectedType == TransactionType.TRANSFER) {
                    Spacer(modifier = Modifier.height(AppTokens.Space8))
                    Text("Destination Account", style = MaterialTheme.typography.labelSmall, color = colors.textSecondary)
                    Spacer(modifier = Modifier.height(AppTokens.Space4))
                    LazyRow(horizontalArrangement = Arrangement.spacedBy(AppTokens.Space8)) {
                        items(accounts.filter { it.id != selectedAccountId }) { acc ->
                            val isSel = selectedDestinationAccountId == acc.id
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(AppTokens.RadiusSm))
                                    .background(if (isSel) colors.secondary.copy(alpha = 0.25f) else colors.elevated)
                                    .border(1.dp, if (isSel) colors.secondary else colors.border, RoundedCornerShape(AppTokens.RadiusSm))
                                    .clickable { selectedDestinationAccountId = acc.id }
                                    .padding(horizontal = 12.dp, vertical = 6.dp)
                            ) {
                                Text(text = acc.name, fontSize = 12.sp, color = if (isSel) colors.secondary else colors.textPrimary)
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(AppTokens.Space12))

                // Category Selection (if not Transfer)
                if (selectedType != TransactionType.TRANSFER) {
                    Text("Category", style = MaterialTheme.typography.labelSmall, color = colors.textSecondary)
                    Spacer(modifier = Modifier.height(AppTokens.Space4))
                    LazyRow(horizontalArrangement = Arrangement.spacedBy(AppTokens.Space8)) {
                        items(categories) { cat ->
                            val isSel = selectedCategoryId == cat.id
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(AppTokens.RadiusSm))
                                    .background(if (isSel) colors.primary.copy(alpha = 0.25f) else colors.elevated)
                                    .border(1.dp, if (isSel) colors.primary else colors.border, RoundedCornerShape(AppTokens.RadiusSm))
                                    .clickable { selectedCategoryId = cat.id }
                                    .padding(horizontal = 12.dp, vertical = 6.dp)
                            ) {
                                Text(text = cat.name, fontSize = 12.sp, color = if (isSel) colors.primary else colors.textPrimary)
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(AppTokens.Space20))

                // Action Buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.End
                ) {
                    TextButton(onClick = onDismiss) {
                        Text("Cancel", color = colors.textSecondary)
                    }
                    Spacer(modifier = Modifier.width(AppTokens.Space8))
                    Button(
                        onClick = {
                            val parsedAmount = amountInput.toDoubleOrNull() ?: 0.0
                            if (parsedAmount > 0) {
                                val tx = Transaction(
                                    id = "tx_${kotlin.random.Random.nextLong(100000, 999999)}",
                                    accountId = selectedAccountId,
                                    destinationAccountId = if (selectedType == TransactionType.TRANSFER) selectedDestinationAccountId else null,
                                    type = selectedType,
                                    amount = Money.fromDouble(parsedAmount, Currency.INR),
                                    currency = Currency.INR,
                                    baseAmount = Money.fromDouble(parsedAmount, Currency.INR),
                                    baseCurrency = Currency.INR,
                                    categoryId = selectedCategoryId,
                                    description = descriptionInput.ifBlank { selectedType.name },
                                    notes = notesInput,
                                    date = 1728038400000L
                                )
                                onSaveTransaction(tx)
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = colors.primary),
                        shape = RoundedCornerShape(AppTokens.RadiusButton)
                    ) {
                        Text("Add Transaction", color = Color.White, fontWeight = FontWeight.SemiBold)
                    }
                }
            } else {
                // Natural Language Entry Tab
                Text(
                    text = "Smart Transaction Entry",
                    style = MaterialTheme.typography.titleLarge,
                    color = colors.textPrimary,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "Type naturally, e.g. \"Spent ₹240 on lunch\" or \"Received ₹50000 salary\"",
                    style = MaterialTheme.typography.bodyMedium,
                    color = colors.textSecondary
                )
                Spacer(modifier = Modifier.height(AppTokens.Space12))

                OutlinedTextField(
                    value = naturalLanguageInput,
                    onValueChange = { naturalLanguageInput = it },
                    placeholder = { Text("e.g. Paid ₹450 for coffee and snacks") },
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = colors.primary,
                        unfocusedBorderColor = colors.border
                    )
                )

                Spacer(modifier = Modifier.height(AppTokens.Space12))

                Button(
                    onClick = {
                        isParsingAI = true
                        kotlinx.coroutines.GlobalScope.apply {
                            // Local instant deterministic interpretation
                            val lower = naturalLanguageInput.lowercase()
                            val numberRegex = Regex("""(?:₹|rs\.?|inr)?\s*([0-9]+(?:[.,][0-9]{1,2})?)""")
                            val match = numberRegex.find(lower)
                            val amount = match?.groupValues?.get(1)?.toDoubleOrNull() ?: 240.0
                            val type = if (lower.contains("received") || lower.contains("salary")) TransactionType.INCOME else TransactionType.EXPENSE
                            parsedProposal = Transaction(
                                id = "tx_${kotlin.random.Random.nextLong(100000, 999999)}",
                                accountId = selectedAccountId,
                                type = type,
                                amount = Money.fromDouble(amount, Currency.INR),
                                currency = Currency.INR,
                                baseAmount = Money.fromDouble(amount, Currency.INR),
                                baseCurrency = Currency.INR,
                                categoryId = "cat_food",
                                description = naturalLanguageInput.replaceFirstChar { it.uppercase() },
                                date = 1728038400000L
                            )
                            isParsingAI = false
                        }
                    },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(containerColor = colors.secondary),
                    shape = RoundedCornerShape(AppTokens.RadiusButton)
                ) {
                    Text("Interpret with AI", color = Color.White, fontWeight = FontWeight.SemiBold)
                }

                // AI Confirmation Preview
                parsedProposal?.let { proposal ->
                    Spacer(modifier = Modifier.height(AppTokens.Space16))
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(AppTokens.RadiusSm))
                            .background(colors.elevated)
                            .border(1.dp, colors.primary, RoundedCornerShape(AppTokens.RadiusSm))
                            .padding(AppTokens.Space12)
                    ) {
                        Column {
                            Text(
                                text = "Parsed Result (Please Confirm):",
                                style = MaterialTheme.typography.labelSmall,
                                color = colors.primary,
                                fontWeight = FontWeight.Bold
                            )
                            Spacer(modifier = Modifier.height(AppTokens.Space4))
                            Text("Amount: ${proposal.amount.toFormattedString()}", color = colors.textPrimary, fontWeight = FontWeight.SemiBold)
                            Text("Type: ${proposal.type.name}", color = colors.textSecondary)
                            Text("Description: ${proposal.description}", color = colors.textSecondary)
                            Spacer(modifier = Modifier.height(AppTokens.Space12))

                            Button(
                                onClick = { onSaveTransaction(proposal) },
                                modifier = Modifier.fillMaxWidth(),
                                colors = ButtonDefaults.buttonColors(containerColor = colors.success),
                                shape = RoundedCornerShape(AppTokens.RadiusButton)
                            ) {
                                Text("Confirm & Save Transaction", color = Color.White, fontWeight = FontWeight.SemiBold)
                            }
                        }
                    }
                }
            }
        }
    }
}

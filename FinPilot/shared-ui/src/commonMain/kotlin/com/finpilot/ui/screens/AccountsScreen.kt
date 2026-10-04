package com.finpilot.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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
import com.finpilot.core.money.Currency
import com.finpilot.core.money.Money
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.AppTypography
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.domain.models.Account
import com.finpilot.domain.models.AccountType
import com.finpilot.ui.components.CurrencyText
import com.finpilot.ui.components.CustomProgressBar
import com.finpilot.ui.components.LiquidCard

@Composable
fun AccountsScreen(
    accounts: List<Account>,
    onAddAccount: (Account) -> Unit,
    modifier: Modifier = Modifier
) {
    val colors = FinPilotTheme.colors
    var showAddDialog by remember { mutableStateOf(false) }

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
                        text = "Accounts & Cards",
                        style = MaterialTheme.typography.headlineLarge,
                        color = colors.textPrimary,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Multi-account financial structure",
                        style = MaterialTheme.typography.labelSmall,
                        color = colors.textSecondary
                    )
                }
                Button(
                    onClick = { showAddDialog = true },
                    shape = RoundedCornerShape(AppTokens.RadiusButton),
                    colors = ButtonDefaults.buttonColors(containerColor = colors.primary)
                ) {
                    Text("+ Add Account", color = Color.White, fontWeight = FontWeight.SemiBold)
                }
            }
        }

        // Group accounts by Assets vs Liabilities
        val assetAccounts = accounts.filter { it.type.isAsset }
        val liabilityAccounts = accounts.filter { it.type.isLiability }

        if (liabilityAccounts.isNotEmpty()) {
            item {
                Text(
                    text = "CREDIT CARDS & LIABILITIES",
                    style = MaterialTheme.typography.labelSmall,
                    color = colors.danger,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                )
            }
            items(liabilityAccounts) { acc ->
                LiquidCard(modifier = Modifier.fillMaxWidth()) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                text = acc.name,
                                style = MaterialTheme.typography.titleLarge,
                                color = colors.textPrimary,
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                text = "${acc.institutionName} ${acc.maskedAccountNumber}",
                                style = MaterialTheme.typography.labelSmall,
                                color = colors.textMuted
                            )
                        }
                        CurrencyText(
                            money = acc.currentBalance,
                            style = AppTypography.CurrencyDisplaySmall,
                            color = colors.danger
                        )
                    }

                    if (acc.creditLimit != null) {
                        Spacer(modifier = Modifier.height(AppTokens.Space12))
                        val util = acc.creditUtilizationPercentage ?: 0.0
                        CustomProgressBar(
                            progressPercentage = util,
                            barColor = if (util > 30.0) colors.danger else colors.secondary
                        )
                        Spacer(modifier = Modifier.height(AppTokens.Space8))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                text = "${util.toInt()}% utilization",
                                style = MaterialTheme.typography.labelSmall,
                                color = if (util > 30.0) colors.danger else colors.secondary
                            )
                            Text(
                                text = "Available: ${(acc.availableCredit ?: Money.zero()).toFormattedString()}",
                                style = MaterialTheme.typography.labelSmall,
                                color = colors.textSecondary
                            )
                        }
                    }
                }
            }
        }

        if (assetAccounts.isNotEmpty()) {
            item {
                Spacer(modifier = Modifier.height(AppTokens.Space8))
                Text(
                    text = "ASSETS & WALLETS",
                    style = MaterialTheme.typography.labelSmall,
                    color = colors.success,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                )
            }
            items(assetAccounts) { acc ->
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
                                    text = if (acc.type == AccountType.BANK) "🏦" else if (acc.type == AccountType.CASH_WALLET) "💵" else "📈",
                                    fontSize = 18.sp
                                )
                            }
                            Spacer(modifier = Modifier.width(AppTokens.Space12))
                            Column {
                                Text(
                                    text = acc.name,
                                    style = MaterialTheme.typography.titleLarge,
                                    color = colors.textPrimary,
                                    fontWeight = FontWeight.SemiBold
                                )
                                Text(
                                    text = "${acc.type.name} • ${acc.maskedAccountNumber.ifBlank { acc.institutionName }}",
                                    style = MaterialTheme.typography.labelSmall,
                                    color = colors.textMuted
                                )
                            }
                        }
                        CurrencyText(
                            money = acc.currentBalance,
                            style = AppTypography.CurrencyDisplaySmall,
                            color = colors.textPrimary
                        )
                    }
                }
            }
        }
    }

    if (showAddDialog) {
        var nameInput by remember { mutableStateOf("") }
        var typeInput by remember { mutableStateOf(AccountType.BANK) }
        var instInput by remember { mutableStateOf("") }
        var balanceInput by remember { mutableStateOf("") }

        androidx.compose.ui.window.Dialog(onDismissRequest = { showAddDialog = false }) {
            LiquidCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(AppTokens.Space16),
                cornerRadius = AppTokens.RadiusDialog
            ) {
                Text(
                    text = "New Financial Account",
                    style = MaterialTheme.typography.headlineMedium,
                    color = colors.textPrimary,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(AppTokens.Space16))

                OutlinedTextField(
                    value = nameInput,
                    onValueChange = { nameInput = it },
                    label = { Text("Account Name") },
                    placeholder = { Text("e.g. HDFC Salary, SBI FD, Cash") },
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(AppTokens.Space12))

                OutlinedTextField(
                    value = instInput,
                    onValueChange = { instInput = it },
                    label = { Text("Institution Name") },
                    placeholder = { Text("e.g. State Bank of India") },
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(AppTokens.Space12))

                OutlinedTextField(
                    value = balanceInput,
                    onValueChange = { balanceInput = it },
                    label = { Text("Opening Balance (₹)") },
                    placeholder = { Text("0.00") },
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(AppTokens.Space20))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.End
                ) {
                    TextButton(onClick = { showAddDialog = false }) {
                        Text("Cancel", color = colors.textSecondary)
                    }
                    Spacer(modifier = Modifier.width(AppTokens.Space8))
                    Button(
                        onClick = {
                            val bal = balanceInput.toDoubleOrNull() ?: 0.0
                            val newAcc = Account(
                                id = "acc_${kotlin.random.Random.nextLong(100000, 999999)}",
                                name = nameInput.ifBlank { "Account" },
                                type = typeInput,
                                institutionName = instInput,
                                currency = Currency.INR,
                                openingBalance = Money.fromDouble(bal, Currency.INR),
                                currentBalance = Money.fromDouble(bal, Currency.INR)
                            )
                            onAddAccount(newAcc)
                            showAddDialog = false
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = colors.primary)
                    ) {
                        Text("Create Account", color = Color.White)
                    }
                }
            }
        }
    }
}

package com.finpilot.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.ui.components.LiquidCard

@Composable
fun GoogleSheetsScreen(
    isConnected: Boolean,
    onConnectGoogle: () -> Unit,
    onDisconnectGoogle: () -> Unit,
    onSyncNow: () -> Unit,
    modifier: Modifier = Modifier
) {
    val colors = FinPilotTheme.colors
    var exportTx by remember { mutableStateOf(true) }
    var exportAccounts by remember { mutableStateOf(true) }
    var exportBudgets by remember { mutableStateOf(true) }
    var exportGoals by remember { mutableStateOf(true) }
    var exportSubs by remember { mutableStateOf(true) }
    var lastSyncStatus by remember { mutableStateOf<String?>(null) }

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
                text = "Google Sheets Integration",
                style = MaterialTheme.typography.headlineLarge,
                color = colors.textPrimary,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "Voluntary cloud export to your personal Google Drive spreadsheet",
                style = MaterialTheme.typography.labelSmall,
                color = colors.textSecondary
            )
        }

        // Connection Status Card
        item {
            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = "INTEGRATION STATUS",
                            style = MaterialTheme.typography.labelSmall,
                            color = colors.textSecondary,
                            letterSpacing = 1.sp
                        )
                        Spacer(modifier = Modifier.height(AppTokens.Space4))
                        Text(
                            text = if (isConnected) "Connected ✓" else "Not Connected",
                            style = MaterialTheme.typography.headlineMedium,
                            color = if (isConnected) colors.success else colors.textPrimary,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    Button(
                        onClick = { if (isConnected) onDisconnectGoogle() else onConnectGoogle() },
                        colors = ButtonDefaults.buttonColors(containerColor = if (isConnected) colors.danger else colors.primary),
                        shape = RoundedCornerShape(AppTokens.RadiusButton)
                    ) {
                        Text(if (isConnected) "Disconnect" else "Connect Google Account", color = Color.White)
                    }
                }

                if (isConnected) {
                    Spacer(modifier = Modifier.height(AppTokens.Space12))
                    Text("Target Spreadsheet: FinPilot Finance 2026", color = colors.textPrimary, fontWeight = FontWeight.SemiBold)
                    Text("Last Synced: 04 Oct 2026, 12:20 PM", color = colors.textMuted, fontSize = 12.sp)

                    Spacer(modifier = Modifier.height(AppTokens.Space16))
                    Button(
                        onClick = {
                            onSyncNow()
                            lastSyncStatus = "Spreadsheet updated successfully with 8 sheets!"
                        },
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(containerColor = colors.success),
                        shape = RoundedCornerShape(AppTokens.RadiusButton)
                    ) {
                        Text("↻ Sync Now", color = Color.White, fontWeight = FontWeight.Bold)
                    }

                    lastSyncStatus?.let { status ->
                        Spacer(modifier = Modifier.height(AppTokens.Space8))
                        Text(status, color = colors.success, fontSize = 12.sp)
                    }
                }
            }
        }

        // Export Selection Options
        item {
            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Configure Sheets to Export",
                    style = MaterialTheme.typography.titleLarge,
                    color = colors.textPrimary,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(AppTokens.Space12))

                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = exportTx, onCheckedChange = { exportTx = it })
                    Text("Transactions (Income & Expenses)", color = colors.textPrimary)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = exportAccounts, onCheckedChange = { exportAccounts = it })
                    Text("Accounts & Credit Cards", color = colors.textPrimary)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = exportBudgets, onCheckedChange = { exportBudgets = it })
                    Text("Budgets & Limits", color = colors.textPrimary)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = exportGoals, onCheckedChange = { exportGoals = it })
                    Text("Savings Goals", color = colors.textPrimary)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = exportSubs, onCheckedChange = { exportSubs = it })
                    Text("Subscriptions & Recurring", color = colors.textPrimary)
                }
            }
        }
    }
}

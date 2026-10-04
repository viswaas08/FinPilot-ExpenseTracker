package com.finpilot.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.finpilot.core.money.Currency
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.ui.components.LiquidCard

@Composable
fun SettingsScreen(
    currentCurrency: Currency,
    onCurrencyChange: (Currency) -> Unit,
    isDarkTheme: Boolean,
    onThemeToggle: () -> Unit,
    isBiometricEnabled: Boolean,
    onBiometricToggle: () -> Unit,
    onExportData: (String) -> Unit,
    onDeleteAccount: () -> Unit,
    onSignOut: () -> Unit,
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
                text = "Settings & Privacy",
                style = MaterialTheme.typography.headlineLarge,
                color = colors.textPrimary,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "Preferences, security, and data ownership",
                style = MaterialTheme.typography.labelSmall,
                color = colors.textSecondary
            )
        }

        // Multi-Currency Selection (Section 20)
        item {
            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Base Currency",
                    style = MaterialTheme.typography.titleLarge,
                    color = colors.textPrimary,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "Default currency for calculations and dashboard metrics (Default: ₹ INR)",
                    style = MaterialTheme.typography.labelSmall,
                    color = colors.textMuted
                )
                Spacer(modifier = Modifier.height(AppTokens.Space12))

                LazyRow(horizontalArrangement = Arrangement.spacedBy(AppTokens.Space8)) {
                    items(Currency.entries) { curr ->
                        val isSel = currentCurrency == curr
                        FilterChip(
                            selected = isSel,
                            onClick = { onCurrencyChange(curr) },
                            label = { Text("${curr.symbol} ${curr.code}") }
                        )
                    }
                }
            }
        }

        // Appearance & Security
        item {
            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "App Preferences",
                    style = MaterialTheme.typography.titleLarge,
                    color = colors.textPrimary,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(AppTokens.Space12))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("Dark Mode", color = colors.textPrimary, fontWeight = FontWeight.SemiBold)
                        Text("Sleek fintech slate interface", style = MaterialTheme.typography.labelSmall, color = colors.textMuted)
                    }
                    Switch(checked = isDarkTheme, onCheckedChange = { onThemeToggle() })
                }

                Divider(color = colors.border.copy(alpha = 0.5f), modifier = Modifier.padding(vertical = AppTokens.Space12))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("Biometric / PIN Lock", color = colors.textPrimary, fontWeight = FontWeight.SemiBold)
                        Text("Fingerprint, Face ID, or system PIN", style = MaterialTheme.typography.labelSmall, color = colors.textMuted)
                    }
                    Switch(checked = isBiometricEnabled, onCheckedChange = { onBiometricToggle() })
                }
            }
        }

        // Data Export & Ownership (Section 28, 52)
        item {
            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Data Ownership & Portability",
                    style = MaterialTheme.typography.titleLarge,
                    color = colors.textPrimary,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "Your financial data belongs to you. Export or purge at any time.",
                    style = MaterialTheme.typography.labelSmall,
                    color = colors.textMuted
                )
                Spacer(modifier = Modifier.height(AppTokens.Space16))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(AppTokens.Space12)
                ) {
                    Button(
                        onClick = { onExportData("CSV") },
                        modifier = Modifier.weight(1f),
                        colors = ButtonDefaults.buttonColors(containerColor = colors.elevated),
                        shape = RoundedCornerShape(AppTokens.RadiusButton)
                    ) {
                        Text("Export CSV", color = colors.textPrimary)
                    }
                    Button(
                        onClick = { onExportData("JSON") },
                        modifier = Modifier.weight(1f),
                        colors = ButtonDefaults.buttonColors(containerColor = colors.elevated),
                        shape = RoundedCornerShape(AppTokens.RadiusButton)
                    ) {
                        Text("Export JSON", color = colors.textPrimary)
                    }
                }
            }
        }

        // Danger Zone: Sign Out & Delete Account
        item {
            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Account Actions",
                    style = MaterialTheme.typography.titleLarge,
                    color = colors.danger,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(AppTokens.Space16))

                Button(
                    onClick = onSignOut,
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(containerColor = colors.elevated),
                    shape = RoundedCornerShape(AppTokens.RadiusButton)
                ) {
                    Text("Sign Out", color = colors.textPrimary)
                }

                Spacer(modifier = Modifier.height(AppTokens.Space8))

                Button(
                    onClick = onDeleteAccount,
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(containerColor = colors.danger),
                    shape = RoundedCornerShape(AppTokens.RadiusButton)
                ) {
                    Text("Delete Account & Cloud Data", color = Color.White, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

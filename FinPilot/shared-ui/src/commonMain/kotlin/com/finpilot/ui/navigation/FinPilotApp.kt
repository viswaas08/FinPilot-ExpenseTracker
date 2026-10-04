package com.finpilot.ui.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
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
import com.finpilot.ai.AIRepositoryImpl
import com.finpilot.auth.AuthServiceImpl
import com.finpilot.auth.BiometricLockManager
import com.finpilot.core.money.Currency
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.data.repositories.*
import com.finpilot.domain.models.*
import com.finpilot.domain.usecases.*
import com.finpilot.sheets.GoogleSheetsServiceImpl
import com.finpilot.sync.MemoryNetworkMonitor
import com.finpilot.sync.SyncEngine
import com.finpilot.sync.SyncState
import com.finpilot.ui.screens.*
import kotlinx.coroutines.launch

enum class AppDestination(val label: String, val icon: String) {
    DASHBOARD("Overview", "📊"),
    ACCOUNTS("Accounts", "💳"),
    TRANSACTIONS("Transactions", "📜"),
    BUDGETS("Budgets", "🎯"),
    GOALS("Goals", "🏆"),
    SUBSCRIPTIONS("Subscriptions", "🔄"),
    ANALYTICS("Analytics", "📈"),
    AI_ADVISOR("AI Advisor", "✦"),
    SHEETS("Google Sheets", "📑"),
    SETTINGS("Settings", "⚙")
}

@Composable
fun FinPilotApp() {
    var isDarkTheme by remember { mutableStateOf(true) }
    var currentCurrency by remember { mutableStateOf(Currency.INR) }

    FinPilotTheme(darkTheme = isDarkTheme) {
        val colors = FinPilotTheme.colors
        val scope = rememberCoroutineScope()

        // Core Repositories & Engine instances
        val networkMonitor = remember { MemoryNetworkMonitor(true) }
        val syncEngine = remember { SyncEngine(networkMonitor, scope) }
        val accountRepo = remember { AccountRepositoryImpl() }
        val txRepo = remember { TransactionRepositoryImpl() }
        val catRepo = remember { CategoryRepositoryImpl() }
        val budgetRepo = remember { BudgetRepositoryImpl() }
        val goalRepo = remember { SavingsGoalRepositoryImpl() }
        val subRepo = remember { SubscriptionRepositoryImpl() }
        val authRepo = remember { AuthServiceImpl() }
        val aiRepo = remember { AIRepositoryImpl() }
        val sheetsRepo = remember { GoogleSheetsServiceImpl() }

        // Use Cases
        val addTxUseCase = remember { AddTransactionUseCase(txRepo, accountRepo) }
        val getDashboardUseCase = remember { GetDashboardDataUseCase(accountRepo, txRepo, catRepo) }
        val calculateNetWorthUseCase = remember { CalculateNetWorthUseCase(accountRepo) }
        val naturalLanguageTxUseCase = remember { NaturalLanguageTransactionUseCase(aiRepo) }

        // Reactive State Collections
        val authUser by authRepo.currentUserFlow.collectAsState(initial = null)
        val syncState by syncEngine.syncState.collectAsState(initial = SyncState.Synced)
        val accounts by accountRepo.getAccountsFlow().collectAsState(initial = emptyList())
        val transactions by txRepo.getTransactionsFlow(100).collectAsState(initial = emptyList())
        val categories by catRepo.getCategoriesFlow().collectAsState(initial = emptyList())
        val budgets by budgetRepo.getBudgetsFlow().collectAsState(initial = emptyList())
        val goals by goalRepo.getGoalsFlow().collectAsState(initial = emptyList())
        val subscriptions by subRepo.getSubscriptionsFlow().collectAsState(initial = emptyList())
        val isSheetsConnected by sheetsRepo.isConnectedFlow.collectAsState(initial = false)

        val dashboardData by getDashboardUseCase(currentCurrency).collectAsState(
            initial = DashboardData(
                totalBalance = com.finpilot.core.money.Money.zero(currentCurrency),
                income = com.finpilot.core.money.Money.zero(currentCurrency),
                expenses = com.finpilot.core.money.Money.zero(currentCurrency),
                savings = com.finpilot.core.money.Money.zero(currentCurrency),
                savingsRatePercentage = 0.0,
                currency = currentCurrency
            )
        )
        val netWorth by calculateNetWorthUseCase(currentCurrency).collectAsState(
            initial = NetWorth.zero(currentCurrency)
        )

        var currentDestination by remember { mutableStateOf(AppDestination.DASHBOARD) }
        var showAddTxDialog by remember { mutableStateOf(false) }

        if (authUser == null) {
            AuthScreen(
                onGoogleSignIn = {
                    scope.launch { authRepo.signInWithGoogle("mock_token_id") }
                },
                onEmailSignIn = { email, pass ->
                    scope.launch { authRepo.signInWithEmail(email, pass) }
                }
            )
        } else {
            // Main Responsive Shell: Sidebar for desktop / tablet, Bottom bar for mobile
            BoxWithConstraints(modifier = Modifier.fillMaxSize().background(colors.background)) {
                val isDesktop = maxWidth >= 840.dp

                Row(modifier = Modifier.fillMaxSize()) {
                    if (isDesktop) {
                        // Desktop Sidebar
                        Column(
                            modifier = Modifier
                                .width(240.dp)
                                .fillMaxHeight()
                                .background(colors.surface)
                                .padding(AppTokens.Space16)
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Box(
                                    modifier = Modifier
                                        .size(36.dp)
                                        .clip(CircleShape)
                                        .background(colors.primary.copy(alpha = 0.2f)),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text("💎", fontSize = 18.sp)
                                }
                                Spacer(modifier = Modifier.width(AppTokens.Space12))
                                Column {
                                    Text("FinPilot 2.0", color = colors.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                                    Text("Control Center", color = colors.textMuted, fontSize = 11.sp)
                                }
                            }

                            Spacer(modifier = Modifier.height(AppTokens.Space24))

                            AppDestination.entries.forEach { dest ->
                                val isSelected = currentDestination == dest
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clip(RoundedCornerShape(AppTokens.RadiusSm))
                                        .background(if (isSelected) colors.primary.copy(alpha = 0.15f) else Color.Transparent)
                                        .clickable { currentDestination = dest }
                                        .padding(horizontal = 12.dp, vertical = 10.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(dest.icon, fontSize = 16.sp)
                                    Spacer(modifier = Modifier.width(AppTokens.Space12))
                                    Text(
                                        text = dest.label,
                                        color = if (isSelected) colors.primary else colors.textSecondary,
                                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                                        fontSize = 14.sp
                                    )
                                }
                                Spacer(modifier = Modifier.height(2.dp))
                            }

                            Spacer(modifier = Modifier.weight(1f))

                            Button(
                                onClick = { showAddTxDialog = true },
                                modifier = Modifier.fillMaxWidth(),
                                shape = RoundedCornerShape(AppTokens.RadiusButton),
                                colors = ButtonDefaults.buttonColors(containerColor = colors.primary)
                            ) {
                                Text("+ Transaction", color = Color.White, fontWeight = FontWeight.Bold)
                            }
                        }
                    }

                    // Main Content Canvas
                    Scaffold(
                        modifier = Modifier.weight(1f),
                        containerColor = colors.background,
                        bottomBar = {
                            if (!isDesktop) {
                                NavigationBar(
                                    containerColor = colors.surface,
                                    tonalElevation = 0.dp
                                ) {
                                    listOf(
                                        AppDestination.DASHBOARD,
                                        AppDestination.ACCOUNTS,
                                        AppDestination.TRANSACTIONS,
                                        AppDestination.AI_ADVISOR,
                                        AppDestination.SETTINGS
                                    ).forEach { dest ->
                                        NavigationBarItem(
                                            selected = currentDestination == dest,
                                            onClick = { currentDestination = dest },
                                            icon = { Text(dest.icon, fontSize = 18.sp) },
                                            label = { Text(dest.label, fontSize = 10.sp) }
                                        )
                                    }
                                }
                            }
                        },
                        floatingActionButton = {
                            if (!isDesktop) {
                                FloatingActionButton(
                                    onClick = { showAddTxDialog = true },
                                    containerColor = colors.primary,
                                    shape = CircleShape
                                ) {
                                    Text("+", color = Color.White, fontSize = 24.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                        }
                    ) { innerPadding ->
                        Box(modifier = Modifier.fillMaxSize().padding(innerPadding)) {
                            when (currentDestination) {
                                AppDestination.DASHBOARD -> DashboardScreen(
                                    dashboardData = dashboardData,
                                    syncState = syncState,
                                    onAddTransactionClick = { showAddTxDialog = true },
                                    onViewAllTransactions = { currentDestination = AppDestination.TRANSACTIONS },
                                    onAccountClick = { currentDestination = AppDestination.ACCOUNTS },
                                    onInsightActionClick = { currentDestination = AppDestination.AI_ADVISOR }
                                )
                                AppDestination.ACCOUNTS -> AccountsScreen(
                                    accounts = accounts,
                                    onAddAccount = { scope.launch { accountRepo.createAccount(it) } }
                                )
                                AppDestination.TRANSACTIONS -> TransactionsScreen(
                                    transactions = transactions,
                                    onAddTransaction = { showAddTxDialog = true }
                                )
                                AppDestination.BUDGETS -> BudgetsScreen(
                                    budgets = budgets,
                                    onAddBudget = {}
                                )
                                AppDestination.GOALS -> SavingsGoalsScreen(
                                    goals = goals,
                                    onAddGoal = {}
                                )
                                AppDestination.SUBSCRIPTIONS -> SubscriptionsScreen(
                                    subscriptions = subscriptions,
                                    onToggleStatus = { sub ->
                                        scope.launch {
                                            val newStatus = if (sub.status == SubscriptionStatus.ACTIVE) SubscriptionStatus.PAUSED else SubscriptionStatus.ACTIVE
                                            subRepo.saveSubscription(sub.copy(status = newStatus))
                                        }
                                    }
                                )
                                AppDestination.ANALYTICS -> AnalyticsScreen(
                                    dashboardData = dashboardData,
                                    netWorth = netWorth
                                )
                                AppDestination.AI_ADVISOR -> {
                                    val healthScore = FinancialHealthScore(
                                        score = 88,
                                        rating = "Excellent",
                                        savingsRateWeight = 35.0,
                                        debtToIncomeWeight = 22.0,
                                        budgetAdherenceWeight = 18.0,
                                        emergencyRunwayMonths = 4.8,
                                        aiExplanation = "Your financial health is strong with an 88/100 score. You maintain a high 65% savings rate and have an emergency fund covering nearly 5 months of living expenses."
                                    )
                                    AIAdvisorScreen(
                                        healthScore = healthScore,
                                        onAskAI = { aiRepo.askAssistant(it).getOrNull() ?: "Cash flow remains steady." }
                                    )
                                }
                                AppDestination.SHEETS -> GoogleSheetsScreen(
                                    isConnected = isSheetsConnected,
                                    onConnectGoogle = { scope.launch { sheetsRepo.exchangeAuthCode("mock_code") } },
                                    onDisconnectGoogle = { scope.launch { sheetsRepo.disconnect() } },
                                    onSyncNow = { scope.launch { sheetsRepo.syncSpreadsheet(com.finpilot.domain.repositories.GoogleSheetsExportRequest()) } }
                                )
                                AppDestination.SETTINGS -> SettingsScreen(
                                    currentCurrency = currentCurrency,
                                    onCurrencyChange = { currentCurrency = it },
                                    isDarkTheme = isDarkTheme,
                                    onThemeToggle = { isDarkTheme = !isDarkTheme },
                                    isBiometricEnabled = BiometricLockManager.isBiometricEnabled,
                                    onBiometricToggle = { BiometricLockManager.isBiometricEnabled = !BiometricLockManager.isBiometricEnabled },
                                    onExportData = { format ->
                                        // Trigger CSV/JSON export
                                    },
                                    onDeleteAccount = { scope.launch { authRepo.deleteAccount() } },
                                    onSignOut = { scope.launch { authRepo.signOut() } }
                                )
                            }
                        }
                    }
                }

                // Add Transaction Modal
                if (showAddTxDialog) {
                    AddTransactionDialog(
                        accounts = accounts,
                        categories = categories,
                        onDismiss = { showAddTxDialog = false },
                        onSaveTransaction = { tx ->
                            scope.launch {
                                addTxUseCase(tx)
                                syncEngine.enqueueMutation("TRANSACTION", tx.id, "INSERT")
                                showAddTxDialog = false
                            }
                        },
                        onParseNaturalLanguage = { text, accId ->
                            naturalLanguageTxUseCase(text, accId).getOrNull()
                        }
                    )
                }
            }
        }
    }
}

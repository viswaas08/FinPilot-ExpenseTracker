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
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.domain.models.FinancialHealthScore
import com.finpilot.ui.components.CustomProgressBar
import com.finpilot.ui.components.LiquidCard

data class ChatMessage(val isUser: Boolean, val text: String)

@Composable
fun AIAdvisorScreen(
    healthScore: FinancialHealthScore,
    onAskAI: suspend (String) -> String,
    modifier: Modifier = Modifier
) {
    val colors = FinPilotTheme.colors
    var promptInput by remember { mutableStateOf("") }
    var chatMessages by remember {
        mutableStateOf(
            listOf(
                ChatMessage(false, "Hello! I am your FinPilot Gemini AI financial advisor. How can I help you analyze your spending or optimize your cash flow today?")
            )
        )
    }
    var isThinking by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

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
                text = "Gemini AI Advisor",
                style = MaterialTheme.typography.headlineLarge,
                color = colors.textPrimary,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "Deterministic health scoring & conversational financial intelligence",
                style = MaterialTheme.typography.labelSmall,
                color = colors.textSecondary
            )
        }

        // Financial Health Score Gauge Card
        item {
            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = "FINANCIAL HEALTH SCORE",
                            style = MaterialTheme.typography.labelSmall,
                            color = colors.primary,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 1.sp
                        )
                        Spacer(modifier = Modifier.height(AppTokens.Space4))
                        Text(
                            text = healthScore.rating,
                            style = MaterialTheme.typography.headlineMedium,
                            color = colors.textPrimary,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    Box(
                        modifier = Modifier
                            .size(64.dp)
                            .clip(CircleShape)
                            .background(colors.primary.copy(alpha = 0.2f))
                            .border(2.dp, colors.primary, CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "${healthScore.score}",
                            fontSize = 22.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = colors.primary
                        )
                    }
                }

                Spacer(modifier = Modifier.height(AppTokens.Space16))
                Text(
                    text = healthScore.aiExplanation,
                    style = MaterialTheme.typography.bodyMedium,
                    color = colors.textSecondary
                )

                Spacer(modifier = Modifier.height(AppTokens.Space16))
                Divider(color = colors.border.copy(alpha = 0.5f))
                Spacer(modifier = Modifier.height(AppTokens.Space12))

                // Score Component Weights
                Text("Component Breakdown", style = MaterialTheme.typography.labelSmall, color = colors.textMuted)
                Spacer(modifier = Modifier.height(AppTokens.Space8))

                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("Savings Rate (35%)", fontSize = 12.sp, color = colors.textSecondary)
                    Text("${healthScore.savingsRateWeight.toInt()}%", fontSize = 12.sp, color = colors.success)
                }
                CustomProgressBar(progressPercentage = 95.0, barColor = colors.success)
                Spacer(modifier = Modifier.height(6.dp))

                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("Debt-to-Income (30%)", fontSize = 12.sp, color = colors.textSecondary)
                    Text("${healthScore.debtToIncomeWeight.toInt()}%", fontSize = 12.sp, color = colors.secondary)
                }
                CustomProgressBar(progressPercentage = 75.0, barColor = colors.secondary)
                Spacer(modifier = Modifier.height(6.dp))

                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("Emergency Runway", fontSize = 12.sp, color = colors.textSecondary)
                    Text("${healthScore.emergencyRunwayMonths} Months", fontSize = 12.sp, color = colors.primary)
                }
                CustomProgressBar(progressPercentage = 80.0, barColor = colors.primary)
            }
        }

        // Suggested Prompts
        item {
            Text(
                text = "Quick Queries",
                style = MaterialTheme.typography.labelSmall,
                color = colors.textSecondary
            )
            Spacer(modifier = Modifier.height(AppTokens.Space8))
            val suggestions = listOf(
                "How much did I spend on food this month?",
                "How much can I save this month?",
                "What subscriptions am I paying for?"
            )
            Column(verticalArrangement = Arrangement.spacedBy(AppTokens.Space8)) {
                suggestions.forEach { prompt ->
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(AppTokens.RadiusSm))
                            .background(colors.elevated)
                            .border(1.dp, colors.border, RoundedCornerShape(AppTokens.RadiusSm))
                            .clickable {
                                promptInput = prompt
                            }
                            .padding(horizontal = 12.dp, vertical = 8.dp)
                    ) {
                        Text(text = "✦ $prompt", fontSize = 13.sp, color = colors.textPrimary)
                    }
                }
            }
        }

        // Chat Interaction Area
        item {
            LiquidCard(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Grounded Financial Assistant",
                    style = MaterialTheme.typography.titleLarge,
                    color = colors.textPrimary,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(AppTokens.Space12))

                chatMessages.forEach { msg ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp),
                        horizontalArrangement = if (msg.isUser) Arrangement.End else Arrangement.Start
                    ) {
                        Box(
                            modifier = Modifier
                                .widthIn(max = 280.dp)
                                .clip(RoundedCornerShape(AppTokens.RadiusButton))
                                .background(if (msg.isUser) colors.primary else colors.elevated)
                                .padding(12.dp)
                        ) {
                            Text(
                                text = msg.text,
                                style = MaterialTheme.typography.bodyMedium,
                                color = if (msg.isUser) Color.White else colors.textPrimary
                            )
                        }
                    }
                }

                if (isThinking) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("✦ Gemini is analyzing your financial records...", color = colors.secondary, fontSize = 12.sp)
                }

                Spacer(modifier = Modifier.height(AppTokens.Space16))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedTextField(
                        value = promptInput,
                        onValueChange = { promptInput = it },
                        placeholder = { Text("Ask about your finances...") },
                        singleLine = true,
                        modifier = Modifier.weight(1f),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = colors.primary,
                            unfocusedBorderColor = colors.border
                        )
                    )
                    Spacer(modifier = Modifier.width(AppTokens.Space8))
                    Button(
                        onClick = {
                            val text = promptInput.trim()
                            if (text.isNotEmpty() && !isThinking) {
                                chatMessages = chatMessages + ChatMessage(true, text)
                                promptInput = ""
                                isThinking = true
                                kotlinx.coroutines.GlobalScope.apply {
                                    val reply = onAskAI(text)
                                    chatMessages = chatMessages + ChatMessage(false, reply)
                                    isThinking = false
                                }
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = colors.primary),
                        shape = RoundedCornerShape(AppTokens.RadiusButton)
                    ) {
                        Text("Ask", color = Color.White)
                    }
                }

                Spacer(modifier = Modifier.height(AppTokens.Space8))
                Text(
                    text = "Disclaimer: AI insights are informational and not certified financial advice.",
                    style = MaterialTheme.typography.labelSmall,
                    color = colors.textMuted
                )
            }
        }
    }
}

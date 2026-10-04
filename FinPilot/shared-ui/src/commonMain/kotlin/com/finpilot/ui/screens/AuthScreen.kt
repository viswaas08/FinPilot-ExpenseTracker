package com.finpilot.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.ui.components.LiquidCard

@Composable
fun AuthScreen(
    onGoogleSignIn: () -> Unit,
    onEmailSignIn: (String, String) -> Unit,
    modifier: Modifier = Modifier
) {
    val colors = FinPilotTheme.colors
    var emailInput by remember { mutableStateOf("") }
    var passwordInput by remember { mutableStateOf("") }
    var showEmailForm by remember { mutableStateOf(false) }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(colors.background),
        contentAlignment = Alignment.Center
    ) {
        LiquidCard(
            modifier = Modifier
                .widthIn(max = 420.dp)
                .padding(AppTokens.Space24),
            cornerRadius = AppTokens.RadiusDialog
        ) {
            Box(
                modifier = Modifier
                    .size(64.dp)
                    .clip(CircleShape)
                    .background(colors.primary.copy(alpha = 0.2f))
                    .border(2.dp, colors.primary, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Text("💎", fontSize = 28.sp)
            }

            Spacer(modifier = Modifier.height(AppTokens.Space16))

            Text(
                text = "FinPilot 2.0",
                style = MaterialTheme.typography.displayMedium,
                color = colors.textPrimary,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "Your money. Your control.",
                style = MaterialTheme.typography.headlineMedium,
                color = colors.primary,
                fontWeight = FontWeight.SemiBold
            )
            Spacer(modifier = Modifier.height(AppTokens.Space8))
            Text(
                text = "Autonomous personal finance operating system with offline-first synchronization and Gemini intelligence.",
                style = MaterialTheme.typography.bodyMedium,
                color = colors.textSecondary
            )

            Spacer(modifier = Modifier.height(AppTokens.Space24))

            Button(
                onClick = onGoogleSignIn,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(AppTokens.RadiusButton),
                colors = ButtonDefaults.buttonColors(containerColor = colors.elevated)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("G", fontWeight = FontWeight.Bold, color = colors.primary, fontSize = 16.sp)
                    Spacer(modifier = Modifier.width(AppTokens.Space12))
                    Text("Continue with Google", color = colors.textPrimary, fontWeight = FontWeight.SemiBold)
                }
            }

            Spacer(modifier = Modifier.height(AppTokens.Space12))

            if (!showEmailForm) {
                OutlinedButton(
                    onClick = { showEmailForm = true },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(AppTokens.RadiusButton),
                    border = androidx.compose.foundation.BorderStroke(1.dp, colors.border)
                ) {
                    Text("Continue with Email", color = colors.textPrimary)
                }
            } else {
                OutlinedTextField(
                    value = emailInput,
                    onValueChange = { emailInput = it },
                    label = { Text("Email address") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(AppTokens.Space8))
                OutlinedTextField(
                    value = passwordInput,
                    onValueChange = { passwordInput = it },
                    label = { Text("Password") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(AppTokens.Space12))
                Button(
                    onClick = { onEmailSignIn(emailInput, passwordInput) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(AppTokens.RadiusButton),
                    colors = ButtonDefaults.buttonColors(containerColor = colors.primary)
                ) {
                    Text("Sign In / Register", color = Color.White)
                }
            }

            Spacer(modifier = Modifier.height(AppTokens.Space20))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center
            ) {
                Text(
                    text = "Privacy Policy • Terms of Service",
                    style = MaterialTheme.typography.labelSmall,
                    color = colors.textMuted
                )
            }
        }
    }
}

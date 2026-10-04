package com.finpilot.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.finpilot.core.money.Money
import com.finpilot.core.theme.AppTokens
import com.finpilot.core.theme.AppTypography
import com.finpilot.core.theme.FinPilotTheme
import com.finpilot.sync.SyncState

@Composable
fun LiquidCard(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = AppTokens.RadiusCard,
    onClick: (() -> Unit)? = null,
    content: @Composable ColumnScope.() -> Unit
) {
    val colors = FinPilotTheme.colors
    val shape = RoundedCornerShape(cornerRadius)
    val cardModifier = if (onClick != null) {
        modifier.clip(shape).clickable(onClick = onClick)
    } else {
        modifier.clip(shape)
    }

    val gradient = if (colors.isDark) {
        Brush.linearGradient(
            listOf(colors.surface.copy(alpha = 0.95f), colors.elevated.copy(alpha = 0.85f))
        )
    } else {
        Brush.linearGradient(
            listOf(colors.surface, colors.elevated)
        )
    }

    Box(
        modifier = cardModifier
            .background(brush = gradient, shape = shape)
            .border(1.dp, colors.border, shape = shape)
            .padding(AppTokens.Space16)
    ) {
        Column(content = content)
    }
}

@Composable
fun CurrencyText(
    money: Money,
    style: androidx.compose.ui.text.TextStyle = AppTypography.CurrencyDisplayMedium,
    color: Color = FinPilotTheme.colors.textPrimary,
    includeSymbol: Boolean = true
) {
    Text(
        text = money.toFormattedString(includeSymbol),
        style = style,
        color = color,
        fontWeight = FontWeight.Bold
    )
}

@Composable
fun StatCard(
    title: String,
    money: Money,
    subtitle: String? = null,
    trendPositive: Boolean? = null,
    accentColor: Color = FinPilotTheme.colors.primary,
    modifier: Modifier = Modifier
) {
    LiquidCard(modifier = modifier) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.labelSmall,
                color = FinPilotTheme.colors.textSecondary,
                letterSpacing = 0.5.sp
            )
            Box(
                modifier = Modifier
                    .size(8.dp)
                    .background(accentColor, CircleShape)
            )
        }
        Spacer(modifier = Modifier.height(AppTokens.Space8))
        CurrencyText(
            money = money,
            style = AppTypography.CurrencyDisplaySmall,
            color = accentColor
        )
        if (subtitle != null) {
            Spacer(modifier = Modifier.height(AppTokens.Space4))
            Text(
                text = subtitle,
                style = MaterialTheme.typography.labelSmall,
                color = if (trendPositive == true) FinPilotTheme.colors.success else if (trendPositive == false) FinPilotTheme.colors.danger else FinPilotTheme.colors.textMuted
            )
        }
    }
}

@Composable
fun SyncBadge(syncState: SyncState, modifier: Modifier = Modifier) {
    val (label, bg, fg) = when (syncState) {
        is SyncState.Synced -> Triple("✓ Synced", Color(0x2622C55E), FinPilotTheme.colors.success)
        is SyncState.Syncing -> Triple("↻ Syncing...", Color(0x2638BDF8), FinPilotTheme.colors.secondary)
        is SyncState.Offline -> Triple("○ Offline", Color(0x2664748B), FinPilotTheme.colors.textMuted)
        is SyncState.Failed -> Triple("⚠ Sync failed", Color(0x26EF4444), FinPilotTheme.colors.danger)
    }

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(AppTokens.RadiusPill))
            .background(bg)
            .border(1.dp, fg.copy(alpha = 0.3f), RoundedCornerShape(AppTokens.RadiusPill))
            .padding(horizontal = 10.dp, vertical = 4.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            fontSize = 11.sp,
            fontWeight = FontWeight.Medium,
            color = fg
        )
    }
}

@Composable
fun CustomProgressBar(
    progressPercentage: Double,
    modifier: Modifier = Modifier,
    barColor: Color = FinPilotTheme.colors.primary,
    trackColor: Color = FinPilotTheme.colors.border,
    height: Dp = 6.dp
) {
    val progressClamped = (progressPercentage / 100.0).coerceIn(0.0, 1.0).toFloat()
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(height)
            .clip(RoundedCornerShape(AppTokens.RadiusPill))
            .background(trackColor)
    ) {
        Box(
            modifier = Modifier
                .fillMaxHeight()
                .fillMaxWidth(fraction = progressClamped)
                .clip(RoundedCornerShape(AppTokens.RadiusPill))
                .background(barColor)
        )
    }
}

@Composable
fun EmptyStateView(
    title: String,
    message: String,
    actionButtonText: String? = null,
    onActionClick: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(AppTokens.Space32),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Box(
            modifier = Modifier
                .size(56.dp)
                .clip(CircleShape)
                .background(FinPilotTheme.colors.elevated)
                .border(1.dp, FinPilotTheme.colors.border, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Text(text = "✦", fontSize = 24.sp, color = FinPilotTheme.colors.primary)
        }
        Spacer(modifier = Modifier.height(AppTokens.Space16))
        Text(
            text = title,
            style = MaterialTheme.typography.headlineMedium,
            color = FinPilotTheme.colors.textPrimary,
            fontWeight = FontWeight.SemiBold
        )
        Spacer(modifier = Modifier.height(AppTokens.Space8))
        Text(
            text = message,
            style = MaterialTheme.typography.bodyMedium,
            color = FinPilotTheme.colors.textSecondary
        )
        if (actionButtonText != null && onActionClick != null) {
            Spacer(modifier = Modifier.height(AppTokens.Space20))
            Button(
                onClick = onActionClick,
                shape = RoundedCornerShape(AppTokens.RadiusButton),
                colors = ButtonDefaults.buttonColors(containerColor = FinPilotTheme.colors.primary)
            ) {
                Text(text = actionButtonText, color = Color.white, fontWeight = FontWeight.SemiBold)
            }
        }
    }
}

@Composable
fun ErrorStateView(
    title: String = "Something went wrong",
    errorMessage: String,
    onRetry: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(AppTokens.Space24),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "⚠ $title",
            style = MaterialTheme.typography.headlineMedium,
            color = FinPilotTheme.colors.danger,
            fontWeight = FontWeight.SemiBold
        )
        Spacer(modifier = Modifier.height(AppTokens.Space8))
        Text(
            text = errorMessage,
            style = MaterialTheme.typography.bodyMedium,
            color = FinPilotTheme.colors.textSecondary
        )
        if (onRetry != null) {
            Spacer(modifier = Modifier.height(AppTokens.Space16))
            OutlinedButton(
                onClick = onRetry,
                shape = RoundedCornerShape(AppTokens.RadiusButton),
                border = androidx.compose.foundation.BorderStroke(1.dp, FinPilotTheme.colors.primary)
            ) {
                Text("Retry", color = FinPilotTheme.colors.primary)
            }
        }
    }
}

@Composable
fun SkeletonLoader(
    modifier: Modifier = Modifier,
    height: Dp = 48.dp,
    cornerRadius: Dp = AppTokens.RadiusSm
) {
    val infiniteTransition = rememberInfiniteTransition()
    val alpha by infiniteTransition.animateFloat(
        initialValue = 0.2f,
        targetValue = 0.6f,
        animationSpec = infiniteRepeatable(
            animation = tween(800, easing = EaseInOutCubic),
            repeatMode = RepeatMode.Reverse
        )
    )

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(height)
            .clip(RoundedCornerShape(cornerRadius))
            .background(FinPilotTheme.colors.elevated.copy(alpha = alpha))
    )
}

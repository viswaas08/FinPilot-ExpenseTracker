package com.finpilot.core.theme

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

data class FinPilotColorScheme(
    val isDark: Boolean,
    val background: Color,
    val surface: Color,
    val elevated: Color,
    val border: Color,
    val primary: Color,
    val secondary: Color,
    val success: Color,
    val danger: Color,
    val warning: Color,
    val textPrimary: Color,
    val textSecondary: Color,
    val textMuted: Color,
    val glassFill: Color,
    val glassBorder: Color
)

val LocalFinPilotColors = staticCompositionLocalOf {
    FinPilotColorScheme(
        isDark = true,
        background = AppColors.DarkBackground,
        surface = AppColors.DarkSurface,
        elevated = AppColors.DarkElevated,
        border = AppColors.DarkBorder,
        primary = AppColors.Primary,
        secondary = AppColors.Secondary,
        success = AppColors.Success,
        danger = AppColors.Danger,
        warning = AppColors.Warning,
        textPrimary = AppColors.DarkTextPrimary,
        textSecondary = AppColors.DarkTextSecondary,
        textMuted = AppColors.DarkTextMuted,
        glassFill = AppColors.GlassOverlayDark,
        glassBorder = AppColors.GlassBorderDark
    )
}

@Composable
fun FinPilotTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val customColors = if (darkTheme) {
        FinPilotColorScheme(
            isDark = true,
            background = AppColors.DarkBackground,
            surface = AppColors.DarkSurface,
            elevated = AppColors.DarkElevated,
            border = AppColors.DarkBorder,
            primary = AppColors.Primary,
            secondary = AppColors.Secondary,
            success = AppColors.Success,
            danger = AppColors.Danger,
            warning = AppColors.Warning,
            textPrimary = AppColors.DarkTextPrimary,
            textSecondary = AppColors.DarkTextSecondary,
            textMuted = AppColors.DarkTextMuted,
            glassFill = AppColors.GlassOverlayDark,
            glassBorder = AppColors.GlassBorderDark
        )
    } else {
        FinPilotColorScheme(
            isDark = false,
            background = AppColors.LightBackground,
            surface = AppColors.LightSurface,
            elevated = AppColors.LightElevated,
            border = AppColors.LightBorder,
            primary = AppColors.Primary,
            secondary = AppColors.Secondary,
            success = AppColors.Success,
            danger = AppColors.Danger,
            warning = AppColors.Warning,
            textPrimary = AppColors.LightTextPrimary,
            textSecondary = AppColors.LightTextSecondary,
            textMuted = AppColors.LightTextMuted,
            glassFill = AppColors.GlassOverlayLight,
            glassBorder = AppColors.GlassBorderLight
        )
    }

    val materialColors = if (darkTheme) {
        darkColorScheme(
            primary = AppColors.Primary,
            secondary = AppColors.Secondary,
            background = AppColors.DarkBackground,
            surface = AppColors.DarkSurface,
            error = AppColors.Danger
        )
    } else {
        lightColorScheme(
            primary = AppColors.Primary,
            secondary = AppColors.Secondary,
            background = AppColors.LightBackground,
            surface = AppColors.LightSurface,
            error = AppColors.Danger
        )
    }

    CompositionLocalProvider(LocalFinPilotColors provides customColors) {
        MaterialTheme(
            colorScheme = materialColors,
            typography = AppTypography.Typography,
            content = content
        )
    }
}

object FinPilotTheme {
    val colors: FinPilotColorScheme
        @Composable
        get() = LocalFinPilotColors.current
}

/**
 * Liquid Glass styling modifier: applies frosted overlay fill with a subtle highlight border
 */
fun Modifier.liquidGlass(
    cornerRadius: Dp = AppTokens.RadiusCard,
    isDark: Boolean = true
): Modifier {
    val shape = RoundedCornerShape(cornerRadius)
    val fillGradient = if (isDark) {
        Brush.linearGradient(
            colors = listOf(Color(0x1F243247), Color(0x0F0D1420))
        )
    } else {
        Brush.linearGradient(
            colors = listOf(Color(0xF0FFFFFF), Color(0xD9FFFFFF))
        )
    }

    val borderStroke = BorderStroke(
        width = 1.dp,
        color = if (isDark) AppColors.GlassBorderDark else AppColors.LightBorder
    )

    return this
        .clip(shape)
        .background(brush = fillGradient, shape = shape)
        .border(borderStroke, shape = shape)
}

import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class AppearanceThemeCard extends StatelessWidget {
  final String activeThemeMode;
  final ValueChanged<String> onThemeChanged;

  const AppearanceThemeCard({
    super.key,
    required this.activeThemeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return LiquidGlassCard(
      borderRadius: 16.0,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_outlined, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Appearance & Theme',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildThemeOption(
                context: context,
                label: 'Dark Mode',
                icon: Icons.dark_mode_rounded,
                mode: 'dark',
                isSelected: activeThemeMode == 'dark',
                subTextColor: subTextColor,
              ),
              const SizedBox(width: 8),
              _buildThemeOption(
                context: context,
                label: 'Light Mode',
                icon: Icons.light_mode_rounded,
                mode: 'light',
                isSelected: activeThemeMode == 'light',
                subTextColor: subTextColor,
              ),
              const SizedBox(width: 8),
              _buildThemeOption(
                context: context,
                label: 'System',
                icon: Icons.brightness_auto_rounded,
                mode: 'system',
                isSelected: activeThemeMode == 'system',
                subTextColor: subTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String mode,
    required bool isSelected,
    required Color subTextColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.lightSurfaceVariant;

    return Expanded(
      child: GestureDetector(
        onTap: () => onThemeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : unselectedBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : subTextColor,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : subTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

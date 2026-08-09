import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/categories/domain/entities/transaction_category.dart';

class CategoryGlassCard extends StatefulWidget {
  final TransactionCategory category;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CategoryGlassCard({
    super.key,
    required this.category,
    required this.onTap,
    this.onDelete,
  });

  @override
  State<CategoryGlassCard> createState() => _CategoryGlassCardState();
}

class _CategoryGlassCardState extends State<CategoryGlassCard> {
  bool _isDeleteState = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GestureDetector(
      onLongPress: () {
        if (cat.isCustom) {
          setState(() => _isDeleteState = !_isDeleteState);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isDeleteState
                ? Colors.redAccent
                : (isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.lightBorder),
            width: _isDeleteState ? 2.0 : 1.2,
          ),
          boxShadow: _isDeleteState
              ? [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.5),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            LiquidGlassCard(
              borderRadius: 16.0,
              padding: const EdgeInsets.all(16),
              borderColor: _isDeleteState ? Colors.redAccent : cat.color.withValues(alpha: isDark ? 0.4 : 0.5),
              onTap: _isDeleteState ? null : widget.onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with Aura
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      cat.icon,
                      color: cat.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Name Text
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Monthly Budget Bar / Indicator
                  if (cat.monthlyBudget > 0) ...[
                    Text(
                      'Limit: ${CurrencyFormatter.formatCompact(cat.monthlyBudget)}/mo',
                      style: TextStyle(
                        fontSize: 11,
                        color: subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.45,
                        minHeight: 4,
                        backgroundColor: cat.color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                      ),
                    ),
                  ] else
                    Text(
                      cat.isCustom ? 'Custom' : 'System Default',
                      style: TextStyle(
                        fontSize: 11,
                        color: subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            // Delete Action Badge Overlay
            if (_isDeleteState && widget.onDelete != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/categories/domain/entities/transaction_category.dart';

class CategoryGlassCard extends StatefulWidget {
  final TransactionCategory category;
  final double actualSpent;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CategoryGlassCard({
    super.key,
    required this.category,
    this.actualSpent = 0.0,
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

    final progressVal = cat.monthlyBudget > 0 ? (widget.actualSpent / cat.monthlyBudget).clamp(0.0, 1.0) : 0.0;

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
                : (isDark ? const Color(0xFF263346) : AppColors.lightBorder),
            width: _isDeleteState ? 2.0 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            LiquidGlassCard(
              borderRadius: 16.0,
              padding: const EdgeInsets.all(14),
              borderColor: _isDeleteState ? Colors.redAccent : cat.color.withValues(alpha: 0.3),
              onTap: _isDeleteState ? null : widget.onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Badge with aura ring
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: cat.color.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Icon(
                      cat.icon,
                      color: cat.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Category Name
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      decoration: TextDecoration.none,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Monthly Budget Bar / Indicator
                  if (cat.monthlyBudget > 0) ...[
                    Text(
                      '${CurrencyFormatter.formatCompact(widget.actualSpent)} / ${CurrencyFormatter.formatCompact(cat.monthlyBudget)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: subTextColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressVal,
                        minHeight: 4,
                        backgroundColor: cat.color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressVal > 0.9 ? AppColors.expense : cat.color,
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cat.isCustom ? 'Custom Tag' : 'System Default',
                        style: TextStyle(
                          fontSize: 10,
                          color: subTextColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
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
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.white,
                      size: 18,
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

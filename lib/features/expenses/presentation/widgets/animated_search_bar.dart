import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class AnimatedSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const AnimatedSearchBar({super.key, required this.onChanged});

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  bool _isExpanded = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: _isExpanded ? MediaQuery.of(context).size.width - 32 : 48,
      height: 48,
      child: LiquidGlassCard(
        borderRadius: 12.0,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        blur: 20.0,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _isExpanded ? Icons.close_rounded : Icons.search_rounded,
                color: textColor,
                size: 22,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (!_isExpanded) {
                    _controller.clear();
                    widget.onChanged('');
                  }
                });
              },
            ),
            if (_isExpanded) ...[
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search title, category, or note...',
                    hintStyle: TextStyle(
                      color: subTextColor,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

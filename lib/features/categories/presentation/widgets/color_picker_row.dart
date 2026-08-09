import 'package:flutter/material.dart';

class ColorPickerRow extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerRow({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  static const List<Color> colors = [
    Color(0xFFFF9F0A), // Neon Orange
    Color(0xFFFF3B30), // Neon Pink/Red
    Color(0xFF06B6D4), // Neon Cyan
    Color(0xFF007AFF), // Neon Blue
    Color(0xFFFF2D55), // Neon Crimson
    Color(0xFF5856D6), // Neon Indigo
    Color(0xFFAF52DE), // Neon Purple
    Color(0xFF34C759), // Neon Emerald Green
    Color(0xFF64D2FF), // Neon Sky Blue
    Color(0xFFFFD60A), // Neon Yellow
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final col = colors[index];
          final isSelected = selectedColor.toARGB32() == col.toARGB32();

          return GestureDetector(
            onTap: () => onColorSelected(col),
            child: AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: col,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: isSelected ? 3.0 : 0.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: col.withValues(alpha: isSelected ? 0.6 : 0.25),
                      blurRadius: isSelected ? 14 : 6,
                      spreadRadius: isSelected ? 2 : 0,
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';

class IconPickerGrid extends StatelessWidget {
  final IconData selectedIcon;
  final Color accentColor;
  final ValueChanged<IconData> onIconSelected;

  const IconPickerGrid({
    super.key,
    required this.selectedIcon,
    required this.accentColor,
    required this.onIconSelected,
  });

  static const List<IconData> icons = [
    Icons.restaurant_rounded,
    Icons.shopping_bag_rounded,
    Icons.directions_car_rounded,
    Icons.receipt_long_rounded,
    Icons.medical_services_rounded,
    Icons.school_rounded,
    Icons.movie_creation_rounded,
    Icons.flight_takeoff_rounded,
    Icons.fitness_center_rounded,
    Icons.home_rounded,
    Icons.sports_esports_rounded,
    Icons.pets_rounded,
    Icons.local_cafe_rounded,
    Icons.build_rounded,
    Icons.work_rounded,
    Icons.card_giftcard_rounded,
    Icons.brush_rounded,
    Icons.security_rounded,
    Icons.phone_android_rounded,
    Icons.wifi_rounded,
    Icons.local_grocery_store_rounded,
    Icons.directions_bus_rounded,
    Icons.nature_people_rounded,
    Icons.more_horiz_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 28.0,
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final iconData = icons[index];
          final isSelected = selectedIcon.codePoint == iconData.codePoint;

          return GestureDetector(
            onTap: () => onIconSelected(iconData),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : Colors.transparent,
                  width: isSelected ? 2.0 : 0.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                iconData,
                color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.7),
                size: 22,
              ),
            ),
          );
        },
      ),
    );
  }
}

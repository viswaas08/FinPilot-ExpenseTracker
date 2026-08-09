import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class OceanMeshBackground extends StatelessWidget {
  final Widget child;

  const OceanMeshBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: isDark ? AppColors.background : AppColors.lightBackground,
      child: child,
    );
  }
}

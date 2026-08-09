import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTypography {
  static const TextStyle display = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    color: AppColors.primaryText,
    height: 1.2,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: AppColors.primaryText,
    height: 1.25,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.secondaryText,
    height: 1.3,
  );

  static const TextStyle financialValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    color: AppColors.primaryText,
    height: 1.15,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    color: AppColors.primaryText,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.mutedText,
    height: 1.35,
  );
}

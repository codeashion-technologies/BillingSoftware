import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const _font = 'Segoe UI';
  static const displayLarge = TextStyle(
    fontFamily: _font,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const displayMedium = TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const headlineLarge = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const headlineMedium = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const titleLarge = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const titleMedium = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const titleSmall = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const bodyLarge = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    color: AppColors.textPrimary,
  );
  static const bodyMedium = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    color: AppColors.textPrimary,
  );
  static const bodySmall = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    color: AppColors.textSecondary,
  );
  static const labelLarge = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const labelMedium = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static const labelSmall = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static const homeTitle = TextStyle(
    fontFamily: _font,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static const homeAddress = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    color: Colors.white,
  );
  static const homeWatermark = TextStyle(
    fontFamily: _font,
    fontSize: 72,
    fontWeight: FontWeight.w700,
    color: AppColors.homeGlow,
  );
  static const status = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    color: AppColors.textPrimary,
  );
}

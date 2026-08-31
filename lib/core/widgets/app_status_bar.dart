import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class AppStatusBar extends StatelessWidget {
  const AppStatusBar({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 24,
    decoration: BoxDecoration(
      color: AppColors.header.withValues(alpha: 0.8),
      border: const Border(top: BorderSide(color: AppColors.border)),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          _StatusCell('MILL BASE'),
          _StatusCell('SHREE BALKRISHNA FASHION'),
          _StatusCell('2026-27'),
          _StatusCell('CAPS'),
          _StatusCell('NUM'),
          _StatusCell('INS'),
          _StatusCell('OFFICE'),
          _StatusCell('LICENSE COPY'),
          _StatusCell('Auto JV : ON'),
          _StatusCell('Sync'),
          _StatusCell('Data Size'),
        ],
      ),
    ),
  );
}

class _StatusCell extends StatelessWidget {
  const _StatusCell(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 24,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      border: Border(right: BorderSide(color: AppColors.border)),
    ),
    child: Text(label, style: AppTextStyles.status),
  );
}

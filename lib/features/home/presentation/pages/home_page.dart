import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/models/company_profile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const profile = CompanyProfile.defaults;
    return LayoutBuilder(
      builder: (context, constraints) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.homeStart,
              AppColors.homeMiddle,
              AppColors.homeEnd,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.12,
                  child: Text(
                    'CODEASHION TECHNOLOGIES',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: AppTextStyles.homeWatermark.copyWith(
                      fontSize: constraints.maxWidth.clamp(32.0, 90.0),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 32,
              bottom: 28,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'CODEASHION TECHNOLOGIES',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.homeTitle.copyWith(
                        fontSize: constraints.maxWidth < 600 ? 25 : 34,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(profile.clientName, style: AppTextStyles.homeAddress),
                    Text('[Company Address]', style: AppTextStyles.homeAddress),
                    Text(profile.area, style: AppTextStyles.homeAddress),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

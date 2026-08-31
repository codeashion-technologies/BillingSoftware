import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good morning', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your accounting workspace at a glance.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 1100
                ? 3
                : constraints.maxWidth > 650
                ? 2
                : 1;
            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              childAspectRatio: 2.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _MetricCard(
                  label: 'Total Receivable',
                  value: '₹ 0.00',
                  icon: Icons.call_received,
                  color: AppColors.accent,
                ),
                _MetricCard(
                  label: 'Total Payable',
                  value: '₹ 0.00',
                  icon: Icons.call_made,
                  color: AppColors.warning,
                ),
                _MetricCard(
                  label: 'Cash Balance',
                  value: '₹ 0.00',
                  icon: Icons.payments_outlined,
                  color: AppColors.success,
                ),
                _MetricCard(
                  label: 'Bank Balance',
                  value: '₹ 0.00',
                  icon: Icons.account_balance,
                  color: AppColors.secondary,
                ),
                _MetricCard(
                  label: "Today's Sales",
                  value: '₹ 0.00',
                  icon: Icons.trending_up,
                  color: AppColors.primary,
                ),
                _MetricCard(
                  label: "Today's Purchase",
                  value: '₹ 0.00',
                  icon: Icons.shopping_cart_outlined,
                  color: AppColors.error,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        const AppCard(
          child: SizedBox(
            height: 180,
            child: Center(
              child: Text(
                'Recent activity will appear here once transactions are recorded.',
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ],
    ),
  );
}

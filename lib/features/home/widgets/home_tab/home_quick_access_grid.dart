import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';

/// A single destination shown in [HomeQuickAccessGrid].
class QuickAccessItem {
  const QuickAccessItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

/// Row of quick-access shortcut cards ("দ্রুত প্রবেশ") on the home tab.
class HomeQuickAccessGrid extends StatelessWidget {
  const HomeQuickAccessGrid({super.key, required this.items});

  final List<QuickAccessItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(width: AppSpacing.md),
          Expanded(child: _QuickAccessCard(item: items[i])),
        ],
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({required this.item});

  final QuickAccessItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        item.onTap();
      },
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.surfaceFor(context),
              borderRadius: AppRadius.large,
              border: Border.all(color: AppColors.borderFor(context)),
              boxShadow: AppShadow.small,
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.medium,
                ),
                child: Icon(item.icon, size: 21, color: item.color),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.label,
            style: AppTextStyles.bodySmall(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryFor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

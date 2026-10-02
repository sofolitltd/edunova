import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';

/// "দৈনিক চ্যালেঞ্জ" banner nudging the student toward today's daily content,
/// with copy that adapts to their current streak.
class HomeDailyChallengeBanner extends StatelessWidget {
  const HomeDailyChallengeBanner({super.key, required this.streak, required this.onTap});

  final int streak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = streak > 0
        ? '$streak দিন স্ট্রিক বজায় রাখতে আজকের পাঠ সম্পন্ন করুন'
        : 'আজকের দৈনিক শেখা সম্পন্ন করে স্ট্রিক শুরু করুন';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.extraLarge,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: AppRadius.medium,
              ),
              child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'দৈনিক চ্যালেঞ্জ',
                    style: AppTextStyles.label(context).copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryFor(context)),
          ],
        ),
      ),
    );
  }
}

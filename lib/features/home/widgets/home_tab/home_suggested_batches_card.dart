import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../services/batch_service.dart' show SuggestedBatch;

/// Suggests the physical coaching batches open for the student's class,
/// with an in-app join (paid) option or a note to visit the branch in person.
class HomeSuggestedBatchesCard extends StatelessWidget {
  const HomeSuggestedBatchesCard({
    super.key,
    required this.batches,
    required this.onTap,
  });

  final List<SuggestedBatch> batches;
  final ValueChanged<SuggestedBatch> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < batches.length; i++) ...[
          _BatchTile(batch: batches[i], onTap: () => onTap(batches[i])),
          if (i != batches.length - 1) const SizedBox(height: AppSpacing.md),
        ],
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: AppRadius.small,
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'সিট নিশ্চিত করতে এই ব্যাচে জয়েন করতে পারেন, অথবা চাইলে সরাসরি আমাদের বগুড়া শাখায় এসেও ভর্তি হতে পারেন',
                  style: AppTextStyles.bodySmall(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BatchTile extends StatelessWidget {
  const _BatchTile({required this.batch, required this.onTap});

  final SuggestedBatch batch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.large,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: AppRadius.small,
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batch.name,
                        style: AppTextStyles.bodyLarge(context)
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (batch.schedule.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          batch.schedule,
                          style: AppTextStyles.bodySmall(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (batch.monthlyFee > 0) ...[
                  Text(
                    '৳${batch.monthlyFee}/মাস',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                ] else
                  const Spacer(),
                TextButton(
                  onPressed: onTap,
                  child: const Text('বিস্তারিত দেখুন'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

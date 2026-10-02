import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../results/services/results_service.dart' show ResultSummary;

/// Fallback overall-result summary card shown when the student has no
/// active batch enrollment but does have exam results.
class HomeProgressSummaryCard extends StatelessWidget {
  const HomeProgressSummaryCard({super.key, required this.summary, required this.onTap});

  final ResultSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = summary.overallPercent;
    final color = percent >= 70
        ? AppColors.success
        : percent >= 50
            ? AppColors.warning
            : AppColors.error;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('সামগ্রিক ফলাফল', style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    summary.improvementAreas.isNotEmpty
                        ? '${summary.improvementAreas.first.subject}-এ উন্নতি দরকার'
                        : '${summary.totalExams}টি পরীক্ষার ফলাফল দেখুন',
                    style: AppTextStyles.bodySmall(context),
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

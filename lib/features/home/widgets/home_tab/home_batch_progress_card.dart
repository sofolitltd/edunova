import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../courses/services/course_service.dart' show Enrollment;
import '../../../results/services/results_service.dart' show SubjectSummary;

/// "আমার ব্যাচ ও পাঠক্রম" card: the student's active batch/routine plus a
/// per-subject progress breakdown built from their exam results.
class HomeBatchProgressCard extends StatelessWidget {
  const HomeBatchProgressCard({
    super.key,
    required this.enrollment,
    required this.bySubject,
    required this.onBatchTap,
    required this.onSubjectTap,
  });

  final Enrollment enrollment;
  final List<SubjectSummary> bySubject;
  final VoidCallback onBatchTap;
  final VoidCallback onSubjectTap;

  static const _subjectColors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.warning,
    AppColors.success,
  ];

  @override
  Widget build(BuildContext context) {
    const color = AppColors.primary;

    return Container(
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
          GestureDetector(
            onTap: onBatchTap,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: AppRadius.small,
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enrollment.batchName.isNotEmpty ? enrollment.batchName : 'রুটিন',
                        style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        enrollment.courseName,
                        style: AppTextStyles.bodySmall(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'চলমান',
                    style: AppTextStyles.label(context).copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (enrollment.batchSchedule.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: onBatchTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundFor(context),
                  borderRadius: AppRadius.small,
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 16, color: AppColors.textTertiaryFor(context)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        enrollment.batchSchedule,
                        style: AppTextStyles.bodySmall(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondaryFor(context)),
                  ],
                ),
              ),
            ),
          ],
          if (bySubject.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            for (int i = 0; i < bySubject.length; i++) ...[
              _SubjectProgressRow(
                subject: bySubject[i],
                color: _subjectColors[i % _subjectColors.length],
                onTap: onSubjectTap,
              ),
              if (i != bySubject.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }
}

class _SubjectProgressRow extends StatelessWidget {
  const _SubjectProgressRow({required this.subject, required this.color, required this.onTap});

  final SubjectSummary subject;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = subject.averagePercent.clamp(0, 100);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.backgroundFor(context),
          borderRadius: AppRadius.medium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          subject.subject,
                          style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: AppTextStyles.label(context).copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 6,
                backgroundColor: AppColors.borderFor(context),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${subject.examCount}টি পরীক্ষার গড়',
              style: AppTextStyles.bodySmall(context),
            ),
          ],
        ),
      ),
    );
  }
}

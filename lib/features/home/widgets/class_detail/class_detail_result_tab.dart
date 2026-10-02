import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../services/batch_service.dart' show BatchMyResult;

/// "Results" tab: the current student's own exam results for this batch.
class ClassDetailResultTab extends StatelessWidget {
  const ClassDetailResultTab({
    super.key,
    required this.results,
    required this.loading,
    required this.loaded,
  });

  final List<BatchMyResult> results;
  final bool loading;
  final bool loaded;

  Color _percentColor(double percent) {
    if (percent >= 70) return AppColors.success;
    if (percent >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    if (loading && !loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart_rounded, size: 56, color: AppColors.textTertiaryFor(context)),
              const SizedBox(height: AppSpacing.md),
              Text('এখনো কোনো ফলাফল নেই', style: AppTextStyles.bodyMedium(context)),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xl,
      ),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final r = results[i];
        final color = _percentColor(r.percentage);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context),
            borderRadius: AppRadius.small,
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: AppRadius.small),
                child: Center(
                  child: Text(
                    '${r.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.examTitle,
                      style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(r.examDate, style: AppTextStyles.bodySmall(context)),
                  ],
                ),
              ),
              Text('${r.score}/${r.totalQuestions}', style: AppTextStyles.bodySmall(context)),
            ],
          ),
        );
      },
    );
  }
}

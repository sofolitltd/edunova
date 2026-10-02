import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../services/batch_service.dart' show BatchExam;

/// "Exams" tab: list of exams for this batch; tapping one opens exam taking.
class ClassDetailExamTab extends StatelessWidget {
  const ClassDetailExamTab({
    super.key,
    required this.exams,
    required this.loading,
    required this.loaded,
    required this.color,
    required this.onExamTap,
  });

  final List<BatchExam> exams;
  final bool loading;
  final bool loaded;
  final Color color;
  final void Function(BatchExam exam) onExamTap;

  @override
  Widget build(BuildContext context) {
    if (loading && !loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (exams.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_outlined, size: 56, color: AppColors.textTertiaryFor(context)),
              const SizedBox(height: AppSpacing.md),
              Text('এই ব্যাচের জন্য কোনো পরীক্ষা নেই', style: AppTextStyles.bodyMedium(context)),
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
      itemCount: exams.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final e = exams[i];
        return GestureDetector(
          onTap: () => onExamTap(e),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceFor(context),
              borderRadius: AppRadius.small,
              border: Border.all(
                color: e.isLive ? AppColors.error.withValues(alpha: 0.3) : AppColors.borderFor(context),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (e.isLive ? AppColors.error : color).withValues(alpha: 0.1),
                    borderRadius: AppRadius.small,
                  ),
                  child: Icon(
                    e.isLive ? Icons.play_circle_filled_rounded : Icons.quiz_rounded,
                    size: 20,
                    color: e.isLive ? AppColors.error : color,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w500)),
                      Text('${e.date} • ${e.totalQuestions} প্রশ্ন', style: AppTextStyles.bodySmall(context)),
                    ],
                  ),
                ),
                if (e.isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

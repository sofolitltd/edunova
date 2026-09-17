import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../services/exam_service.dart';

class ExamResultScreen extends StatelessWidget {
  final String examTitle;
  final int correctAnswers;
  final int totalQuestions;
  /// When available (right after submitting), enables a per-question review.
  final List<ExamQuestion>? questions;
  final Map<int, String>? answers;

  const ExamResultScreen({
    super.key,
    required this.examTitle,
    required this.correctAnswers,
    required this.totalQuestions,
    this.questions,
    this.answers,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
    final wrongAnswers = totalQuestions - correctAnswers;
    final color = percentage >= 80
        ? AppColors.success
        : percentage >= 50
            ? AppColors.primary
            : AppColors.warning;
    final canReview = questions != null && answers != null;

    return AppScaffold(
      appBar: const AppAppBar(title: 'ফলাফল'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1),
                  border: Border.all(color: color, width: 5),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${percentage.round()}%',
                        style: AppTextStyles.h2(context)
                            .copyWith(color: color, fontWeight: FontWeight.w800),
                      ),
                      Text('স্কোর', style: AppTextStyles.bodySmall(context)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              examTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3(context),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'মোট প্রশ্ন',
                    value: '$totalQuestions',
                    color: AppColors.primary,
                    icon: Icons.list_alt_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatCard(
                    label: 'সঠিক',
                    value: '$correctAnswers',
                    color: AppColors.success,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatCard(
                    label: 'ভুল',
                    value: '$wrongAnswers',
                    color: AppColors.error,
                    icon: Icons.cancel_rounded,
                  ),
                ),
              ],
            ),
            if (canReview) ...[
              const SizedBox(height: AppSpacing.xxl),
              Text('প্রশ্ন পর্যালোচনা', style: AppTextStyles.h3(context)),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < questions!.length; i++)
                _ReviewCard(
                  index: i + 1,
                  question: questions![i],
                  selectedLetter: answers![questions![i].id],
                ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              text: 'বন্ধ করুন',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: AppTextStyles.bodyLarge(context)
                  .copyWith(fontWeight: FontWeight.w700, color: color)),
          Text(label, style: AppTextStyles.bodySmall(context)),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final int index;
  final ExamQuestion question;
  final String? selectedLetter;

  const _ReviewCard({
    required this.index,
    required this.question,
    required this.selectedLetter,
  });

  @override
  Widget build(BuildContext context) {
    final correctLetter = question.correctLetter;
    final isCorrect = selectedLetter != null && selectedLetter == correctLetter;
    final options = {
      'A': question.optionA,
      'B': question.optionB,
      'C': question.optionC,
      'D': question.optionD,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.medium,
        border: Border.all(
          color: selectedLetter == null
              ? AppColors.borderFor(context)
              : (isCorrect ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$index. ${question.questionText}',
              style: AppTextStyles.bodyMedium(context)
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          for (final entry in options.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    entry.key == correctLetter
                        ? Icons.check_circle_rounded
                        : entry.key == selectedLetter
                            ? Icons.cancel_rounded
                            : Icons.circle_outlined,
                    size: 16,
                    color: entry.key == correctLetter
                        ? AppColors.success
                        : entry.key == selectedLetter
                            ? AppColors.error
                            : AppColors.textTertiaryFor(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${entry.key}. ${entry.value}',
                      style: AppTextStyles.bodySmall(context).copyWith(
                        fontWeight: entry.key == correctLetter
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class ClassTab extends ConsumerWidget {
  const ClassTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.classes,
              style: AppTextStyles.h2(context),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.classSubtitle,
              style: AppTextStyles.bodyMedium(context),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Enrolled Classes ───────────────────
            Text(
              l10n.enrolledClasses,
              style: AppTextStyles.h3(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildClassCard(
              context,
              subject: l10n.mathematics,
              teacher: 'Mr. Rahman',
              schedule: 'Mon, Wed, Fri • 10:00 AM',
              students: 35,
              color: AppColors.primary,
              nextClass: l10n.nextClassToday,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildClassCard(
              context,
              subject: l10n.physics,
              teacher: 'Ms. Akter',
              schedule: 'Tue, Thu • 2:00 PM',
              students: 32,
              color: AppColors.success,
              nextClass: l10n.nextClassTomorrow,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildClassCard(
              context,
              subject: l10n.englishLit,
              teacher: 'Mr. Hossain',
              schedule: 'Mon, Wed • 11:30 AM',
              students: 28,
              color: AppColors.accent,
              nextClass: l10n.nextClassIn2Days,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildClassCard(
              context,
              subject: l10n.chemistry,
              teacher: 'Ms. Begum',
              schedule: 'Tue, Fri • 9:00 AM',
              students: 30,
              color: AppColors.warning,
              nextClass: l10n.nextClassToday,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Class Materials ─────────────────────
            Text(
              l10n.classMaterials,
              style: AppTextStyles.h3(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildMaterialCard(
              context,
              title: l10n.mathNotesWeek1,
              type: 'PDF',
              size: '2.4 MB',
              icon: Icons.picture_as_pdf_rounded,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildMaterialCard(
              context,
              title: l10n.physicsLabRecord,
              type: 'DOC',
              size: '1.8 MB',
              icon: Icons.description_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildMaterialCard(
              context,
              title: l10n.englishEssay,
              type: 'PDF',
              size: '890 KB',
              icon: Icons.picture_as_pdf_rounded,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.xxxxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required String subject,
    required String teacher,
    required String schedule,
    required int students,
    required Color color,
    required String nextClass,
  }) {
    return GestureDetector(
      onTap: () => context.push('/class-detail', extra: {
        'subject': subject,
        'teacher': teacher,
        'schedule': schedule,
        'students': students,
        'color': color,
      }),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
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
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      teacher,
                      style: AppTextStyles.bodySmall(context),
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
                  '$students',
                  style: AppTextStyles.label(context).copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundFor(context),
              borderRadius: AppRadius.small,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.textTertiaryFor(context),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  schedule,
                  style: AppTextStyles.bodySmall(context),
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  nextClass,
                  style: AppTextStyles.label(context).copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildMaterialCard(
    BuildContext context, {
    required String title,
    required String type,
    required String size,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppShadow.small,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.small,
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$type • $size',
                  style: AppTextStyles.bodySmall(context),
                ),
              ],
            ),
          ),
          Icon(
            Icons.download_rounded,
            size: 20,
            color: AppColors.textTertiaryFor(context),
          ),
        ],
      ),
    );
  }
}

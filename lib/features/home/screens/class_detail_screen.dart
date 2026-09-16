import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class ClassDetailScreen extends ConsumerWidget {
  final String subject;
  final String teacher;
  final String schedule;
  final int students;
  final Color color;

  const ClassDetailScreen({
    super.key,
    required this.subject,
    required this.teacher,
    required this.schedule,
    required this.students,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      appBar: AppAppBar(title: subject),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),

            // ── Header Card ──────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: AppRadius.large,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppRadius.medium,
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject,
                              style: AppTextStyles.h2(context).copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              teacher,
                              style: AppTextStyles.bodyLarge(context).copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      _buildHeaderStat(
                        context,
                        icon: Icons.schedule_rounded,
                        value: schedule,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _buildHeaderStat(
                        context,
                        icon: Icons.people_rounded,
                        value: '$students ${l10n.students}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── About ─────────────────────────────
            Text(l10n.aboutClass, style: AppTextStyles.h3(context)),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceFor(context),
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Text(
                l10n.classAboutDescription,
                style: AppTextStyles.bodyLarge(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Schedule ──────────────────────────
            Text(l10n.weeklySchedule, style: AppTextStyles.h3(context)),
            const SizedBox(height: AppSpacing.md),
            _buildScheduleRow(context, 'Monday', '10:00 AM - 11:30 AM', true),
            _buildScheduleRow(context, 'Wednesday', '10:00 AM - 11:30 AM', true),
            _buildScheduleRow(context, 'Friday', '10:00 AM - 11:30 AM', true),
            _buildScheduleRow(context, 'Tuesday', '-', false),
            _buildScheduleRow(context, 'Thursday', '-', false),
            const SizedBox(height: AppSpacing.xxl),

            // ── Materials ─────────────────────────
            Text(l10n.classMaterials, style: AppTextStyles.h3(context)),
            const SizedBox(height: AppSpacing.md),
            _buildMaterialItem(
              context,
              title: l10n.mathNotesWeek1,
              type: 'PDF',
              size: '2.4 MB',
              icon: Icons.picture_as_pdf_rounded,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildMaterialItem(
              context,
              title: 'Chapter 2 Slides',
              type: 'PPT',
              size: '5.1 MB',
              icon: Icons.slideshow_rounded,
              color: AppColors.warning,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildMaterialItem(
              context,
              title: 'Assignment 1',
              type: 'PDF',
              size: '890 KB',
              icon: Icons.assignment_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Students ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.students, style: AppTextStyles.h3(context)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '$students ${l10n.total}',
                    style: AppTextStyles.label(context).copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...List.generate(5, (i) {
              final names = ['Rahat', 'Tasnim', 'Arif', 'Nusrat', 'Sumaiya'];
              return _buildStudentRow(context, names[i], i);
            }),
            const SizedBox(height: AppSpacing.xxxxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(BuildContext context, {
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Text(
          value,
          style: AppTextStyles.bodySmall(context).copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleRow(BuildContext context, String day, String time, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.05)
            : AppColors.surfaceFor(context),
        borderRadius: AppRadius.small,
        border: Border.all(
          color: active ? color.withValues(alpha: 0.2) : AppColors.borderFor(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? color : AppColors.textTertiaryFor(context),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              day,
              style: AppTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w500,
                color: active ? AppColors.textPrimaryFor(context) : AppColors.textTertiaryFor(context),
              ),
            ),
          ),
          Text(
            time,
            style: AppTextStyles.bodySmall(context).copyWith(
              color: active ? color : AppColors.textTertiaryFor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialItem(BuildContext context, {
    required String title,
    required String type,
    required String size,
    required IconData icon,
    required Color color,
  }) {
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.small,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
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

  Widget _buildStudentRow(BuildContext context, String name, int index) {
    final colors = [AppColors.primary, AppColors.success, AppColors.accent, AppColors.warning, AppColors.error];
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors[index % colors.length].withValues(alpha: 0.1),
            child: Text(
              name[0],
              style: AppTextStyles.label(context).copyWith(
                color: colors[index % colors.length],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.textTertiaryFor(context),
          ),
        ],
      ),
    );
  }
}

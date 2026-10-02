import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../services/batch_service.dart' show BatchDetail;
import 'class_detail_header.dart';

/// "About Class" tab: header card, course description, batch info and teacher list.
class ClassDetailAboutTab extends StatelessWidget {
  const ClassDetailAboutTab({super.key, required this.batch, required this.color});

  final BatchDetail batch;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClassDetailHeader(batch: batch, color: color),
          const SizedBox(height: AppSpacing.xl),
          if (batch.courseDescription.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceFor(context),
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Text(batch.courseDescription, style: AppTextStyles.bodyLarge(context)),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceFor(context),
              borderRadius: AppRadius.medium,
              border: Border.all(color: AppColors.borderFor(context)),
            ),
            child: Column(
              children: [
                _infoRow(context, Icons.school_rounded, 'ক্লাস',
                    text: batch.classLevel.isNotEmpty ? batch.classLevel : '-'),
                _infoRow(context, Icons.category_rounded, 'ধরন',
                    trailing: batch.type.isNotEmpty ? _typePill(context, batch.type) : const Text('-')),
                _infoRow(context, Icons.wb_sunny_rounded, 'শিফট',
                    text: batch.shift.isNotEmpty ? batch.shift : '-'),
                _infoRow(context, Icons.people_rounded, 'মোট শিক্ষার্থী',
                    trailing: _countBadge(context, '${batch.studentCount}')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text('শিক্ষক', style: AppTextStyles.h3(context)),
              const SizedBox(width: AppSpacing.sm),
              if (batch.teachers.isNotEmpty) _countBadge(context, '${batch.teachers.length} জন'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (batch.teachers.isEmpty)
            Text('এখনো কোনো শিক্ষক নিয়োগ করা হয়নি', style: AppTextStyles.bodySmall(context))
          else
            ...batch.teachers.map((t) => Container(
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
                        backgroundColor: color.withValues(alpha: 0.1),
                        child: Text(
                          t.fullName.isNotEmpty ? t.fullName[0].toUpperCase() : '?',
                          style: AppTextStyles.label(context).copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(t.fullName, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, {String? text, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiaryFor(context)),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.bodySmall(context)),
          const Spacer(),
          trailing ??
              Text(text ?? '-', style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _typePill(BuildContext context, String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        type,
        style: AppTextStyles.bodySmall(context).copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _countBadge(BuildContext context, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        value,
        style: AppTextStyles.bodySmall(context).copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

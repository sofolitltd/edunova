import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../services/batch_service.dart' show BatchStudent;

/// "Students" tab: roster of fellow students enrolled in this batch.
class ClassDetailStudentsTab extends StatelessWidget {
  const ClassDetailStudentsTab({
    super.key,
    required this.students,
    required this.loading,
    required this.loaded,
    required this.color,
  });

  final List<BatchStudent> students;
  final bool loading;
  final bool loaded;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (loading && !loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (students.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.groups_outlined, size: 56, color: AppColors.textTertiaryFor(context)),
              const SizedBox(height: AppSpacing.md),
              Text('এখনো কোনো শিক্ষার্থী নেই', style: AppTextStyles.bodyMedium(context)),
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
      itemCount: students.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final s = students[i];
        return Container(
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
                  s.fullName.isNotEmpty ? s.fullName[0].toUpperCase() : '?',
                  style: AppTextStyles.label(context).copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(s.fullName, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w500)),
              ),
              if (s.studentId.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    s.studentId,
                    style: AppTextStyles.bodySmall(context).copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../courses/services/course_service.dart' show Course;

/// Horizontally-scrolling course card used in the free/offline/online course
/// rails on the home tab.
class HomeCourseCard extends StatelessWidget {
  const HomeCourseCard({
    super.key,
    required this.course,
    required this.accentColor,
    required this.onTap,
  });

  final Course course;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 228,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.extraLarge,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.small,
                  ),
                  child: Text(
                    course.type == 'free'
                        ? 'ফ্রী'
                        : course.type == 'offline'
                            ? 'অফলাইন'
                            : 'অনলাইন',
                    style: AppTextStyles.label(context).copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                if (course.classLevel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundFor(context),
                      borderRadius: AppRadius.small,
                      border: Border.all(color: AppColors.borderFor(context)),
                    ),
                    child: Text(
                      'Class ${course.classLevel}',
                      style: AppTextStyles.label(context).copyWith(fontSize: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              course.titleBn.isNotEmpty ? course.titleBn : course.title,
              style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (course.schedule.isNotEmpty) ...[
              Text(
                course.schedule,
                style: AppTextStyles.bodySmall(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
            ],
            if (course.type == 'free')
              Text(
                'ফ্রী',
                style: AppTextStyles.bodyLarge(context).copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w800,
                ),
              )
            else
              Text(
                '৳${course.price}',
                style: AppTextStyles.bodyLarge(context).copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

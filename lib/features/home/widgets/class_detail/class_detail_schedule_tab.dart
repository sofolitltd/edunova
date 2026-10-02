import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../services/batch_service.dart' show BatchDetail, BatchSubjectSchedule;

/// "Weekly Schedule" tab: per-subject schedule when set up, else the
/// flat batch-wide days/time range as a fallback.
class ClassDetailScheduleTab extends StatelessWidget {
  const ClassDetailScheduleTab({
    super.key,
    required this.batch,
    required this.subjects,
    required this.loading,
    required this.loaded,
    required this.color,
  });

  final BatchDetail batch;
  final List<BatchSubjectSchedule> subjects;
  final bool loading;
  final bool loaded;
  final Color color;

  static const _weekDays = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  static const _weekDayAbbrev = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  @override
  Widget build(BuildContext context) {
    if (loading && !loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (subjects.isEmpty) {
      final activeDays = batch.days.map((d) => d.toLowerCase()).toSet();
      final timeRange = batch.startTime.isNotEmpty && batch.endTime.isNotEmpty
          ? '${batch.startTime} - ${batch.endTime}'
          : batch.schedule;

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _weekDays.map((day) {
            final active = activeDays.contains(day.toLowerCase());
            return _buildScheduleRow(context, day, active ? timeRange : '-', active);
          }).toList(),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_weekDays.length, (i) {
          final dayKey = _weekDayAbbrev[i].toLowerCase();
          final dayEntries = subjects
              .where((s) => s.days.any((d) => d.toLowerCase() == dayKey))
              .toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));
          return _buildDaySubjects(context, _weekDays[i], dayEntries);
        }),
      ),
    );
  }

  Widget _buildDaySubjects(BuildContext context, String day, List<BatchSubjectSchedule> entries) {
    final active = entries.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.05) : AppColors.surfaceFor(context),
        borderRadius: AppRadius.small,
        border: Border.all(
          color: active ? color.withValues(alpha: 0.2) : AppColors.borderFor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Text(
                day,
                style: AppTextStyles.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.textPrimaryFor(context) : AppColors.textTertiaryFor(context),
                ),
              ),
            ],
          ),
          if (!active)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 20),
              child: Text(
                '-',
                style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.textTertiaryFor(context)),
              ),
            )
          else
            ...entries.map((e) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm, left: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.teacherName.isNotEmpty ? '${e.subjectName} (${e.teacherName})' : e.subjectName,
                          style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (e.startTime.isNotEmpty || e.endTime.isNotEmpty)
                        Text(
                          '${e.startTime} - ${e.endTime}',
                          style: AppTextStyles.bodySmall(context).copyWith(color: color),
                        ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(BuildContext context, String day, String time, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.05) : AppColors.surfaceFor(context),
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
}

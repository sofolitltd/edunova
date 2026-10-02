import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../services/batch_service.dart' show SuggestedBatch;

class BatchDetailScreen extends StatelessWidget {
  const BatchDetailScreen({super.key, required this.batch});

  final SuggestedBatch batch;

  void _handleJoin(BuildContext context) {
    context.push(
      '/enroll-batch/${batch.id}',
      extra: {
        'batchName': batch.name,
        'price': batch.admissionFee,
        'type': batch.type,
        'classLevel': batch.classLevel,
        'days': batch.days,
        'startTime': batch.startTime,
        'endTime': batch.endTime,
        'schedule': batch.schedule,
        'shift': batch.shift,
        'courseName': batch.courseName,
        'admissionFee': batch.admissionFee,
        'noteFee': batch.noteFee,
        'monthlyFee': batch.monthlyFee,
        'maxStudents': batch.maxStudents,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'ব্যাচ বিস্তারিত'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.xl),
            _buildScheduleHighlight(context),
            const SizedBox(height: AppSpacing.xl),
            Text('ব্যাচের তথ্য', style: AppTextStyles.h3(context)),
            const SizedBox(height: AppSpacing.md),
            _buildInfoCard(context),
            const SizedBox(height: AppSpacing.xl),
            Text('ফি', style: AppTextStyles.h3(context)),
            const SizedBox(height: AppSpacing.md),
            _buildFeeCard(context),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: AppButton(
            text: 'ব্যাচে জয়েন করুন',
            onPressed: () => _handleJoin(context),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_rounded, color: Colors.white, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  batch.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (batch.courseName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              batch.courseName,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _headerBadge('ভর্তি ফি', '৳${batch.admissionFee}'),
              if (batch.maxStudents > 0)
                _headerBadge('উপলব্ধ আসন', '${batch.maxStudents} জন'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleHighlight(BuildContext context) {
    if (batch.days.isEmpty && batch.startTime.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.large,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'ক্লাসের দিন ও সময়',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (batch.days.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              batch.days.join(', '),
              style: AppTextStyles.h3(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
          if (batch.startTime.isNotEmpty && batch.endTime.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${batch.startTime} - ${batch.endTime}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        children: [
          if (batch.classLevel.isNotEmpty)
            _infoRow(context, Icons.class_rounded, 'শ্রেণি', batch.classLevel),
          if (batch.shift.isNotEmpty)
            _infoRow(context, Icons.wb_sunny_outlined, 'শিফট', batch.shift),
          if (batch.type.isNotEmpty)
            _infoRow(
              context,
              Icons.location_on_rounded,
              'ধরন',
              batch.type == 'offline' ? 'অফলাইন (বগুড়া শাখা)' : 'অনলাইন',
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildFeeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        children: [
          _infoRow(
            context,
            Icons.payments_outlined,
            'ভর্তি ফি',
            '৳${batch.admissionFee}',
          ),
          if (batch.noteFee > 0)
            _infoRow(
              context,
              Icons.description_outlined,
              'নোট ফি',
              '৳${batch.noteFee}',
            ),
          _infoRow(
            context,
            Icons.calendar_month_rounded,
            'মাসিক ফি',
            '৳${batch.monthlyFee}/মাস',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall(context)
                  .copyWith(color: AppColors.textSecondaryFor(context)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium(context)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

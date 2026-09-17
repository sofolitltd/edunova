import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/services/secure_storage_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../courses/services/course_service.dart';

class ClassTab extends ConsumerStatefulWidget {
  const ClassTab({super.key});

  @override
  ConsumerState<ClassTab> createState() => _ClassTabState();
}

class _ClassTabState extends ConsumerState<ClassTab> {
  final _service = CourseService();
  List<Enrollment> _enrolledBatches = [];
  bool _loading = true;

  static const _cardColors = [
    AppColors.primary,
    AppColors.success,
    AppColors.accent,
    AppColors.warning,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final token = await SecureStorageService().readToken();
      if (token == null) {
        setState(() => _loading = false);
        return;
      }
      final enrollments = await _service.getMyEnrollments(token);
      final approved = enrollments
          .where((e) => e.status == 'approved' && e.batchId != null)
          .toList();
      if (mounted) setState(() { _enrolledBatches = approved; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_enrolledBatches.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.school_outlined, size: 48, color: AppColors.textSecondaryFor(context)),
                      const SizedBox(height: AppSpacing.md),
                      Text('এখনো কোনো ব্যাচে ভর্তি নেই', style: AppTextStyles.bodyMedium(context)),
                    ],
                  ),
                )
              else
                ..._enrolledBatches.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildClassCard(
                      context,
                      enrollment: e,
                      color: _cardColors[i % _cardColors.length],
                    ),
                  );
                }),
              const SizedBox(height: AppSpacing.xxxxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required Enrollment enrollment,
    required Color color,
  }) {
    final subject = enrollment.batchName.isNotEmpty ? enrollment.batchName : enrollment.courseName;

    return GestureDetector(
      onTap: () => context.push('/class-detail', extra: {
        'batchId': enrollment.batchId,
        'subject': subject,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        enrollment.courseName,
                        style: AppTextStyles.bodySmall(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    'চলমান',
                    style: AppTextStyles.label(context).copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (enrollment.batchSchedule.isNotEmpty) ...[
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
                    Expanded(
                      child: Text(
                        enrollment.batchSchedule,
                        style: AppTextStyles.bodySmall(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondaryFor(context)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

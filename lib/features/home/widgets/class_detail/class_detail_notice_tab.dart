import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../services/batch_service.dart' show BatchNotice;

/// "Notice" tab: announcements sent specifically to this batch.
class ClassDetailNoticeTab extends StatelessWidget {
  const ClassDetailNoticeTab({
    super.key,
    required this.notices,
    required this.loading,
    required this.loaded,
    required this.color,
  });

  final List<BatchNotice> notices;
  final bool loading;
  final bool loaded;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (loading && !loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.campaign_outlined, size: 56, color: AppColors.textTertiaryFor(context)),
              const SizedBox(height: AppSpacing.md),
              Text('এখনো কোনো নোটিস নেই', style: AppTextStyles.bodyMedium(context)),
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
      itemCount: notices.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final n = notices[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context),
            borderRadius: AppRadius.small,
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.medium,
                ),
                child: Icon(Icons.campaign_rounded, size: 18, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (!n.readByMe)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.errorSurfaceFor(context),
                              borderRadius: AppRadius.small,
                            ),
                            child: Text(
                              'নতুন',
                              style: AppTextStyles.label(context).copyWith(
                                color: AppColors.errorFor(context),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(n.body, style: AppTextStyles.bodyMedium(context)),
                    const SizedBox(height: 6),
                    Text(_formatDate(n.sentAt), style: AppTextStyles.bodySmall(context)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} মিনিট আগে';
      if (diff.inHours < 24) return '${diff.inHours} ঘণ্টা আগে';
      if (diff.inDays < 7) return '${diff.inDays} দিন আগে';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

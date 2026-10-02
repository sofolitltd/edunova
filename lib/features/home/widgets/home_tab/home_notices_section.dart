import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../notifications/services/notification_history_service.dart';

/// "জরুরি নোটিশ" section on the home tab: latest notifications with an
/// unread badge and a link to the full notification history.
class HomeNoticesSection extends StatelessWidget {
  const HomeNoticesSection({
    super.key,
    required this.notifications,
    required this.onViewAll,
    required this.onItemTap,
    this.maxItems = 3,
  });

  final List<AppNotification> notifications;
  final VoidCallback onViewAll;
  final ValueChanged<AppNotification> onItemTap;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final items = notifications.take(maxItems).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.campaign_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('জরুরি নোটিশ', style: AppTextStyles.h3(context)),
              ],
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'সবগুলো দেখুন',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _NoticeItem(notification: items[i], onTap: () => onItemTap(items[i])),
              if (i != items.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ],
    );
  }
}

class _NoticeItem extends StatelessWidget {
  const _NoticeItem({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = _iconColor(notification.linkType);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: AppRadius.medium,
              ),
              child: Icon(_icon(notification.linkType), size: 18, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (!notification.readByMe) ...[
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
                        const SizedBox(width: 6),
                      ],
                      Text(_formatDate(notification.sentAt), style: AppTextStyles.bodySmall(context)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.title,
                    style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiaryFor(context)),
          ],
        ),
      ),
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

  IconData _icon(String linkType) {
    switch (linkType) {
      case 'exam':
        return Icons.quiz_rounded;
      case 'course':
        return Icons.school_rounded;
      case 'article':
        return Icons.article_rounded;
      case 'lesson':
        return Icons.menu_book_rounded;
      case 'calendar':
        return Icons.calendar_today_rounded;
      case 'doubt':
        return Icons.help_outline_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _iconColor(String linkType) {
    switch (linkType) {
      case 'exam':
        return AppColors.error;
      case 'course':
        return AppColors.primary;
      case 'article':
        return AppColors.accent;
      case 'lesson':
        return AppColors.success;
      case 'calendar':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }
}

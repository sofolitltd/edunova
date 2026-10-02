import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../services/notification_history_service.dart';

const _categoryLabels = {
  'urgent': 'জরুরি',
  'exam': 'পরীক্ষা',
  'class': 'ক্লাস',
  'vacation': 'ছুটি',
  'other': 'সাধারণ',
};

const _linkButtonLabels = {
  'exam': 'পরীক্ষা দেখুন',
  'course': 'ক্লাস দেখুন',
  'article': 'আর্টিকেল দেখুন',
  'lesson': 'হোমে যান',
  'calendar': 'ক্যালেন্ডার দেখুন',
  'doubt': 'হোমে যান',
  'enrollment': 'এনরোলমেন্ট দেখুন',
};

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key, required this.notification});

  final AppNotification notification;

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
        'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
      ];
      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour12:$minute $period';
    } catch (_) {
      return isoDate;
    }
  }

  void _handleLinkTap(BuildContext context) {
    switch (notification.linkType) {
      case 'exam':
        context.push('/exam-detail', extra: {'id': notification.linkId});
        break;
      case 'course':
        context.push('/class-detail', extra: {'id': notification.linkId});
        break;
      case 'article':
        context.push('/articles');
        break;
      case 'lesson':
      case 'calendar':
      case 'doubt':
        context.push('/home');
        break;
      case 'enrollment':
        context.push('/my-enrollments');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = notification.linkType.isNotEmpty;

    return AppScaffold(
      appBar: const AppAppBar(title: 'নোটিফিকেশন বিস্তারিত'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: notification.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.iconColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: notification.iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _categoryLabels[notification.category] ?? '',
                          style: AppTextStyles.bodySmall(context).copyWith(
                            color: notification.iconColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(notification.sentAt),
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              notification.title,
              style: AppTextStyles.h2(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              notification.body,
              style: AppTextStyles.bodyLarge(context).copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            if (hasLink) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: _linkButtonLabels[notification.linkType] ?? 'দেখুন',
                onPressed: () => _handleLinkTap(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

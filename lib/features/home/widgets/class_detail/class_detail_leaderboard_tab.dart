import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../services/batch_service.dart' show LeaderboardEntry;

/// "Leaderboard" tab: ranked students by total exam score for this batch.
class ClassDetailLeaderboardTab extends StatelessWidget {
  const ClassDetailLeaderboardTab({
    super.key,
    required this.leaderboard,
    required this.loading,
    required this.loaded,
    required this.color,
    required this.myUserId,
  });

  final List<LeaderboardEntry> leaderboard;
  final bool loading;
  final bool loaded;
  final Color color;
  final int? myUserId;

  static const _medalColors = [Color(0xFFFBBF24), Color(0xFF94A3B8), Color(0xFFB45309)];

  @override
  Widget build(BuildContext context) {
    if (loading && !loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (leaderboard.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_outlined, size: 56, color: AppColors.textTertiaryFor(context)),
              const SizedBox(height: AppSpacing.md),
              Text('এখনো কোনো ফলাফল নেই', style: AppTextStyles.bodyMedium(context)),
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
      itemCount: leaderboard.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final e = leaderboard[i];
        final isMe = myUserId != null && myUserId == e.userId;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isMe ? color.withValues(alpha: 0.06) : AppColors.surfaceFor(context),
            borderRadius: AppRadius.small,
            border: Border.all(color: isMe ? color.withValues(alpha: 0.3) : AppColors.borderFor(context)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${i + 1}',
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w800,
                    color: i < 3 ? _medalColors[i] : AppColors.textTertiaryFor(context),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Text(
                  e.fullName.isNotEmpty ? e.fullName[0].toUpperCase() : '?',
                  style: AppTextStyles.label(context).copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? '${e.fullName} (তুমি)' : e.fullName,
                      style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text('${e.examsTaken} পরীক্ষা দিয়েছে', style: AppTextStyles.bodySmall(context)),
                  ],
                ),
              ),
              Text(
                '${e.totalScore}',
                style: AppTextStyles.h3(context).copyWith(color: color),
              ),
            ],
          ),
        );
      },
    );
  }
}

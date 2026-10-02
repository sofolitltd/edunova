import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme_provider.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/notification_service.dart';
import '../../../../shared/services/secure_storage_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../courses/services/course_service.dart';
import '../../../daily_content/services/daily_content_service.dart';
import '../../../notifications/services/notification_history_service.dart';
import '../../../results/services/results_service.dart';
import '../../services/batch_service.dart';
import '../../widgets/home_tab/home_batch_progress_card.dart';
import '../../widgets/home_tab/home_cta_banner.dart';
import '../../widgets/home_tab/home_daily_challenge_banner.dart';
import '../../widgets/home_tab/home_notices_section.dart';
import '../../widgets/home_tab/home_progress_summary_card.dart';
import '../../widgets/home_tab/home_quick_access_grid.dart';
import '../../widgets/home_tab/home_suggested_batches_card.dart';
import '../../widgets/home_tab/home_welcome_card.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  final CourseService _service = CourseService();
  final ResultsService _resultsService = ResultsService();
  final NotificationHistoryService _notificationService =
      NotificationHistoryService();
  final DailyContentService _dailyContentService = DailyContentService();
  final BatchService _batchService = BatchService();
  ResultSummary _resultSummary = ResultSummary.empty();
  Enrollment? _activeEnrollment;
  List<AppNotification> _notifications = [];
  List<SuggestedBatch> _suggestedBatches = [];
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadResultSummary();
    _loadRoutine();
    _loadNotifications();
    _loadStreak();
    _loadSuggestedBatches();
    NotificationService.refreshSignal.addListener(_onPushReceived);
  }

  @override
  void dispose() {
    NotificationService.refreshSignal.removeListener(_onPushReceived);
    super.dispose();
  }

  void _onPushReceived() {
    _loadNotifications();
    _loadRoutine();
  }

  Future<void> _loadSuggestedBatches() async {
    try {
      final token = await SecureStorageService().readToken();
      final batches = await _batchService.getSuggestedBatches(token);
      if (mounted) setState(() => _suggestedBatches = batches);
    } catch (_) {}
  }

  Future<void> _loadResultSummary() async {
    try {
      final token = await SecureStorageService().readToken();
      final summary = await _resultsService.getSummary(token: token);
      if (mounted) setState(() => _resultSummary = summary);
    } catch (_) {}
  }

  Future<void> _loadRoutine() async {
    try {
      final token = await SecureStorageService().readToken();
      if (token == null) return;
      final enrollments = await _service.getMyEnrollments(token);
      final approved = enrollments.where(
        (e) =>
            e.status == 'approved' &&
            e.batchSchedule.isNotEmpty &&
            e.batchId != null,
      );
      if (mounted && approved.isNotEmpty) {
        setState(() => _activeEnrollment = approved.first);
      }
    } catch (_) {}
  }

  Future<void> _loadNotifications() async {
    try {
      final token = await SecureStorageService().readToken();
      if (token == null) return;
      final notifications = await _notificationService.getNotifications(token);
      if (mounted) setState(() => _notifications = notifications);
    } catch (_) {}
  }

  Future<void> _loadStreak() async {
    try {
      final token = await SecureStorageService().readToken();
      final streak = await _dailyContentService.getStreak(token: token);
      if (mounted) setState(() => _streak = streak);
    } catch (_) {}
  }

  void _handleNoticeTap(AppNotification notification) {
    if (!notification.readByMe) {
      final token = ref.read(authProvider).token;
      if (token != null) {
        _notificationService.markAsRead(token, notification.id);
        setState(() {
          final idx = _notifications.indexWhere((n) => n.id == notification.id);
          if (idx >= 0) {
            _notifications[idx] = AppNotification(
              id: notification.id,
              title: notification.title,
              body: notification.body,
              target: notification.target,
              targetId: notification.targetId,
              linkType: notification.linkType,
              linkId: notification.linkId,
              sentAt: notification.sentAt,
              readByMe: true,
            );
          }
        });
      }
    }
    context.push('/notification-detail', extra: notification);
  }

  void _handleOpenBatch(SuggestedBatch batch) {
    HapticFeedback.selectionClick();
    context.push('/batches/${batch.id}', extra: batch);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final firstName = (user?.fullName ?? '').trim().split(' ').first;
    final unreadCount = _notifications.where((n) => !n.readByMe).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => Future.wait([
          _loadResultSummary(),
          _loadRoutine(),
          _loadNotifications(),
          _loadStreak(),
          _loadSuggestedBatches(),
        ]),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                MediaQuery.of(context).padding.top + AppSpacing.lg,
                AppSpacing.screenHorizontal,
                AppSpacing.xxxxxl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Welcome & status ──────────────────
                  HomeWelcomeCard(
                    l10n: l10n,
                    isDark: isDark,
                    user: user,
                    firstName: firstName,
                    streak: _streak,
                    overallPercent: _resultSummary.overallPercent,
                    hasResults: _resultSummary.totalExams > 0,
                    unreadNotificationCount: unreadCount,
                    onSearchTap: () => context.push('/courses'),
                    onNotificationsTap: () {
                      HapticFeedback.selectionClick();
                      context.push('/notifications');
                    },
                    onThemeToggle: () {
                      HapticFeedback.selectionClick();
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                    onStreakTap: () => context.push('/daily-content'),
                    onResultsTap: () => context.push('/results'),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Notices ───────────────────────────
                  if (_notifications.isNotEmpty) ...[
                    HomeNoticesSection(
                      notifications: _notifications,
                      onViewAll: () => context.push('/notifications'),
                      onItemTap: _handleNoticeTap,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // ── My Batch & Progress ───────────────
                  if (_activeEnrollment != null) ...[
                    Text(
                      'আমার ব্যাচ ও পাঠক্রম',
                      style: AppTextStyles.h3(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    HomeBatchProgressCard(
                      enrollment: _activeEnrollment!,
                      bySubject: _resultSummary.bySubject,
                      onBatchTap: () => context.push(
                        '/class-detail',
                        extra: {
                          'batchId': _activeEnrollment!.batchId ?? 0,
                          'subject': _activeEnrollment!.batchName.isNotEmpty
                              ? _activeEnrollment!.batchName
                              : _activeEnrollment!.courseName,
                          'color': AppColors.primary,
                        },
                      ),
                      onSubjectTap: () => context.push('/results'),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ] else if (_resultSummary.totalExams > 0) ...[
                    HomeProgressSummaryCard(
                      summary: _resultSummary,
                      onTap: () => context.push('/results'),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // ── Suggested Batches (no active batch yet) ──
                  if (_activeEnrollment == null &&
                      _suggestedBatches.isNotEmpty) ...[
                    Text(
                      'আপনার ক্লাসের জন্য ব্যাচ',
                      style: AppTextStyles.h3(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    HomeSuggestedBatchesCard(
                      batches: _suggestedBatches,
                      onTap: _handleOpenBatch,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // ── Quick Access ─────────────────────
                  Text('দ্রুত প্রবেশ', style: AppTextStyles.h3(context)),
                  const SizedBox(height: AppSpacing.lg),
                  HomeQuickAccessGrid(
                    items: [
                      QuickAccessItem(
                        icon: Icons.live_tv_rounded,
                        label: 'লাইভ পরীক্ষা',
                        color: AppColors.error,
                        onTap: () => context.push('/live-exams'),
                      ),
                      QuickAccessItem(
                        icon: Icons.note_alt_rounded,
                        label: 'নোটস',
                        color: AppColors.primary,
                        onTap: () => context.push('/notes'),
                      ),
                      QuickAccessItem(
                        icon: Icons.lightbulb_rounded,
                        label: 'দৈনিক শেখার',
                        color: AppColors.warning,
                        onTap: () => context.push('/daily-content'),
                      ),
                      QuickAccessItem(
                        icon: Icons.sports_esports_rounded,
                        label: 'অনুশীলন',
                        color: AppColors.success,
                        onTap: () => context.push('/practice'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Daily Challenge ───────────────────
                  HomeDailyChallengeBanner(
                    streak: _streak,
                    onTap: () => context.push('/daily-content'),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Parenting Hub ─────────────────────
                  HomeCtaBanner(
                    icon: Icons.article_rounded,
                    title: 'পেরেন্টিং হাব',
                    subtitle: 'শিশু বিকাস, মানসিক স্বাস্থ্য ও পেরেন্টিং টিপস',
                    colors: [AppColors.accent, const Color(0xFFEC4899)],
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.push('/articles');
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

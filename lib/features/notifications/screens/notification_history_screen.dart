import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_filter_chip.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/services/notification_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/notification_history_service.dart';

const _categoryFilters = [
  {'value': 'all', 'label': 'সব'},
  {'value': 'urgent', 'label': 'জরুরি'},
  {'value': 'exam', 'label': 'পরীক্ষা'},
  {'value': 'class', 'label': 'ক্লাস'},
  {'value': 'vacation', 'label': 'ছুটি'},
];

class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  ConsumerState<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends ConsumerState<NotificationHistoryScreen> {
  final NotificationHistoryService _service = NotificationHistoryService();
  final TextEditingController _searchController = TextEditingController();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  bool _hasMore = true;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  List<AppNotification> get _filteredNotifications {
    var list = _notifications;
    if (_selectedCategory != 'all') {
      list = list.where((n) => n.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.body.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  bool get _isFiltering =>
      _searchQuery.isNotEmpty || _selectedCategory != 'all';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    NotificationService.refreshSignal.addListener(_onPushReceived);
  }

  @override
  void dispose() {
    NotificationService.refreshSignal.removeListener(_onPushReceived);
    _searchController.dispose();
    super.dispose();
  }

  void _onPushReceived() {
    _page = 1;
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final auth = ref.read(authProvider);
    if (auth.token == null) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final notifications =
          await _service.getNotifications(auth.token!, page: _page);
      setState(() {
        if (_page == 1) {
          _notifications = notifications;
        } else {
          _notifications.addAll(notifications);
        }
        _hasMore = notifications.length == 20;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    _page++;
    await _loadNotifications();
  }

  Future<void> _markAsRead(int id) async {
    final auth = ref.read(authProvider);
    if (auth.token == null) return;
    await _service.markAsRead(auth.token!, id);
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        _notifications[idx] = AppNotification(
          id: _notifications[idx].id,
          title: _notifications[idx].title,
          body: _notifications[idx].body,
          target: _notifications[idx].target,
          targetId: _notifications[idx].targetId,
          linkType: _notifications[idx].linkType,
          linkId: _notifications[idx].linkId,
          sentAt: _notifications[idx].sentAt,
          readByMe: true,
        );
      }
    });
  }

  Future<void> _markAllAsRead() async {
    final auth = ref.read(authProvider);
    if (auth.token == null) return;
    await _service.markAllAsRead(auth.token!);
    setState(() {
      _notifications = _notifications
          .map((n) => AppNotification(
                id: n.id,
                title: n.title,
                body: n.body,
                target: n.target,
                targetId: n.targetId,
                linkType: n.linkType,
                linkId: n.linkId,
                sentAt: n.sentAt,
                readByMe: true,
              ))
          .toList();
    });
  }

  void _handleTap(AppNotification notif) {
    if (!notif.readByMe) _markAsRead(notif.id);
    context.push('/notification-detail', extra: notif);
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

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _notifications.where((n) => !n.readByMe).length;

    return AppScaffold(
      appBar: AppAppBar(
        title: 'নোটিফিকেশন',
        trailing: unreadCount > 0
            ? TextButton(
                onPressed: _markAllAsRead,
                child: Text(
                  'সব পড়া হয়েছে',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.primary,
                  ),
                ),
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.sm,
            AppSpacing.screenHorizontal,
            0,
          ),
          child: AppSearchBar(
            controller: _searchController,
            hintText: 'নোটিফিকেশন খুঁজুন...',
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            itemCount: _categoryFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = _categoryFilters[i];
              return AppFilterChip(
                label: cat['label']!,
                isSelected: _selectedCategory == cat['value'],
                onTap: () =>
                    setState(() => _selectedCategory = cat['value']!),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildList() {
    if (_isLoading && _notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(_error!, textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(context)),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  _page = 1;
                  _loadNotifications();
                },
                child: const Text('আবার চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_rounded,
                size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text('কোনো নোটিফিকেশন নেই',
                style: AppTextStyles.bodyLarge(context).copyWith(
                  color: AppColors.textSecondary,
                )),
          ],
        ),
      );
    }

    final filtered = _filteredNotifications;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text('কোনো ফলাফল পাওয়া যায়নি',
                style: AppTextStyles.bodyLarge(context).copyWith(
                  color: AppColors.textSecondary,
                )),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _page = 1;
        await _loadNotifications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.sm,
        ),
        itemCount: filtered.length + (_hasMore && !_isFiltering ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filtered.length) {
            _loadMore();
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildNotificationTile(filtered[index]);
        },
      ),
    );
  }

  Widget _buildNotificationTile(AppNotification notif) {
    final isRead = notif.readByMe;
    final hasLink = notif.linkType.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isRead
            ? Theme.of(context).cardColor
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead
              ? Theme.of(context).dividerColor.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleTap(notif),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: notif.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    notif.icon,
                    color: notif.iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                fontWeight: isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.body,
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            _formatDate(notif.sentAt),
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: AppColors.textSecondary.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                          if (hasLink) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

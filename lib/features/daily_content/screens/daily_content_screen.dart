import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../services/daily_content_service.dart';

class DailyContentScreen extends ConsumerStatefulWidget {
  const DailyContentScreen({super.key});

  @override
  ConsumerState<DailyContentScreen> createState() => _DailyContentScreenState();
}

class _DailyContentScreenState extends ConsumerState<DailyContentScreen> {
  final _service = DailyContentService();
  List<DailyContentItem> _items = [];
  int _streak = 0;
  bool _loading = true;
  String _selectedType = 'all';

  static const _types = [
    {'value': 'all', 'label': 'All', 'icon': Icons.dashboard_rounded, 'color': AppColors.primary},
    {'value': 'vocabulary', 'label': 'Vocab', 'icon': Icons.translate_rounded, 'color': Color(0xFF3B82F6)},
    {'value': 'math', 'label': 'Math', 'icon': Icons.calculate_rounded, 'color': Color(0xFF8B5CF6)},
    {'value': 'science', 'label': 'Science', 'icon': Icons.science_rounded, 'color': Color(0xFF10B981)},
    {'value': 'news', 'label': 'News', 'icon': Icons.newspaper_rounded, 'color': Color(0xFFF59E0B)},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storage = SecureStorageService();
    final token = await storage.readToken();
    try {
      final type = _selectedType == 'all' ? null : _selectedType;
      final items = await _service.getDailyContent(token: token, contentType: type);
      final streak = await _service.getStreak(token: token);
      if (mounted) setState(() { _items = items; _streak = streak; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceFor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('দৈনিক শেখার', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text('$_streak', style: AppTextStyles.label(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  // Type selector
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                      itemCount: _types.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final t = _types[index];
                        final selected = _selectedType == t['value'];
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedType = t['value'] as String);
                            _loadData();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? t['color'] as Color : AppColors.surfaceFor(context),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                color: selected ? t['color'] as Color : AppColors.borderFor(context),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(t['icon'] as IconData, size: 16, color: selected ? Colors.white : AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(t['label'] as String, style: TextStyle(
                                  color: selected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Content list
                  Expanded(
                    child: _items.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) => _buildContentCard(_items[index]),
                          ),
                  ),
                ],
              ),
            ),
    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text('No Content Yet', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          Text('New content appears daily!', style: AppTextStyles.bodySmall(context)),
        ],
      ),
    );
  }

  Widget _buildContentCard(DailyContentItem item) {
    final typeInfo = _types.firstWhere(
      (t) => t['value'] == item.contentType,
      orElse: () => _types[0],
    );
    final color = typeInfo['color'] as Color;

    return GestureDetector(
      onTap: () => _showContentDetail(item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppRadius.small,
              ),
              child: Icon(typeInfo['icon'] as IconData, size: 20, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(item.contentType.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContentDetail(DailyContentItem item) {
    final storage = SecureStorageService();
    storage.readToken().then((token) {
      _service.markContentViewed(item.id, token: token);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, controller) => Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundFor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: Text(item.title, style: AppTextStyles.h3(context))),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(item.body, style: AppTextStyles.bodyMedium(context).copyWith(height: 1.8)),
                    if (item.answer.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: AppRadius.medium,
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Answer / Explanation', style: AppTextStyles.label(context).copyWith(color: AppColors.success)),
                            const SizedBox(height: 8),
                            Text(item.answer, style: AppTextStyles.bodyMedium(context)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../services/article_service.dart';
import 'article_detail_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final ArticleService _articleService = ArticleService();
  List<Article> _articles = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'all';

  static const Map<String, String> _categoryLabels = {
    'all': 'সব',
    'screen_time': 'স্ক্রিন টাইম',
    'teen_parenting': 'কিশোর পেরেন্টিং',
    'exam_stress': 'পরীক্ষার চাপ',
    'mental_health': 'মানসিক স্বাস্থ্য',
    'study_habits': 'পড়াশোনা',
    'child-development': 'শিশু বিকাশ',
  };

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      final articles = await _articleService.getPublishedArticles();
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Article> get _filteredArticles {
    if (_selectedCategory == 'all') return _articles;
    return _articles.where((a) => a.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppAppBar(
        title: 'পেরেন্টিং হাব',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: AppSpacing.md),
                        Text('সমস্যা হয়েছে',
                            style: AppTextStyles.bodyLarge(context)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(_error!,
                            style: AppTextStyles.bodyMedium(context),
                            textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _error = null;
                            });
                            _loadArticles();
                          },
                          child: const Text('আবার চেষ্টা করুন'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // ── Category Filter ──
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categoryLabels.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final key = _categoryLabels.keys.elementAt(index);
                          final isSelected = _selectedCategory == key;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCategory = key);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceFor(context),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.borderFor(context),
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                _categoryLabels[key]!,
                                style:
                                    AppTextStyles.bodySmall(context).copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondaryFor(context),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Articles Count ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal),
                      child: Row(
                        children: [
                          Text(
                            '${_filteredArticles.length}টি আর্টিকেল',
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: AppColors.textTertiaryFor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Articles List ──
                    Expanded(
                      child: _filteredArticles.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.article_outlined,
                                      size: 48,
                                      color:
                                          AppColors.textSecondaryFor(context)),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'কোনো আর্টিকেল পাওয়া যায়নি',
                                    style: AppTextStyles.bodyLarge(context),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadArticles,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.screenHorizontal),
                                itemCount: _filteredArticles.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.lg),
                                itemBuilder: (context, index) {
                                  final article = _filteredArticles[index];
                                  return _ArticleCard(
                                    article: article,
                                    categoryLabels: _categoryLabels,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ArticleDetailScreen(
                                            article: article,
                                            categoryLabels: _categoryLabels,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final Map<String, String> categoryLabels;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.article,
    required this.categoryLabels,
    required this.onTap,
  });

  Color _categoryColor(String category) {
    switch (category) {
      case 'screen_time':
        return const Color(0xFFEF4444);
      case 'teen_parenting':
        return const Color(0xFF8B5CF6);
      case 'exam_stress':
        return const Color(0xFFF59E0B);
      case 'mental_health':
        return const Color(0xFF10B981);
      case 'study_habits':
        return const Color(0xFF3B82F6);
      case 'child-development':
        return const Color(0xFFF472B6);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(article.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: Image.network(
                  article.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            catColor.withValues(alpha: 0.8),
                            catColor,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.article_rounded,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: catColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      categoryLabels[article.category] ?? article.category,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: catColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Title
                  Text(
                    article.title,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Preview
                  Text(
                    article.content.length > 120
                        ? '${article.content.substring(0, 120)}...'
                        : article.content,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.textSecondaryFor(context),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Read more
                  Row(
                    children: [
                      Text(
                        'বিস্তারিত পড়ুন',
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

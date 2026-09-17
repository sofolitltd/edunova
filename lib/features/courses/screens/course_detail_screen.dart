import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../services/course_service.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final int courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  final CourseService _service = CourseService();
  Course? _course;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCourse();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCourse() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final course = await _service.getCourseById(widget.courseId);
      setState(() {
        _course = course;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  List<dynamic> _parseJsonList(String raw) {
    if (raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(
        appBar: AppAppBar(title: ''),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _course == null) {
      return AppScaffold(
        appBar: const AppAppBar(title: ''),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(_error ?? 'Course not found',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(context)),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: _loadCourse,
                child: const Text('আবার চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      );
    }

    final course = _course!;
    final accent = _parseColor(course.color);

    return AppScaffold(
      body: Column(
        children: [
          // ── Header ───────────────────────
          _buildHeader(course, accent),

          // ── Tab Bar ──────────────────────
          Container(
            color: Theme.of(context).cardColor,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondaryFor(context),
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'সারসংক্ষেপ'),
                Tab(text: 'পাঠ্যক্রম'),
                Tab(text: 'বৈশিষ্ট্য'),
              ],
            ),
          ),

          // ── Tab Content ──────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(course),
                _buildSyllabusTab(course),
                _buildFeaturesTab(course),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(course, accent),
    );
  }

  Widget _buildHeader(Course course, Color accent) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App Bar Row ─────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    course.type == 'free' ? 'ফ্রী' : course.type == 'online' ? 'অনলাইন' : 'অফলাইন',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),

            // ── Course Info ─────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges row
                  Row(
                    children: [
                      if (course.badge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            course.badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (course.badge.isNotEmpty) const SizedBox(width: 8),
                      if (course.classLevel.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Class ${course.classLevel}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    course.titleBn.isNotEmpty ? course.titleBn : course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subject + Teacher
                  if (course.subject.isNotEmpty)
                    Text(
                      course.subject,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (course.teacher.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.person_rounded, size: 16,
                            color: Colors.white.withValues(alpha: 0.8)),
                        const SizedBox(width: 4),
                        Text(
                          course.teacher,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    children: [
                      _headerStat(Icons.star_rounded, '${course.rating.toStringAsFixed(1)} (${course.reviewsCount})'),
                      const SizedBox(width: 16),
                      _headerStat(Icons.people_rounded, '${course.studentsCount} শিক্ষার্থী'),
                      const SizedBox(width: 16),
                      _headerStat(Icons.menu_book_rounded, '${course.classesCount} ক্লাস'),
                      const SizedBox(width: 16),
                      _headerStat(Icons.quiz_rounded, '${course.examsCount} পরীক্ষা'),
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

  Widget _headerStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Overview Tab ──────────────────────
  Widget _buildOverviewTab(Course course) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          _sectionTitle('কোর্স পরিচিতি'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            course.description.isNotEmpty ? course.description : 'বিবরণ নেই।',
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.textSecondaryFor(context),
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Info Cards
          _sectionTitle('তথ্য'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _infoCard(Icons.access_time_rounded, 'সময়কাল', course.duration.isNotEmpty ? course.duration : 'N/A')),
              const SizedBox(width: 10),
              Expanded(child: _infoCard(Icons.schedule_rounded, 'সূচি', course.schedule.isNotEmpty ? course.schedule : 'N/A')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _infoCard(Icons.category_rounded, 'ধরন', course.type.isNotEmpty ? course.type.toUpperCase() : 'N/A')),
              const SizedBox(width: 10),
              Expanded(child: _infoCard(Icons.school_rounded, 'ক্লাস', course.classLevel.isNotEmpty ? 'Class ${course.classLevel}' : 'N/A')),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Instructors
          if (course.instructors.isNotEmpty) ...[
            _sectionTitle('শিক্ষকমণ্ডলী'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              course.instructors,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondaryFor(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Schedule
          if (course.schedule.isNotEmpty) ...[
            _sectionTitle('সাপ্তাহিক সূচি'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                course.schedule,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Syllabus Tab ──────────────────────
  Widget _buildSyllabusTab(Course course) {
    final curriculum = _parseJsonList(course.curriculum);

    if (curriculum.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: 48,
                color: AppColors.textTertiaryFor(context)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'পাঠ্যক্রম তথ্য পাওয়া যায়নি',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondaryFor(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      itemCount: curriculum.length,
      itemBuilder: (context, index) {
        final item = curriculum[index];
        final month = item is Map ? (item['month'] ?? 'Month ${index + 1}') : 'Month ${index + 1}';
        final topics = item is Map && item['topics'] is List ? item['topics'] as List : [];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderFor(context).withValues(alpha: 0.3)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 14),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              title: Text(
                month.toString(),
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: topics.isNotEmpty
                  ? Text(
                      '${topics.length} টি বিষয়',
                      style: AppTextStyles.bodySmall(context),
                    )
                  : null,
              children: topics.map<Widget>((topic) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.play_circle_outline_rounded,
                      size: 20, color: AppColors.primary),
                  title: Text(
                    topic.toString(),
                    style: AppTextStyles.bodySmall(context),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // ── Features Tab ──────────────────────
  Widget _buildFeaturesTab(Course course) {
    final features = _parseJsonList(course.features);

    if (features.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.featured_play_list_rounded, size: 48,
                color: AppColors.textTertiaryFor(context)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'বৈশিষ্ট্য তথ্য পাওয়া যায়নি',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondaryFor(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        final text = feature.toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderFor(context).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Bottom Bar ────────────────────────
  Widget _buildBottomBar(Course course, Color accent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (course.type == 'free')
                  Text(
                    'ফ্রী',
                    style: AppTextStyles.h3(context).copyWith(color: AppColors.success),
                  )
                else ...[
                  Text(
                    '৳${course.price}',
                    style: AppTextStyles.h3(context).copyWith(color: AppColors.primary),
                  ),
                  if (course.oldPrice > 0)
                    Text(
                      '৳${course.oldPrice}',
                      style: AppTextStyles.bodySmall(context).copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textTertiaryFor(context),
                      ),
                    ),
                ],
              ],
            ),
            const SizedBox(width: 16),

            // Enroll Button
            Expanded(
              child: AppButton(
                text: 'এনরোল করুন',
                onPressed: () {
                  context.push('/enroll/${course.id}', extra: {
                    'courseName': course.title,
                    'courseTitleBn': course.titleBn,
                    'price': course.price,
                    'type': course.type,
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: AppTextStyles.h3(context),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall(context).copyWith(
              color: AppColors.textTertiaryFor(context),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

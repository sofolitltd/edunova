import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../services/course_service.dart';

class CoursesScreen extends StatefulWidget {
  final String initialType;
  const CoursesScreen({super.key, this.initialType = 'all'});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final CourseService _service = CourseService();
  List<Course> _courses = [];
  bool _isLoading = true;
  String? _error;
  String _selectedClass = 'all';
  late String _selectedType;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _prefillClassThenLoad();
  }

  Future<void> _prefillClassThenLoad() async {
    // Default to the student's own class so most guardians see relevant
    // courses immediately without needing to pick a filter first.
    final user = await SecureStorageService().readUser();
    final studentClass = user['studentClass'];
    if (mounted && studentClass != null && studentClass.isNotEmpty) {
      setState(() => _selectedClass = studentClass);
    }
    _loadCourses();
  }

  static const List<Map<String, String>> _classLevels = [
    {'value': 'all', 'label': 'সব'},
    {'value': '3', 'label': '৩র্থ'},
    {'value': '4', 'label': '৪র্থ'},
    {'value': '5', 'label': '৫ম'},
    {'value': '6', 'label': '৬ষ্ঠ'},
    {'value': '7', 'label': '৭ম'},
    {'value': '8', 'label': '৮ম'},
  ];

  static const List<Map<String, String>> _typeFilters = [
    {'value': 'all', 'label': 'সব ধরন'},
    {'value': 'free', 'label': 'ফ্রী'},
    {'value': 'online', 'label': 'অনলাইন'},
    {'value': 'offline', 'label': 'অফলাইন'},
  ];

  Future<void> _loadCourses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final courses = await _service.getCourses(
        classLevel: _selectedClass == 'all' ? null : _selectedClass,
        type: _selectedType == 'all' ? null : _selectedType,
      );
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Course> get _filteredCourses {
    if (_search.isEmpty) return _courses;
    final q = _search.toLowerCase();
    return _courses.where((c) =>
      c.title.toLowerCase().contains(q) ||
      c.titleBn.contains(_search) ||
      c.subject.toLowerCase().contains(q)
    ).toList();
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderFor(context)),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.label(context).copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppAppBar(
        title: 'কোর্সসমূহ',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // ── Search ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'কোর্স খুঁজুন...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: AppColors.surfaceFor(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Type filter ──────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              itemCount: _typeFilters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final tf = _typeFilters[i];
                return _buildFilterChip(
                  tf['label']!,
                  _selectedType == tf['value'],
                  () {
                    setState(() => _selectedType = tf['value']!);
                    _loadCourses();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Class filter ─────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              itemCount: _classLevels.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cl = _classLevels[i];
                return _buildFilterChip(
                  cl['value'] == 'all' ? cl['label']! : 'ক্লাস ${cl['label']}',
                  _selectedClass == cl['value'],
                  () {
                    setState(() => _selectedClass = cl['value']!);
                    _loadCourses();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Course List ─────────────────────
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(_error!, textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(context)),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _loadCourses,
              child: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredCourses;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64,
                color: AppColors.textSecondaryFor(context).withOpacity(0.3)),
            const SizedBox(height: AppSpacing.md),
            Text('কোনো কোর্স পাওয়া যায়নি',
                style: AppTextStyles.bodyLarge(context).copyWith(
                  color: AppColors.textSecondaryFor(context),
                )),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCourses,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.sm,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) => _buildCourseCard(filtered[index]),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    final accentColor = _parseColor(course.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context).withOpacity(0.1)),
        boxShadow: AppShadow.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient Header ──────────────
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (course.badge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
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
                      const Spacer(),
                      Text(
                        course.titleBn.isNotEmpty ? course.titleBn : course.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (course.classLevel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Class ${course.classLevel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (course.type.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: course.type == 'free'
                          ? Colors.green.withOpacity(0.8)
                          : course.type == 'online'
                              ? Colors.blue.withOpacity(0.8)
                              : Colors.orange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course.type == 'free' ? 'ফ্রী' : course.type == 'online' ? 'অনলাইন' : 'অফলাইন',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Content ──────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating + Students
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 18, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text(
                      course.rating.toStringAsFixed(1),
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${course.studentsCount} শিক্ষার্থী',
                      style: AppTextStyles.bodySmall(context),
                    ),
                  ],
                ),

                // Instructors
                if (course.instructors.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.people_rounded, size: 16, color: AppColors.textTertiaryFor(context)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          course.instructors,
                          style: AppTextStyles.bodySmall(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),

                // Stats Row
                Row(
                  children: [
                    _statChip(Icons.menu_book_rounded, '${course.classesCount} ক্লাস'),
                    const SizedBox(width: 8),
                    _statChip(Icons.quiz_rounded, '${course.examsCount} পরীক্ষা'),
                    if (course.duration.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _statChip(Icons.access_time_rounded, course.duration),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Price + Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'শুরু থেকে',
                          style: AppTextStyles.bodySmall(context).copyWith(fontSize: 11),
                        ),
                        Row(
                          children: [
                            Text(
                              '৳${course.price}',
                              style: AppTextStyles.h3(context).copyWith(color: AppColors.primary),
                            ),
                            if (course.oldPrice > 0) ...[
                              const SizedBox(width: 6),
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
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push('/courses/${course.id}'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'বিস্তারিত',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

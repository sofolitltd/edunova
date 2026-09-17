import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/course_service.dart';

class MyEnrollmentsScreen extends ConsumerStatefulWidget {
  const MyEnrollmentsScreen({super.key});

  @override
  ConsumerState<MyEnrollmentsScreen> createState() => _MyEnrollmentsScreenState();
}

class _MyEnrollmentsScreenState extends ConsumerState<MyEnrollmentsScreen> {
  List<Enrollment> _enrollments = [];
  bool _isLoading = true;
  String? _error;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = ref.read(authProvider).token;
      if (token == null) {
        setState(() {
          _error = 'লগইন করুন';
          _isLoading = false;
        });
        return;
      }

      final service = CourseService();
      final enrollments = await service.getMyEnrollments(token);
      setState(() {
        _enrollments = enrollments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Enrollment> get _filteredEnrollments {
    if (_filter == 'all') return _enrollments;
    return _enrollments.where((e) => e.status == _filter).toList();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy', 'en_US').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatPayment(String method) {
    const map = {
      'bkash': 'bKash',
      'nagad': 'Nagad',
      'rocket': 'Rocket',
      'cash': 'ক্যাশ',
      'card': 'কার্ড',
    };
    return map[method] ?? method;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'আমার এনরোলমেন্ট'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadEnrollments,
                  child: Column(
                    children: [
                      _buildStats(),
                      _buildFilterTabs(),
                      Expanded(child: _buildList()),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(_error!, textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(context)),
            const SizedBox(height: AppSpacing.lg),
            AppButton(text: 'আবার চেষ্টা করুন', onPressed: _loadEnrollments),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final total = _enrollments.length;
    final approved = _enrollments.where((e) => e.status == 'approved').length;
    final pending = _enrollments.where((e) => e.status == 'pending').length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _statChip('$total', 'মোট', AppColors.primary),
          const SizedBox(width: 10),
          _statChip('$approved', 'অনুমোদিত', AppColors.success),
          const SizedBox(width: 10),
          _statChip('$pending', 'অপেক্ষমাণ', AppColors.warning),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          _filterTab('all', 'সব'),
          const SizedBox(width: 8),
          _filterTab('approved', 'অনুমোদিত'),
          const SizedBox(width: 8),
          _filterTab('pending', 'অপেক্ষমাণ'),
          const SizedBox(width: 8),
          _filterTab('rejected', 'বাতিল'),
        ],
      ),
    );
  }

  Widget _filterTab(String value, String label) {
    final isActive = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.borderFor(context),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondaryFor(context),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    final filtered = _filteredEnrollments;

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 56,
                  color: AppColors.textTertiaryFor(context)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _filter == 'all'
                    ? 'আপনি এখনো কোনো কোর্সে এনরোল করেননি'
                    : 'কোনো $_filter এনরোলমেন্ট নেই',
                style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.textSecondaryFor(context)),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: 'কোর্স দেখুন',
                onPressed: () => context.push('/courses'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildEnrollmentCard(filtered[index]),
    );
  }

  Widget _buildEnrollmentCard(Enrollment e) {
    final statusCol = _statusColor(e.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppShadow.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.courseName.isNotEmpty ? e.courseName : 'কোর্স',
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.courseType == 'free' ? 'ফ্রী কোর্স' : 'পেইড কোর্স',
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: AppColors.textSecondaryFor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusCol.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(e.status), size: 14, color: statusCol),
                    const SizedBox(width: 4),
                    Text(
                      _statusText(e.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusCol,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundFor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _detailRow(Icons.calendar_today_rounded, 'তারিখ', _formatDate(e.createdAt)),
                if (e.batchName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _detailRow(Icons.group_rounded, 'ব্যাচ', e.batchName),
                ],
                if (e.batchSchedule.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _detailRow(Icons.schedule_rounded, 'রুটিন', e.batchSchedule),
                ],
                if (e.amount > 0) ...[
                  const SizedBox(height: 8),
                  _detailRow(Icons.payments_rounded, 'পরিমাণ', '৳${e.amount}'),
                ],
                if (e.paymentMethod.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _detailRow(Icons.credit_card_rounded, 'পেমেন্ট', _formatPayment(e.paymentMethod)),
                ],
              ],
            ),
          ),

          // Status message
          if (e.status == 'pending') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.warning),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'আপনার এনরোলমেন্ট রিভিউ হচ্ছে। অনুমোদনের পর জানানো হবে।',
                    style: TextStyle(fontSize: 11, color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiaryFor(context)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall(context).copyWith(
            color: AppColors.textSecondaryFor(context),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'approved':
        return 'অনুমোদিত';
      case 'rejected':
        return 'বাতিল';
      default:
        return 'অপেক্ষমাণ';
    }
  }
}

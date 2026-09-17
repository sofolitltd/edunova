import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../services/results_service.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  final _service = ResultsService();
  ResultSummary _summary = ResultSummary.empty();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final storage = SecureStorageService();
      final token = await storage.readToken();
      final summary = await _service.getSummary(token: token);
      if (mounted) setState(() { _summary = summary; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _percentColor(double percent) {
    if (percent >= 70) return AppColors.success;
    if (percent >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'ফলাফল'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: _summary.totalExams == 0
                    ? _buildEmptyState()
                    : ListView(
                        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                        children: [
                          _buildOverallCard(),
                          const SizedBox(height: AppSpacing.xl),
                          if (_summary.improvementAreas.isNotEmpty) ...[
                            _buildImprovementCard(),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                          _buildSectionTitle('বিষয়ভিত্তিক ফলাফল'),
                          const SizedBox(height: AppSpacing.md),
                          ..._summary.bySubject.map(_buildSubjectRow),
                          const SizedBox(height: AppSpacing.xl),
                          _buildSectionTitle('সাম্প্রতিক পরীক্ষা'),
                          const SizedBox(height: AppSpacing.md),
                          ..._summary.recent.map(_buildRecentCard),
                        ],
                      ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart_rounded, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: AppSpacing.md),
                Text('এখনো কোনো ফলাফল নেই', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                Text('পরীক্ষার ফলাফল যোগ হলে এখানে দেখা যাবে', style: AppTextStyles.bodySmall(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w700));
  }

  Widget _buildOverallCard() {
    final color = _percentColor(_summary.overallPercent);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.medium,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text('সামগ্রিক ফলাফল', style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(
            '${_summary.overallPercent.toStringAsFixed(1)}%',
            style: AppTextStyles.h1(context).copyWith(color: color, fontWeight: FontWeight.w800, fontSize: 40),
          ),
          const SizedBox(height: 4),
          Text('${_summary.totalExams}টি পরীক্ষার ভিত্তিতে', style: AppTextStyles.bodySmall(context)),
        ],
      ),
    );
  }

  Widget _buildImprovementCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              Text('উন্নতির প্রয়োজন', style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.warning, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ..._summary.improvementAreas.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${s.subject} — ${s.averagePercent.toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall(context),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSubjectRow(SubjectSummary s) {
    final color = _percentColor(s.averagePercent);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.subject, style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600)),
                Text('${s.averagePercent.toStringAsFixed(0)}%', style: AppTextStyles.bodyMedium(context).copyWith(color: color, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: (s.averagePercent / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: AppColors.borderFor(context),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 4),
            Text('${s.examCount}টি পরীক্ষা', style: AppTextStyles.bodySmall(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCard(ResultItem r) {
    final color = _percentColor(r.percentage);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: AppRadius.small),
              child: Center(
                child: Text('${r.percentage.toStringAsFixed(0)}%', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.examName, style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${r.subject} · ${r.examDate}', style: AppTextStyles.bodySmall(context)),
                  if (r.remarks.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(r.remarks, style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            Text('${r.marksObtained.toStringAsFixed(0)}/${r.marksTotal.toStringAsFixed(0)}', style: AppTextStyles.bodySmall(context)),
          ],
        ),
      ),
    );
  }
}

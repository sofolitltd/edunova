import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../services/practice_service.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import 'sentence_screen.dart';

class PracticeHubScreen extends StatefulWidget {
  const PracticeHubScreen({super.key});

  @override
  State<PracticeHubScreen> createState() => _PracticeHubScreenState();
}

class _PracticeHubScreenState extends State<PracticeHubScreen> {
  final _service = PracticeService();
  PracticeStats _stats = PracticeStats.empty();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final token = await SecureStorageService().readToken();
    final stats = await _service.getStats(token);
    if (mounted) setState(() { _stats = stats; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'অনুশীলন'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  children: [
                    _buildStatsCard(),
                    const SizedBox(height: AppSpacing.xl),
                    Text('অনুশীলন শুরু করো', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.md),
                    _buildActivityTile(
                      icon: Icons.style_rounded,
                      title: 'ফ্ল্যাশকার্ড',
                      subtitle: 'নতুন শব্দ শিখো, কার্ড উল্টিয়ে অর্থ দেখো',
                      gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      onTap: () => _openAndRefresh(const FlashcardScreen()),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildActivityTile(
                      icon: Icons.quiz_rounded,
                      title: 'শব্দ কুইজ',
                      subtitle: 'সঠিক অর্থ বেছে পয়েন্ট জিতো',
                      gradient: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      onTap: () => _openAndRefresh(const QuizScreen()),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildActivityTile(
                      icon: Icons.edit_note_rounded,
                      title: 'বাক্য গঠন',
                      subtitle: 'শব্দ দিয়ে নিজের বাক্য লেখো',
                      gradient: const [Color(0xFF10B981), Color(0xFF06B6D4)],
                      onTap: () => _openAndRefresh(const SentenceScreen()),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildStatsRow(),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _openAndRefresh(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    _load();
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.medium,
        boxShadow: AppShadow.primary,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('লেভেল ${_stats.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
              const SizedBox(height: 2),
              Text('${_stats.totalPoints} পয়েন্ট', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 2),
              Text('পরবর্তী লেভেলে আর ${_stats.pointsToNextLevel} পয়েন্ট', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 28)),
              Text('${_stats.currentStreak}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
              const Text('দিনের ধারা', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: AppRadius.small,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall(context)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildMiniStat('${_stats.quizCorrect}/${_stats.quizAttempts}', 'সঠিক উত্তর')),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildMiniStat('${_stats.flashcardsSeen}', 'কার্ড দেখা হয়েছে')),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildMiniStat('${_stats.sentencesDone}', 'বাক্য লেখা হয়েছে')),
      ],
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall(context), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

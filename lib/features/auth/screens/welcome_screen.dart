import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _WelcomePage(
      icon: Icons.school_rounded,
      title: 'EduNova তে স্বাগতম',
      subtitle: 'আপনার সন্তানের শিক্ষার সঙ্গী',
      description: 'ক্লাস ৩-৮ পর্যন্ত সকল বিষয়ে মানসম্মত শিক্ষা একটি অ্যাপে।',
    ),
    _WelcomePage(
      icon: Icons.play_circle_filled_rounded,
      title: 'লাইভ ক্লাস ও পরীক্ষা',
      subtitle: 'সরাসরি শিক্ষকের সঙ্গে জড়িত হন',
      description: 'লাইভ পরীক্ষা দিন, নোটস পড়ুন এবং প্রতিদিন নতুন কিছু শিখুন।',
    ),
    _WelcomePage(
      icon: Icons.family_restroom_rounded,
      title: 'অভিভাবকদের জন্য',
      subtitle: 'আপনার সন্তানের অগ্রগতি ট্র্যাক করুন',
      description: 'দৈনিক হাজিরা, পারফরম্যান্স রিপোর্ট এবং শিক্ষকদের সঙ্গে যোগাযোগ।',
    ),
    _WelcomePage(
      icon: Icons.rocket_launch_rounded,
      title: 'এখনই শুরু করুন',
      subtitle: 'মাত্র কয়েক সেকেন্ডে রেজিস্ট্রেশন',
      description: 'ফ্রী কোর্সে শুরু করুন অথবা পেইড কোর্সে এনরোল করুন।',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDone() async {
    await SecureStorageService().saveHasSeenWelcome();
    if (!mounted) return;
    context.go('/login');
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _handleDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip Button ────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _handleDone,
                child: Text(
                  'এড়িয়ে যান',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            // ── Page View ──────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),

            // ── Dots + Button ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.xl,
              ),
              child: Row(
                children: [
                  // Dots
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primary
                              : AppColors.textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Next / Done button
                  GestureDetector(
                    onTap: HapticFeedback.lightImpact,
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        child: Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 24,
                        ),
                      ),
                    ),
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

class _WelcomePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const _WelcomePage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xxxxl),
          Text(
            title,
            style: AppTextStyles.h1(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            subtitle,
            style: AppTextStyles.bodyLarge(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            description,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

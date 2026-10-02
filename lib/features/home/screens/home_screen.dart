import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'tabs/home_tab.dart';
import 'tabs/exam_tab.dart';
import 'tabs/class_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final _tabs = const [
    HomeTab(),
    ExamTab(),
    ClassTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: AppColors.surfaceFor(context),
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
            indicatorShape: const StadiumBorder(),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                fontSize: 11,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : AppColors.textTertiaryFor(context),
              ),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: [
            NavigationDestination(
              icon: _navIcon(HugeIcons.strokeRoundedHome01, context, selected: false),
              selectedIcon: _navIcon(HugeIcons.strokeRoundedHome01, context, selected: true),
              label: l10n.home,
            ),
            NavigationDestination(
              icon: _navIcon(HugeIcons.strokeRoundedQuiz01, context, selected: false),
              selectedIcon: _navIcon(HugeIcons.strokeRoundedQuiz01, context, selected: true),
              label: l10n.exam,
            ),
            NavigationDestination(
              icon: _navIcon(HugeIcons.strokeRoundedBookOpen01, context, selected: false),
              selectedIcon: _navIcon(HugeIcons.strokeRoundedBookOpen01, context, selected: true),
              label: l10n.classes,
            ),
            NavigationDestination(
              icon: _navIcon(HugeIcons.strokeRoundedUser, context, selected: false),
              selectedIcon: _navIcon(HugeIcons.strokeRoundedUser, context, selected: true),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(List<List<dynamic>> icon, BuildContext context, {required bool selected}) {
    return HugeIcon(
      icon: icon,
      size: 24,
      strokeWidth: selected ? 2.2 : 1.8,
      color: selected ? AppColors.primary : AppColors.textTertiaryFor(context),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../shared/constants/app_text_styles.dart';

/// Title + subtitle row with a "সব দেখুন" link, used above horizontal
/// course rails on the home tab.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h3(context)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.bodySmall(context)),
          ],
        ),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                'সব দেখুন',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, size: 18, color: color),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      appBar: AppAppBar(title: l10n.privacyPolicy),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text(
                l10n.appName,
                style: AppTextStyles.h2(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                l10n.privacyPolicy,
                style: AppTextStyles.bodyMedium(context),
              ),
            ),
            Center(
              child: Text(
                l10n.lastUpdated,
                style: AppTextStyles.bodySmall(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            _buildSection(
              context,
              title: l10n.privacyS1Title,
              content: l10n.privacyS1Content,
            ),
            _buildSection(
              context,
              title: l10n.privacyS2Title,
              content: l10n.privacyS2Content,
            ),
            _buildSection(
              context,
              title: l10n.privacyS3Title,
              content: l10n.privacyS3Content,
            ),
            _buildSection(
              context,
              title: l10n.privacyS4Title,
              content: l10n.privacyS4Content,
            ),
            _buildSection(
              context,
              title: l10n.privacyS5Title,
              content: l10n.privacyS5Content,
            ),
            _buildSection(
              context,
              title: l10n.privacyS6Title,
              content: l10n.privacyS6Content,
            ),
            _buildSection(
              context,
              title: l10n.privacyS7Title,
              content: l10n.privacyS7Content,
            ),
            const SizedBox(height: AppSpacing.xxxxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3(context).copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.sm),
          Text(content, style: AppTextStyles.bodyLarge(context)),
        ],
      ),
    );
  }
}

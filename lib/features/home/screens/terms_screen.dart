import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      appBar: AppAppBar(title: l10n.termsOfService),
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
                l10n.termsOfService,
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
              title: l10n.termsS1Title,
              content: l10n.termsS1Content,
            ),
            _buildSection(
              context,
              title: l10n.termsS2Title,
              content: l10n.termsS2Content,
            ),
            _buildSection(
              context,
              title: l10n.termsS3Title,
              content: l10n.termsS3Content,
            ),
            _buildSection(
              context,
              title: l10n.termsS4Title,
              content: l10n.termsS4Content,
            ),
            _buildSection(
              context,
              title: l10n.termsS5Title,
              content: l10n.termsS5Content,
            ),
            _buildSection(
              context,
              title: l10n.termsS6Title,
              content: l10n.termsS6Content,
            ),
            _buildSection(
              context,
              title: l10n.termsS7Title,
              content: l10n.termsS7Content,
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

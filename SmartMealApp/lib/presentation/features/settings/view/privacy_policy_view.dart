import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/features/settings/widgets/privacy_content.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyHeading),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: DefaultTextStyle(
            style: TextStyle(color: colorScheme.onSurface, height: 1.4),
            child: PrivacyContent(languageCode: lang),
          ),
        ),
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}

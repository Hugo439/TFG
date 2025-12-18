import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class TermsContent extends StatelessWidget {
  const TermsContent({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lastUpdated = DateFormat.yMMMMd(
      languageCode,
    ).format(DateTime(2025, 12, 17));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.termsHeading),
        const SizedBox(height: 8),
        Text(l10n.termsUpdated(lastUpdated)),
        const SizedBox(height: 16),
        _SectionTitle(l10n.termsSection1Title),
        Text(l10n.termsSection1Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.termsSection2Title),
        Text(l10n.termsSection2Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.termsSection3Title),
        Text(l10n.termsSection3Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.termsSection4Title),
        Text(l10n.termsSection4Body),
        const SizedBox(height: 12),
        _SectionTitle(l10n.termsSection5Title),
        Text(l10n.termsSection5Body),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }
}

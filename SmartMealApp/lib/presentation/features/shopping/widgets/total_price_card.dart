import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class TotalPriceCard extends StatelessWidget {
  final double totalPrice;
  final int checkedCount;
  final int totalCount;
  final String? totalLabel;
  final String? selectedLabel;

  const TotalPriceCard({
    super.key,
    required this.totalPrice,
    this.checkedCount = 0,
    this.totalCount = 0,
    this.totalLabel,
    this.selectedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondary,
            colorScheme.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                totalLabel ?? l10n.shoppingTotalLabel,
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.shoppingSelectedCount(checkedCount, totalCount),
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Text(
            '€${totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorScheme.onSecondary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
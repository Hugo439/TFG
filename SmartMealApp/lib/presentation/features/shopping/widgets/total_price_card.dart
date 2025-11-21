import 'package:flutter/material.dart';

class TotalPriceCard extends StatelessWidget {
  final double totalPrice;
  final int checkedCount;
  final int totalCount;

  const TotalPriceCard({
    super.key,
    required this.totalPrice,
    this.checkedCount = 0,
    this.totalCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                'Total Estimado',
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$checkedCount/$totalCount productos',
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
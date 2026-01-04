import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Card que muestra el precio total de la lista de compras.
///
/// Responsabilidades:
/// - Mostrar precio total estimado
/// - Mostrar contadores de items (seleccionados/total)
/// - Diseño destacado con gradiente
///
/// Información mostrada:
/// - **Label**: "Total estimado" (localizado)
/// - **Contador items**: "X seleccionados de Y" (opcional)
/// - **Precio total**: Grande y destacado con icono euro
/// - **Nota**: "Precio aproximado" en letra pequeña
///
/// Diseño visual:
/// - **Gradiente**: secondary → secondary con alpha 0.8
/// - **Bordes redondeados**: 16px
/// - **Sombra**: BoxShadow con color secondary, alpha 0.4
/// - **Texto**: color onSecondary para contraste
/// - **Icono euro**: 32px junto al precio
///
/// Layout:
/// - Row con spaceBetween
/// - Izquierda: Labels y contador
/// - Derecha: Precio con icono euro
///
/// Cálculo del precio:
/// - Suma de precios de todos los items
/// - Usa PriceDatabaseService para estimaciones
/// - Prioridad: UserPriceOverride > PriceCatalog > Fallback
/// - Mostrado con 2 decimales: "XX.XX€"
///
/// Contador de items:
/// - checkedCount: items marcados como comprados
/// - totalCount: total de items en la lista
/// - Formato: "X seleccionados de Y"
/// - Opcional (solo si checkedCount > 0)
///
/// Labels personalizables:
/// - totalLabel: override para "Total estimado"
/// - selectedLabel: override para "X seleccionados de Y"
/// - Default: usa l10n para localización
///
/// Parámetros:
/// [totalPrice] - Precio total calculado
/// [checkedCount] - Número de items marcados (default: 0)
/// [totalCount] - Número total de items (default: 0)
/// [totalLabel] - Label custom para total (opcional)
/// [selectedLabel] - Label custom para contador (opcional)
///
/// Uso:
/// ```dart
/// TotalPriceCard(
///   totalPrice: 45.67,
///   checkedCount: 5,
///   totalCount: 12,
/// )
/// ```
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
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.4),
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
                  color: colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.shoppingSelectedCount(checkedCount, totalCount),
                style: TextStyle(color: colorScheme.onPrimary, fontSize: 13),
              ),
            ],
          ),
          Text(
            '€${totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

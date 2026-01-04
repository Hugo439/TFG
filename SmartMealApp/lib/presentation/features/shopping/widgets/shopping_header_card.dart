import 'package:flutter/material.dart';

/// Card de encabezado para la vista de lista de compra.
///
/// Responsabilidades:
/// - Título "Lista de la Compra"
/// - Subtítulo informativo (ej: número de items)
/// - Icono de carrito de compras
///
/// Diseño visual:
/// - **Gradient**: primary a primary con alpha 0.8
/// - **Dirección**: topLeft a bottomRight
/// - **BoxShadow**: primary con alpha 0.3, blur 8, offset (0,4)
/// - **BorderRadius**: 16px
/// - **Padding**: 20px
///
/// Layout:
/// - Row: columna de texto (expandida) + container con icono
/// - Columna: título + subtítulo
/// - Icono: shopping_cart, 32px, en container decorado
///
/// Container del icono:
/// - Padding: 12px
/// - Background: onPrimary con alpha 0.2
/// - BorderRadius: 12px
///
/// Tipografía:
/// - **Título**: 20px, bold, onPrimary
/// - **Subtítulo**: 14px, regular, onPrimary
///
/// Consistencia visual:
/// - Mismo estilo que TotalPriceCard (ambos con gradient)
/// - Colores complementarios (primary vs secondary)
///
/// Parámetros:
/// [subtitle] - Texto informativo (ej: "8 productos")
///
/// Uso:
/// ```dart
/// ShoppingHeaderCard(subtitle: '12 productos')
/// ```
class ShoppingHeaderCard extends StatelessWidget {
  final String subtitle;

  const ShoppingHeaderCard({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lista de la Compra',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: colorScheme.onPrimary, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_cart,
              color: colorScheme.onPrimary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

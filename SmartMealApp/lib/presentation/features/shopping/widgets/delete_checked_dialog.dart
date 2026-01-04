import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Diálogo de confirmación para eliminar items marcados.
///
/// Responsabilidades:
/// - Confirmar eliminación de productos comprados
/// - Prevenir borrado accidental
///
/// Flujo:
/// 1. Usuario toca botón de eliminar marcados
/// 2. showDialog con DeleteCheckedDialog
/// 3. Usuario confirma o cancela
/// 4. Si confirma: onConfirm() + cierra diálogo
///
/// Acciones:
/// - **Cancelar**: cierra sin hacer nada
/// - **Eliminar**: ejecuta onConfirm() y cierra
///
/// Diseño:
/// - AlertDialog estándar de Material
/// - Título: l10n.shoppingDeleteCheckedTitle
/// - Mensaje: l10n.shoppingDeleteCheckedMessage
///
/// Colores:
/// - Botón cancelar: onSurface (neutral)
/// - Botón eliminar: error (rojo, acción destructiva)
///
/// UX:
/// - Acción destructiva claramente marcada
/// - Fácil cancelar (click fuera o botón)
/// - Mensaje claro de lo que se va a eliminar
///
/// Parámetros:
/// [onConfirm] - Callback ejecutado al confirmar eliminación
///
/// Uso:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => DeleteCheckedDialog(
///     onConfirm: () => deleteCheckedItems(),
///   ),
/// )
/// ```
class DeleteCheckedDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteCheckedDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.shoppingDeleteCheckedTitle),
      content: Text(l10n.shoppingDeleteCheckedMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.commonCancel,
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text(
            l10n.commonDelete,
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ],
    );
  }
}

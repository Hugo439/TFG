import 'package:flutter/material.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

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

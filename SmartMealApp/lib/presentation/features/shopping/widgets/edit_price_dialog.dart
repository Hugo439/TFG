import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/usecases/shopping/save_user_price_override_usecase.dart';
import 'package:smartmeal/domain/services/shopping/price_database.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';
import 'package:smartmeal/core/errors/errors.dart';

class EditPriceDialog extends StatefulWidget {
  final ShoppingItem item;
  final VoidCallback? onPriceSaved;

  const EditPriceDialog({super.key, required this.item, this.onPriceSaved});

  @override
  State<EditPriceDialog> createState() => _EditPriceDialogState();
}

class _EditPriceDialogState extends State<EditPriceDialog> {
  late final TextEditingController _priceController;
  late final TextEditingController _reasonController;
  bool _isSaving = false;
  String? _errorMessage;
  late final String _unitLabel;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.item.price.value.toStringAsFixed(2),
    );
    _reasonController = TextEditingController();
    _unitLabel = _getUnitLabel();
  }

  String _getUnitLabel() {
    // Detectar tipo de unidad basado en la base de datos de precios
    final ingredientName = widget.item.name.value.toLowerCase();

    // Buscar en precios específicos
    if (PriceDatabase.specificPrices.containsKey(ingredientName)) {
      final priceInfo = PriceDatabase.specificPrices[ingredientName]!;
      switch (priceInfo.unitType) {
        case UnitType.piece:
          return 'unidad';
        case UnitType.weight:
          return 'kilogramo';
        case UnitType.liter:
          return 'litro';
      }
    }

    // Por defecto, inferir del texto de cantidad
    final quantity = widget.item.quantity.value.toLowerCase();
    if (quantity.contains('kg')) return 'kilogramo';
    if (quantity.contains('l')) return 'litro';
    if (quantity.contains('ud') || quantity.contains('unidad')) return 'unidad';

    // Fallback basado en categoría
    return 'kilogramo'; // La mayoría de productos se venden por peso
  }

  IconData _getUnitIcon() {
    switch (_unitLabel) {
      case 'unidad':
        return Icons.looks_one;
      case 'litro':
        return Icons.water_drop;
      case 'kilogramo':
      default:
        return Icons.scale;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _savePrice() async {
    final l10n = context.l10n;
    final priceText = _priceController.text.trim().replaceAll(',', '.');
    final newPrice = double.tryParse(priceText);

    if (newPrice == null || newPrice <= 0) {
      setState(() {
        _errorMessage = l10n.shoppingEditPriceErrorInvalid;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw AuthFailure('Usuario no autenticado');
      }

      final useCase = sl<SaveUserPriceOverrideUseCase>();
      final result = await useCase(
        SaveUserPriceOverrideParams(
          userId: user.uid,
          ingredientName: widget.item.name.value,
          customPrice: newPrice,
          reason: _reasonController.text.trim().isEmpty
              ? l10n.shoppingEditPriceReasonDefault
              : _reasonController.text.trim(),
        ),
      );

      result.fold(
        (failure) {
          setState(() {
            _errorMessage = l10n.shoppingEditPriceErrorSaving(failure.message);
            _isSaving = false;
          });
        },
        (_) {
          if (mounted) {
            Navigator.of(context).pop(true);
            widget.onPriceSaved?.call();
          }
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = l10n.shoppingEditPriceErrorUnexpected(e.toString());
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.shoppingEditPriceTitle,
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del ingrediente
            Text(
              widget.item.name.value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.shoppingEditPriceCurrentPrice(
                widget.item.price.value.toStringAsFixed(2),
              ),
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            // Indicador de unidad de medida
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getUnitIcon(), size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.shoppingEditPriceUnitInfo(_unitLabel),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Campo de precio
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: l10n.shoppingEditPriceNewPriceLabel,
                hintText: l10n.shoppingEditPriceNewPriceHint,
                prefixIcon: const Icon(Icons.euro),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _errorMessage,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Campo de razón (opcional)
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: l10n.shoppingEditPriceReasonLabel,
                hintText: l10n.shoppingEditPriceReasonHint,
                prefixIcon: const Icon(Icons.comment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // Info adicional
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.shoppingEditPriceInfo,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _savePrice,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onPrimary,
                    ),
                  ),
                )
              : Text(l10n.commonSave),
        ),
      ],
    );
  }
}

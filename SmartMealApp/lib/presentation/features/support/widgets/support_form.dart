import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartmeal/presentation/theme/theme_helpers.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Formulario para enviar mensajes de soporte.
///
/// Responsabilidades:
/// - Dropdown de categorías de soporte
/// - Campo de texto para mensaje
/// - Adjuntar imagen (opcional)
/// - Botón de enviar
/// - Estados: loading, success, error
///
/// Categorías:
/// - Dudas
/// - Errores
/// - Sugerencias
/// - Cuenta
/// - Menús
/// - Otro
///
/// Flujo de uso:
/// 1. Usuario selecciona categoría
/// 2. Escribe mensaje (TextField multiline, 5 líneas)
/// 3. Opcionalmente adjunta imagen
/// 4. Toca "Enviar"
/// 5. Loading state mientras envía
/// 6. Success o error message
///
/// Adjunto:
/// - Botón "Adjuntar imagen"
/// - ImagePicker para seleccionar de galería
/// - Preview de imagen seleccionada
/// - Botón para quitar adjunto
///
/// Estados visuales:
/// - **Normal**: formulario habilitado
/// - **Loading**: botón enviar con spinner, campos disabled
/// - **Success**: snackbar verde de confirmación
/// - **Error**: mensaje rojo debajo del formulario
///
/// Diseño:
/// - **Dropdown**: filled, borderRadius 12px
/// - **TextField**: 5 maxLines, filled, borderRadius 12px
/// - **Botón adjuntar**: ElevatedButton con icon attach_file
/// - **Botón enviar**: ElevatedButton con texto "Enviar"
///
/// Layout:
/// - Columna vertical
/// - Dropdown arriba
/// - TextField en medio
/// - Row con botones (adjuntar + enviar)
/// - Preview de imagen si existe
/// - Mensaje de error si error != null
///
/// Validación:
/// - Categoría requerida
/// - Mensaje no vacío
/// - Adjunto opcional
///
/// Parámetros:
/// [controller] - TextEditingController para mensaje
/// [loading] - Estado de carga
/// [error] - Mensaje de error (null si no hay)
/// [success] - Flag de éxito
/// [selectedCategory] - Categoría seleccionada
/// [onCategoryChanged] - Callback al cambiar categoría
/// [attachment] - XFile con imagen adjunta
/// [onPickAttachment] - Callback para seleccionar imagen
/// [onSend] - Callback para enviar mensaje
///
/// Uso:
/// ```dart
/// SupportForm(
///   controller: messageController,
///   loading: viewModel.isLoading,
///   error: viewModel.error,
///   success: viewModel.success,
///   selectedCategory: viewModel.category,
///   onCategoryChanged: viewModel.setCategory,
///   attachment: viewModel.attachment,
///   onPickAttachment: viewModel.pickImage,
///   onSend: viewModel.sendMessage,
/// )
/// ```
class SupportForm extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final String? error;
  final bool success;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final XFile? attachment;
  final VoidCallback onPickAttachment;
  final VoidCallback onSend;

  const SupportForm({
    super.key,
    required this.controller,
    required this.loading,
    required this.error,
    required this.success,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.attachment,
    required this.onPickAttachment,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = [
      'Dudas',
      'Errores',
      'Sugerencias',
      'Cuenta',
      'Menús',
      'Otro',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedCategory,
          items: categories
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: onCategoryChanged,
          decoration: InputDecoration(
            labelText: context.l10n.supportCategory,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: ThemeHelpers.backgroundSecondary(context),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: context.l10n.supportMessage,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            fillColor: colorScheme.surfaceContainerHighest,
            filled: true,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: Text(context.l10n.supportAttach),
              onPressed: loading ? null : onPickAttachment,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            if (attachment != null)
              Expanded(
                child: Text(
                  attachment!.name,
                  style: TextStyle(color: colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        if (attachment != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Image.file(
              File(attachment!.path),
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(error!, style: TextStyle(color: colorScheme.error)),
          ),
        if (success)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Mensaje enviado correctamente',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: Text(
              loading ? context.l10n.supportSending : context.l10n.supportSend,
            ),
            onPressed: loading ? null : onSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

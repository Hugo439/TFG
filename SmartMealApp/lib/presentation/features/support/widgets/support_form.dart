import 'package:flutter/material.dart';

class SupportForm extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final String? error;
  final VoidCallback onSend;
  final bool success; // Añade este parámetro como booleano

  const SupportForm({
    super.key,
    required this.controller,
    required this.loading,
    required this.error,
    required this.success, // Cambia aquí
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Tu mensaje',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: colorScheme.surfaceContainerHighest,
            filled: true,
          ),
        ),
        const SizedBox(height: 16),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: colorScheme.error),
          ),
        if (success)
          Text(
            'Mensaje enviado correctamente',
            style: TextStyle(color: colorScheme.primary),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: loading
                ? const Text('Enviando...')
                : const Text('Enviar mensaje'),
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
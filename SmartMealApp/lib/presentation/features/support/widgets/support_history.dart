import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/support_message.dart';
import 'package:smartmeal/presentation/theme/theme_helpers.dart';
import 'package:smartmeal/presentation/theme/colors.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';
import 'package:smartmeal/presentation/l10n/support_localizer.dart';

class SupportHistory extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<SupportMessage> messages;

  const SupportHistory({
    super.key,
    required this.loading,
    required this.error,
    required this.messages,
  });

  // Obtener icono según categoría
  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Dudas':
        return Icons.help_outline;
      case 'Errores':
        return Icons.error_outline;
      case 'Sugerencias':
        return Icons.lightbulb_outline;
      case 'Cuenta':
        return Icons.person_outline;
      case 'Menús':
        return Icons.restaurant_menu;
      case 'Otro':
        return Icons.more_horiz;
      default:
        return Icons.label_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error!,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      );
    }
    
    if (messages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.supportNoMessages,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final categoryColor = ThemeHelpers.getCategoryColor(msg.category, context);
        final categoryIcon = _getCategoryIcon(msg.category);
        final statusColor = ThemeHelpers.getStatusColor(msg.status, context);
        
        // Localizar categoría y estado
        final localizedCategory = SupportLocalizer.category(context, msg.category);
        final localizedStatus = SupportLocalizer.status(context, msg.status);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          color: ThemeHelpers.cardBackground(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: categoryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con categoría y estado
                Row(
                  children: [
                    // Categoría con icono y color
                    if (msg.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: categoryColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              categoryIcon,
                              size: 16,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              localizedCategory,
                              style: TextStyle(
                                color: categoryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    // Estado
                    if (msg.status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          localizedStatus,
                          style: TextStyle(
                            color: isDark ? AppColors.darkPrimaryText : AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Mensaje
                Text(
                  msg.message,
                  style: TextStyle(
                    fontSize: 15,
                    color: ThemeHelpers.textPrimary(context),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Fecha
                Text(
                  _formatDate(msg.sentAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeHelpers.textSecondary(context),
                  ),
                ),
                
                // Adjunto
                if (msg.attachmentUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      msg.attachmentUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.broken_image,
                          color: colorScheme.error,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ],
                
                // Respuesta
                if (msg.response != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.support_agent,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.supportResponse,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          msg.response!,
                          style: TextStyle(
                            color: ThemeHelpers.textPrimary(context),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        if (msg.responseDate != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(msg.responseDate!),
                            style: TextStyle(
                              color: ThemeHelpers.textSecondary(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy a las ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer a las ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
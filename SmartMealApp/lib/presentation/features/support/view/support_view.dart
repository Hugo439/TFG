import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/domain/usecases/support/get_support_messages_usecase.dart';
import 'package:smartmeal/domain/repositories/support_message_repository.dart';
import 'package:smartmeal/data/datasources/local/faq_local_datasource.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import '../viewmodel/support_view_model.dart';
import '../widgets/support_form.dart';
import '../widgets/support_history.dart';
import '../widgets/faq_list.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/contact_links.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Pantalla de soporte y ayuda.
///
/// Responsabilidades:
/// - Formulario para enviar mensajes al admin
/// - Historial de mensajes previos con respuestas
/// - Sección de FAQs (Preguntas Frecuentes)
/// - Enlaces de contacto (email, redes sociales)
///
/// Secciones principales (Tabs):
/// 1. **Enviar mensaje (SupportForm)**:
///    - Mensaje de texto
///    - Categoría (dropdown: técnico, sugerencia, bug, otro)
///    - Adjunto opcional (imagen con ImagePicker)
///    - Botón enviar
///
/// 2. **Historial (SupportHistory)**:
///    - Lista de mensajes enviados
///    - Estado: pendiente/respondido
///    - Respuesta del admin (si existe)
///    - Fecha de envío y respuesta
///
/// 3. **FAQs (FAQList)**:
///    - Preguntas frecuentes agrupadas por categoría
///    - ExpansionTile para ver respuestas
///    - Cargadas desde FAQLocalDatasource
///    - Por locale (es/en)
///
/// 4. **Contacto (ContactLinks)**:
///    - Email de soporte
///    - Redes sociales
///    - Enlaces externos
///
/// Envío de mensaje:
/// - SupportViewModel.sendSupportMessage()
/// - Validación: texto no vacío, categoría seleccionada
/// - Guarda en Firestore: support_messages collection
/// - SnackBar de confirmación
/// - Limpia formulario tras enviar
///
/// Adjuntos:
/// - ImagePicker.pickImage(source: gallery)
/// - Sube a Firebase Storage (opcional)
/// - Asocia URL con el mensaje
///
/// Carga de datos:
/// - Automática en initState
/// - loadMessages(userId) obtiene historial
/// - loadFAQs(locale) obtiene preguntas frecuentes
///
/// Estados:
/// - **Loading**: CircularProgressIndicator
/// - **Error**: Mensaje de error
/// - **Success**: Muestra tabs con contenido
///
/// Navegación:
/// - Acceso desde HomeView
/// - Botón volver a Home
///
/// Uso:
/// ```dart
/// Navigator.pushNamed(context, Routes.support);
/// ```
class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = SupportViewModel(
          getSupportMessagesUseCase: Provider.of<GetSupportMessagesUseCase>(
            context,
            listen: false,
          ),
          supportMessageRepository: Provider.of<SupportMessageRepository>(
            context,
            listen: false,
          ),
          faqLocalDatasource: sl<FAQLocalDatasource>(),
        );
        vm.loadMessages(vm.userId);
        return vm;
      },
      child: const _SupportContent(),
    );
  }
}

class _SupportContent extends StatefulWidget {
  const _SupportContent();

  @override
  State<_SupportContent> createState() => _SupportContentState();
}

class _SupportContentState extends State<_SupportContent> {
  final controller = TextEditingController();
  String? selectedCategory;
  XFile? attachment;

  Future<void> pickAttachment() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        attachment = picked;
      });
    }
  }

  Future<void> _sendMessage() async {
    final vm = Provider.of<SupportViewModel>(context, listen: false);

    final success = await vm.sendSupportMessage(
      controller.text,
      selectedCategory,
      attachment,
    );

    if (success && mounted) {
      // Limpiar formulario después de enviar
      controller.clear();
      setState(() {
        selectedCategory = null;
        attachment = null;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.supportSentOk),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SupportViewModel>();
      final locale = Localizations.localeOf(context).languageCode;
      vm.loadFAQs(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SupportViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.supportTitle,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.supportContact,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.supportDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              SupportForm(
                controller: controller,
                loading: vm.loading,
                error: vm.formError,
                success: vm.success,
                selectedCategory: selectedCategory,
                onCategoryChanged: (cat) =>
                    setState(() => selectedCategory = cat),
                attachment: attachment,
                onPickAttachment: pickAttachment,
                onSend: _sendMessage,
              ),
              const SizedBox(height: 32),
              Divider(),
              const SizedBox(height: 16),
              Text(
                context.l10n.supportHistory,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              SupportHistory(
                loading: vm.loadingHistory,
                error: vm.historyError,
                messages: vm.messages,
              ),
              const SizedBox(height: 32),
              Divider(),
              const SizedBox(height: 16),
              Text(
                context.l10n.supportFaq,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              FAQList(faqs: vm.faqs),
              const SizedBox(height: 32),
              ContactLinks(
                email:
                    'hugolaroca@gmail.com', //TODO: Cambiar email 'soporte@smartmeal.com'
                whatsapp: '34640879075',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

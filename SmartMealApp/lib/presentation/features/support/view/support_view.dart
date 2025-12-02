import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/domain/usecases/get_support_messages_usecase.dart';
import 'package:smartmeal/domain/repositories/support_message_repository.dart';
import '../viewmodel/support_view_model.dart';
import '../widgets/support_form.dart';
import '../widgets/support_history.dart';
import '../widgets/faq_list.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/contact_links.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = SupportViewModel(
          getSupportMessagesUseCase: Provider.of<GetSupportMessagesUseCase>(context, listen: false),
          supportMessageRepository: Provider.of<SupportMessageRepository>(context, listen: false),
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
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              SupportForm(
                controller: controller,
                loading: vm.loading,
                error: vm.formError,
                success: vm.success,
                selectedCategory: selectedCategory,
                onCategoryChanged: (cat) => setState(() => selectedCategory = cat),
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
                email: 'hugolaroca@gmail.com', //TODO: Cambiar email 'soporte@smartmeal.com'
                whatsapp: '34640879075',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
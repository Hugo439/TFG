import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/domain/usecases/get_support_messages_usecase.dart';
import 'package:smartmeal/domain/repositories/support_message_repository.dart';
import '../viewmodel/support_view_model.dart';
import '../widgets/support_form.dart';
import '../widgets/faq_item.dart';
import 'package:smartmeal/presentation/widgets/layout/smart_meal_app_bar.dart';
import 'package:smartmeal/domain/entities/support_message.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = 'user_id_actual'; // Obtén el userId real

    return ChangeNotifierProvider(
      create: (_) => SupportViewModel(
        getSupportMessagesUseCase: Provider.of<GetSupportMessagesUseCase>(context, listen: false),
        supportMessageRepository: Provider.of<SupportMessageRepository>(context, listen: false),
      )..loadMessages(userId),
      child: const _SupportContent(),
    );
  }
}

class _SupportContent extends StatelessWidget {
  const _SupportContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SupportViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final controller = TextEditingController();

    return Scaffold(
      appBar: SmartMealAppBar(
        title: 'Soporte',
        subtitle: '¿Necesitas ayuda?',
        centerTitle: false,
        showNotification: false,
      ),
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contacta con el equipo de SmartMeal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Tienes dudas, sugerencias o problemas? Escríbenos y te responderemos lo antes posible.',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              SupportForm(
                controller: controller,
                loading: vm.loading,
                error: vm.error,
                success: vm.success,
                onSend: () => vm.sendSupportMessage(controller.text),
              ),
              const SizedBox(height: 32),
              Divider(),
              const SizedBox(height: 16),
              Text(
                'Historial de mensajes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              if (vm.loading)
                const Center(child: CircularProgressIndicator())
              else if (vm.error != null)
                Text(vm.error!, style: TextStyle(color: colorScheme.error))
              else if (vm.messages.isEmpty)
                const Text('No tienes mensajes de soporte.')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: vm.messages.length,
                  itemBuilder: (context, index) {
                    final msg = vm.messages[index];
                    return ListTile(
                      title: Text(msg.message),
                      subtitle: Text(msg.sentAt.toString()),
                      trailing: msg.status != null ? Text(msg.status!) : null,
                    );
                  },
                ),
              const SizedBox(height: 32),
              Divider(),
              const SizedBox(height: 16),
              Text(
                'Preguntas frecuentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const FAQItem(
                question: '¿Cómo puedo cambiar mi contraseña?',
                answer: 'Ve a la sección de perfil y selecciona "Cambiar contraseña".',
              ),
              const FAQItem(
                question: '¿Cómo reporto un error?',
                answer: 'Escríbenos un mensaje explicando el problema y lo solucionaremos lo antes posible.',
              ),
              const FAQItem(
                question: '¿Dónde puedo ver mis menús generados?',
                answer: 'En la sección "Menús" del panel principal.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
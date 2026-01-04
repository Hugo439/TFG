import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/faq.dart';
import 'faq_item.dart';

/// Lista de preguntas frecuentes (FAQs).
///
/// Responsabilidades:
/// - Renderizar lista de FAQs
/// - Mapear entidades FAQ a widgets FAQItem
///
/// Funcionamiento:
/// - Recibe List<FAQ> desde SupportViewModel
/// - Map cada FAQ a FAQItem
/// - Columna vertical con todas las FAQItems
///
/// Simple wrapper:
/// - No tiene lógica propia
/// - Delega renderizado a FAQItem
///
/// Uso típico:
/// - SupportView carga FAQs desde Firestore
/// - FAQList renderiza la colección
/// - Cada FAQItem es expandible individualmente
///
/// Parámetros:
/// [faqs] - Lista de FAQs a mostrar
///
/// Uso:
/// ```dart
/// FAQList(faqs: viewModel.faqs)
/// ```
class FAQList extends StatelessWidget {
  final List<FAQ> faqs;

  const FAQList({super.key, required this.faqs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: faqs
          .map((faq) => FAQItem(question: faq.question, answer: faq.answer))
          .toList(),
    );
  }
}

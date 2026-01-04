import 'package:smartmeal/data/models/faq_model.dart';
import 'package:smartmeal/domain/entities/faq.dart';

/// Mapper para convertir FAQModel a FAQ con selección de idioma.
///
/// Responsabilidad:
/// - **toEntity**: Convierte FAQModel → FAQ seleccionando pregunta/respuesta según locale
///
/// Lógica de idioma:
/// - Si locale empieza con 'es' → usa questionEs/answerEs
/// - Cualquier otro locale → usa questionEn/answerEn (default inglés)
///
/// Estructura FAQModel:
/// - questionEn, answerEn: textos en inglés
/// - questionEs, answerEs: textos en español
///
/// Ejemplo:
/// ```dart
/// final faq = FAQMapper.toEntity(model, 'es_ES'); // usa textos en español
/// final faq = FAQMapper.toEntity(model, 'en_US'); // usa textos en inglés
/// ```
class FAQMapper {
  /// Convierte FAQModel a FAQ seleccionando textos según idioma.
  ///
  /// [model] - Modelo con preguntas/respuestas en ambos idiomas.
  /// [locale] - Código de idioma (ej: 'es_ES', 'en_US').
  ///
  /// Returns: FAQ con textos en el idioma solicitado.
  ///
  /// Selección:
  /// - locale.startsWith('es') → español
  /// - cualquier otro → inglés (default)
  static FAQ toEntity(FAQModel model, String locale) {
    final isSpanish = locale.startsWith('es');

    return FAQ(
      id: model.id,
      question: isSpanish ? model.questionEs : model.questionEn,
      answer: isSpanish ? model.answerEs : model.answerEn,
    );
  }
}

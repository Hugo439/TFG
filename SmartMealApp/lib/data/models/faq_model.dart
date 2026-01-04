/// Modelo de datos para FAQ (Preguntas Frecuentes).
///
/// Responsabilidad:
/// - Almacenar preguntas/respuestas multiidioma desde Firestore
///
/// Campos:
/// - **id**: identificador único del FAQ
/// - **questionEs**: pregunta en español
/// - **answerEs**: respuesta en español
/// - **questionEn**: pregunta en inglés
/// - **answerEn**: respuesta en inglés
/// - **order**: orden de visualización (menor = primero)
///
/// Ruta Firestore:
/// ```
/// faqs/{faqId}
/// ```
///
/// Ejemplo:
/// ```json
/// {
///   "question_es": "¿Cómo genero un menú?",
///   "answer_es": "Ve a la pantalla de menús y pulsa 'Generar menú'...",
///   "question_en": "How do I generate a menu?",
///   "answer_en": "Go to the menus screen and tap 'Generate menu'...",
///   "order": 1
/// }
/// ```
class FAQModel {
  final String id;
  final String questionEs;
  final String answerEs;
  final String questionEn;
  final String answerEn;
  final int order;

  FAQModel({
    required this.id,
    required this.questionEs,
    required this.answerEs,
    required this.questionEn,
    required this.answerEn,
    this.order = 0,
  });

  /// Parsea FAQ desde Map de Firestore.
  ///
  /// id viene como parámetro separado (document ID).
  factory FAQModel.fromMap(Map<String, dynamic> map, String id) {
    return FAQModel(
      id: id,
      questionEs: map['question_es'] ?? '',
      answerEs: map['answer_es'] ?? '',
      questionEn: map['question_en'] ?? '',
      answerEn: map['answer_en'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  /// Convierte a Map para persistencia en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'question_es': questionEs,
      'answer_es': answerEs,
      'question_en': questionEn,
      'answer_en': answerEn,
      'order': order,
    };
  }
}

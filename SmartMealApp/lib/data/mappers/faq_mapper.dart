import 'package:smartmeal/data/models/faq_model.dart';
import 'package:smartmeal/domain/entities/faq.dart';

class FAQMapper {
  static FAQ toEntity(FAQModel model, String locale) {
    final isSpanish = locale.startsWith('es');
    
    return FAQ(
      id: model.id,
      question: isSpanish ? model.questionEs : model.questionEn,
      answer: isSpanish ? model.answerEs : model.answerEn,
    );
  }
}
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

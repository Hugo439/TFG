import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/faq.dart';
import 'faq_item.dart';

class FAQList extends StatelessWidget {
  final List<FAQ> faqs;

  const FAQList({super.key, required this.faqs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: faqs
          .map((faq) => FAQItem(
                question: faq.question,
                answer: faq.answer,
              ))
          .toList(),
    );
  }
}
import 'package:flutter/material.dart';
import '../../l10n/l10n_ext.dart';

class SupportLocalizer {
  static String category(BuildContext context, String? raw) {
    switch (raw) {
      case 'Dudas': return context.l10n.categoryDudas;
      case 'Errores': return context.l10n.categoryErrores;
      case 'Sugerencias': return context.l10n.categorySugerencias;
      case 'Cuenta': return context.l10n.categoryCuenta;
      case 'Menús': return context.l10n.categoryMenus;
      case 'Otro': return context.l10n.categoryOtro;
      default: return raw ?? '';
    }
  }

  static String status(BuildContext context, String? raw) {
    switch (raw) {
      case 'pendiente': return context.l10n.statusPendiente;
      case 'en proceso': return context.l10n.statusEnProceso;
      case 'respondido': return context.l10n.statusRespondido;
      default: return raw ?? '';
    }
  }
}
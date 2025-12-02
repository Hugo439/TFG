import 'package:flutter/material.dart';

/// Colores usados en SmartMeal (light + dark variants).
class AppColors {
  // Base light
  static const Color primary = Color(0xFF4CAF50);          // #4caf50
  static const Color secondary = Color(0xFFA5D6A7);        // #a5d6a7
  static const Color tertiary = Color(0xFFC8E6C9);         // #c8e6c9
  static const Color alternate = Color(0xFFFFFFFF);        // #ffffff
  static const Color white = Color(0xFFFFFFFF);            // #ffffff

  // Text
  static const Color primaryText = Color(0xFF000000);      // #000000
  static const Color secondaryText = Color(0xFF4A4A4A);    // #4a4a4a
  static const Color mutedText = Color(0xFF757575);        // equivalente a grey[600]

  // Backgrounds
  static const Color primaryBackground = Color(0xFFE8F5E9); // #e8f5e9
  static const Color secondaryBackground = Color(0xFFC8E6C9); // #c8e6c9

  // Accents / semantic
  static const Color accent1 = Color(0xFF76FF03); // #76ff03
  static const Color accent2 = Color(0xFFB2FF59); // #b2ff59
  static const Color accent3 = Color(0xFF388E3C); // #388e3c
  static const Color accent4 = Color(0xFFB2DFDB); // #b2dfdb

  static const Color success = Color(0xFF4CAF50);           // #4caf50
  static const Color error = Color(0xFFF44336);  // #f44336
  static const Color warning = Color(0xFFFFA726); // #ffa726
  static const Color info = Color(0xFF2196F3);   // #2196f3

  // Error containers (light)
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color onErrorContainer = Color(0xFFB71C1C);

  // Custom (gradient / translucent) — tomado de la paleta (ARGB)
  static const Color colorDegradado = Color(0x7EB2FF59); // 0x7E B2 FF 59 (transparente)
  static const Color transparent = Color(0x00000000); // Color completamente transparente

  // Interaction overlays
  static const Color splash = Color(0x1A4CAF50);    // ~10% primary
  static const Color highlight = Color(0x0D4CAF50); // ~5% primary

  // Shadow / border
  static const Color shadow = Color(0x19000000);        // 10% negro (para sombras)
  static const Color shadowStrong = Color(0x33000000);  // 20% negro
  static const Color border = Color(0x1F000000);        // 12% negro (bordes suaves)

  // Navigation specific
  static const Color navBackground = alternate;
  static const Color navBorder = border;

  // Dark variants
  static const Color darkPrimary = Color(0xFF2E7D32);       // #2e7d32
  static const Color darkSecondary = Color(0xFF1B5E20);     // #1b5e20
  static const Color darkTertiary = Color(0xFF004D40);      // #004d40
  static const Color darkAlternate = Color(0xFF121212);     // #121212
  static const Color darkWhite = Color(0xFFFFFFFF);         // #ffffff (para iconos y texto en dark)

  static const Color darkPrimaryText = Color(0xFFFFFFFF);   // #ffffff
  static const Color darkSecondaryText = Color(0xFFCBCBCB); // #cbcbcb

  static const Color darkPrimaryBackground = Color(0xFF1B1B1B); // #1b1b1b
  static const Color darkSecondaryBackground = Color(0xFF464646); // #464646

  static const Color darkAccent1 = Color(0xFFA5D6A7); // #a5d6a7
  static const Color darkAccent2 = Color(0xFF7CB342); // #7cb342
  static const Color darkAccent3 = Color(0xFF1B5E20); // #1b5e20
  static const Color darkAccent4 = Color(0xFF004D40); // #004d40

  static const Color darkSuccess = Color(0xFF2E7D32); // #2e7d32
  static const Color darkError = Color(0xFFD32F2F);   // #d32f2f
  static const Color darkWarning = Color(0xFFFBC02D); // #fbc02d
  static const Color darkInfo = Color(0xFF1976D2);    // #1976d2

  // Error containers (dark)
  static const Color darkErrorContainer = Color(0xFF5D1F1F);
  static const Color darkOnErrorContainer = Color(0xFFFFCDD2);

  // Colores de categorías de soporte (LIGHT)
  static const Color categoryDudas = Color(0xFF2196F3);        // Azul
  static const Color categoryErrores = Color(0xFFF44336);      // Rojo
  static const Color categorySugerencias = Color(0xFF9C27B0);  // Púrpura
  static const Color categoryCuenta = Color(0xFFFF9800);       // Naranja
  static const Color categoryMenus = Color(0xFF4CAF50);        // Verde
  static const Color categoryOtro = Color(0xFF757575);         // Gris

  // Colores de categorías de soporte (DARK)
  static const Color darkCategoryDudas = Color(0xFF64B5F6);        // Azul claro
  static const Color darkCategoryErrores = Color(0xFFE57373);      // Rojo claro
  static const Color darkCategorySugerencias = Color(0xFFBA68C8);  // Púrpura claro
  static const Color darkCategoryCuenta = Color(0xFFFFB74D);       // Naranja claro
  static const Color darkCategoryMenus = Color(0xFF81C784);        // Verde claro
  static const Color darkCategoryOtro = Color(0xFFBDBDBD);         // Gris claro
}
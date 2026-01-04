import 'package:flutter/material.dart';

/// Paleta de colores completa de SmartMeal (light + dark).
///
/// Responsabilidades:
/// - Definir todos los colores usados en la app
/// - Variantes light y dark para cada color
/// - Colores semánticos (success, error, warning, info)
/// - Colores de estadísticas (macros, costos)
/// - Colores de categorías de soporte
///
/// Estructura:
/// - **Base light**: primary, secondary, tertiary
/// - **Text**: primaryText, secondaryText, mutedText
/// - **Backgrounds**: primaryBackground, secondaryBackground
/// - **Accents**: accent1-4 para variaciones
/// - **Semantic**: success, error, warning, info
/// - **Stats**: protein, carbs, fats, cost
/// - **Containers**: errorContainer, onErrorContainer
/// - **Interaction**: splash, highlight, shadow, border
/// - **Navigation**: navBackground, navBorder
/// - **Dark variants**: darkPrimary, darkSecondary, etc.
///
/// Colores principales:
/// - primary: #4CAF50 (verde principal)
/// - secondary: #A5D6A7 (verde claro)
/// - tertiary: #C8E6C9 (verde muy claro)
///
/// Colores de texto:
/// - primaryText: #000000 (negro)
/// - secondaryText: #4A4A4A (gris oscuro)
/// - mutedText: #757575 (gris medio)
///
/// Backgrounds light:
/// - primaryBackground: #E8F5E9 (verde muy claro)
/// - secondaryBackground: #C8E6C9 (verde claro)
///
/// Accents:
/// - accent1: #76FF03 (verde brillante)
/// - accent2: #B2FF59 (verde lima)
/// - accent3: #388E3C (verde oscuro)
/// - accent4: #B2DFDB (turquesa claro)
///
/// Semánticos:
/// - success: #4CAF50 (verde)
/// - error: #F44336 (rojo)
/// - warning: #FFA726 (naranja)
/// - info: #2196F3 (azul)
///
/// Estadísticas:
/// - statProtein: #7C3AED (púrpura)
/// - statCarbs: #EC4899 (rosa)
/// - statFats: #0EA5E9 (azul cielo)
/// - statCost: #FB923C (naranja)
///
/// Dark variants:
/// - darkPrimary: #2E7D32 (verde oscuro)
/// - darkSecondary: #1B5E20 (verde muy oscuro)
/// - darkPrimaryBackground: #0D1117 (negro azulado)
/// - darkSecondaryBackground: #161B22 (gris muy oscuro)
/// - darkPrimaryText: #FFFFFF (blanco)
/// - darkSecondaryText: #CBCBCB (gris claro)
///
/// Categorías de soporte:
/// - categoryDudas / darkCategoryDudas
/// - categoryErrores / darkCategoryErrores
/// - categorySugerencias / darkCategorySugerencias
/// - categoryCuenta / darkCategoryCuenta
/// - categoryMenus / darkCategoryMenus
/// - categoryOtro / darkCategoryOtro
///
/// Interaction overlays:
/// - splash: 10% primary para ripple
/// - highlight: 5% primary para hover
/// - shadow: 10% negro para sombras
/// - shadowStrong: 20% negro para sombras intensas
/// - border: 12% negro para bordes suaves
///
/// Uso:
/// ```dart
/// Container(
///   color: AppColors.primary,
///   child: Text(
///     'Título',
///     style: TextStyle(color: AppColors.primaryText),
///   ),
/// )
///
/// // Con tema
/// final isDark = Theme.of(context).brightness == Brightness.dark;
/// final bgColor = isDark
///   ? AppColors.darkPrimaryBackground
///   : AppColors.primaryBackground;
/// ```
class AppColors {
  // Base light
  static const Color primary = Color(0xFF4CAF50); // #4caf50
  static const Color secondary = Color(0xFFA5D6A7); // #a5d6a7
  static const Color tertiary = Color(0xFFC8E6C9); // #c8e6c9
  static const Color alternate = Color(0xFFFFFFFF); // #ffffff
  static const Color white = Color(0xFFFFFFFF); // #ffffff

  // Text
  static const Color primaryText = Color(0xFF000000); // #000000
  static const Color secondaryText = Color(0xFF4A4A4A); // #4a4a4a
  static const Color mutedText = Color(0xFF757575); // equivalente a grey[600]

  // Backgrounds
  static const Color primaryBackground = Color(0xFFE8F5E9); // #e8f5e9
  static const Color secondaryBackground = Color(0xFFC8E6C9); // #c8e6c9

  // Accents / semantic
  static const Color accent1 = Color(0xFF76FF03); // #76ff03
  static const Color accent2 = Color(0xFFB2FF59); // #b2ff59
  static const Color accent3 = Color(0xFF388E3C); // #388e3c
  static const Color accent4 = Color(0xFFB2DFDB); // #b2dfdb

  static const Color success = Color(0xFF4CAF50); // #4caf50
  static const Color error = Color(0xFFF44336); // #f44336
  static const Color warning = Color(0xFFFFA726); // #ffa726
  static const Color info = Color(0xFF2196F3); // #2196f3

  // Stats colors (macros, precios, etc)
  static const Color statProtein = Color(0xFF7C3AED); // púrpura (proteína)
  static const Color statCarbs = Color(0xFFEC4899); // rosa (carbos)
  static const Color statFats = Color(0xFF0EA5E9); // azul cielo (grasas)
  static const Color statCost = Color(0xFFFB923C); // naranja (costo)

  // Error containers (light)
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color onErrorContainer = Color(0xFFB71C1C);

  // Custom (gradient / translucent) — tomado de la paleta (ARGB)
  static const Color colorDegradado = Color(
    0x7EB2FF59,
  ); // 0x7E B2 FF 59 (transparente)
  static const Color transparent = Color(
    0x00000000,
  ); // Color completamente transparente

  // Interaction overlays
  static const Color splash = Color(0x1A4CAF50); // ~10% primary
  static const Color highlight = Color(0x0D4CAF50); // ~5% primary

  // Shadow / border
  static const Color shadow = Color(0x19000000); // 10% negro (para sombras)
  static const Color shadowStrong = Color(0x33000000); // 20% negro
  static const Color border = Color(0x1F000000); // 12% negro (bordes suaves)

  // Navigation specific
  static const Color navBackground = alternate;
  static const Color navBorder = border;

  // Dark variants
  static const Color darkPrimary = Color(0xFF2E7D32); // #2e7d32
  static const Color darkSecondary = Color(0xFF1B5E20); // #1b5e20
  static const Color darkTertiary = Color(0xFF004D40); // #004d40
  static const Color darkAlternate = Color(0xFF121212); // #121212
  static const Color darkWhite = Color(
    0xFFFFFFFF,
  ); // #ffffff (para iconos y texto en dark)

  static const Color darkPrimaryText = Color(0xFFFFFFFF); // #ffffff
  static const Color darkSecondaryText = Color(0xFFCBCBCB); // #cbcbcb

  static const Color darkPrimaryBackground = Color(
    0xFF0D1117,
  ); // Fondo primario
  static const Color darkSecondaryBackground = Color(
    0xFF161B22,
  ); // Fondo secundario

  static const Color darkAccent1 = Color(0xFFA5D6A7); // #a5d6a7
  static const Color darkAccent2 = Color(0xFF7CB342); // #7cb342
  static const Color darkAccent3 = Color(0xFF1B5E20); // #1b5e20
  static const Color darkAccent4 = Color(0xFF004D40); // #004d40

  static const Color darkSuccess = Color(0xFF2E7D32); // #2e7d32
  static const Color darkError = Color(0xFFD32F2F); // #d32f2f
  static const Color darkWarning = Color(0xFFFBC02D); // #fbc02d
  static const Color darkInfo = Color(0xFF1976D2); // #1976d2

  // Dark stats colors (macros, precios, etc)
  static const Color darkStatProtein = Color(0xFFA78BFA); // púrpura claro
  static const Color darkStatCarbs = Color(0xFFF472B6); // rosa claro
  static const Color darkStatFats = Color(0xFF38BDF8); // azul claro
  static const Color darkStatCost = Color(0xFFFBBF24); // naranja claro

  // Error containers (dark)
  static const Color darkErrorContainer = Color(0xFF5D1F1F);
  static const Color darkOnErrorContainer = Color(0xFFFFCDD2);

  // Colores de categorías de soporte (LIGHT)
  static const Color categoryDudas = Color(0xFF2196F3); // Azul
  static const Color categoryErrores = Color(0xFFF44336); // Rojo
  static const Color categorySugerencias = Color(0xFF9C27B0); // Púrpura
  static const Color categoryCuenta = Color(0xFFFF9800); // Naranja
  static const Color categoryMenus = Color(0xFF4CAF50); // Verde
  static const Color categoryOtro = Color(0xFF757575); // Gris

  // Colores de categorías de soporte (DARK)
  static const Color darkCategoryDudas = Color(0xFF64B5F6); // Azul claro
  static const Color darkCategoryErrores = Color(0xFFE57373); // Rojo claro
  static const Color darkCategorySugerencias = Color(
    0xFFBA68C8,
  ); // Púrpura claro
  static const Color darkCategoryCuenta = Color(0xFFFFB74D); // Naranja claro
  static const Color darkCategoryMenus = Color(0xFF81C784); // Verde claro
  static const Color darkCategoryOtro = Color(0xFFBDBDBD); // Gris claro

  // Nuevos colores para dark mode mejorado
  static const Color darkSurface = Color(0xFF161B22); // Superficie
  static const Color darkSurfaceContainer = Color(0xFF21262D); // Contenedor
  static const Color darkSurfaceContainerHigh = Color(
    0xFF30363D,
  ); // Contenedor alto
  static const Color darkSurfaceContainerHighest = Color(
    0xFF484F58,
  ); // Contenedor más alto
  static const Color darkOnSurface = Color(0xFFE6EDF3); // Texto en superficie
  static const Color darkOnSurfaceVariant = Color(0xFF7D8590); // Texto variante
  static const Color darkOutline = Color(0xFF6E7681); // Bordes
  static const Color darkOutlineVariant = Color(0xFF30363D); // Bordes variantes
}

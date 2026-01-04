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
  // ==================== LIGHT MODE COLORS ====================

  // Primary Palette - Verde vibrante y moderno
  static const Color primary = Color(0xFF10B981); // Verde esmeralda moderno
  static const Color primaryLight = Color(0xFF34D399); // Verde claro
  static const Color primaryDark = Color(0xFF059669); // Verde oscuro
  static const Color onPrimary = Color(0xFFFFFFFF); // Texto en primary

  // Secondary Palette - Complemento cálido
  static const Color secondary = Color(0xFFF59E0B); // Ámbar vibrante
  static const Color secondaryLight = Color(0xFFFBBF24); // Ámbar claro
  static const Color secondaryDark = Color(0xFFD97706); // Ámbar oscuro
  static const Color onSecondary = Color(0xFFFFFFFF); // Texto en secondary

  // Tertiary Palette - Acento fresco
  static const Color tertiary = Color(0xFF06B6D4); // Cyan moderno
  static const Color tertiaryLight = Color(0xFF22D3EE); // Cyan claro
  static const Color tertiaryDark = Color(0xFF0891B2); // Cyan oscuro
  static const Color onTertiary = Color(0xFFFFFFFF); // Texto en tertiary

  // Neutral Palette - Grises sofisticados
  static const Color neutral50 = Color(0xFFFAFAFA); // Casi blanco
  static const Color neutral100 = Color(0xFFF5F5F5); // Gris muy claro
  static const Color neutral200 = Color(0xFFE5E5E5); // Gris claro
  static const Color neutral300 = Color(0xFFD4D4D4); // Gris medio-claro
  static const Color neutral400 = Color(0xFFA3A3A3); // Gris medio
  static const Color neutral500 = Color(0xFF737373); // Gris
  static const Color neutral600 = Color(0xFF525252); // Gris oscuro
  static const Color neutral700 = Color(0xFF404040); // Gris muy oscuro
  static const Color neutral800 = Color(0xFF262626); // Casi negro
  static const Color neutral900 = Color(0xFF171717); // Negro suave

  // Surface & Background - Superficies con profundidad
  static const Color surface = Color(0xFFFFFFFF); // Blanco puro
  static const Color surfaceContainer = Color(
    0xFFF9FAFB,
  ); // Contenedor principal
  static const Color surfaceContainerLow = Color(0xFFF3F4F6); // Contenedor bajo
  static const Color surfaceContainerHigh = Color(
    0xFFE5E7EB,
  ); // Contenedor alto
  static const Color surfaceContainerHighest = Color(
    0xFFD1D5DB,
  ); // Contenedor máximo
  static const Color surfaceBright = Color(0xFFFFFFFF); // Superficie brillante
  static const Color surfaceDim = Color(0xFFE5E7EB); // Superficie tenue

  static const Color background = Color(0xFFFAFAFA); // Fondo general
  static const Color backgroundSecondary = Color(
    0xFFF5F5F5,
  ); // Fondo secundario

  // Text Colors - Jerarquía clara
  static const Color textPrimary = Color(0xFF111827); // Texto principal
  static const Color textSecondary = Color(0xFF6B7280); // Texto secundario
  static const Color textTertiary = Color(0xFF9CA3AF); // Texto terciario
  static const Color textDisabled = Color(0xFFD1D5DB); // Texto deshabilitado

  // Semantic Colors - Estados y acciones
  static const Color success = Color(0xFF10B981); // Verde éxito
  static const Color successLight = Color(0xFFD1FAE5); // Verde éxito claro
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFEF4444); // Rojo error
  static const Color errorLight = Color(0xFFFEE2E2); // Rojo error claro
  static const Color onError = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFF59E0B); // Ámbar advertencia
  static const Color warningLight = Color(
    0xFFFEF3C7,
  ); // Ámbar advertencia claro
  static const Color onWarning = Color(0xFFFFFFFF);

  static const Color info = Color(0xFF3B82F6); // Azul información
  static const Color infoLight = Color(0xFFDBEAFE); // Azul información claro
  static const Color onInfo = Color(0xFFFFFFFF);

  // Statistics Colors - Macronutrientes con gradientes
  static const Color statProtein = Color(0xFF8B5CF6); // Púrpura proteína
  static const Color statProteinLight = Color(0xFFEDE9FE); // Púrpura claro

  static const Color statCarbs = Color(0xFFEC4899); // Rosa carbohidratos
  static const Color statCarbsLight = Color(0xFFFCE7F3); // Rosa claro

  static const Color statFats = Color(0xFF06B6D4); // Cyan grasas
  static const Color statFatsLight = Color(0xFFCFFAFE); // Cyan claro

  static const Color statCalories = Color(0xFFF59E0B); // Ámbar calorías
  static const Color statCaloriesLight = Color(0xFFFEF3C7); // Ámbar claro

  static const Color statCost = Color(0xFF10B981); // Verde costo
  static const Color statCostLight = Color(0xFFD1FAE5); // Verde claro

  // Category Colors - Categorías de soporte
  static const Color categoryDudas = Color(0xFF3B82F6); // Azul
  static const Color categoryErrores = Color(0xFFEF4444); // Rojo
  static const Color categorySugerencias = Color(0xFF8B5CF6); // Púrpura
  static const Color categoryCuenta = Color(0xFFF59E0B); // Ámbar
  static const Color categoryMenus = Color(0xFF10B981); // Verde
  static const Color categoryOtro = Color(0xFF6B7280); // Gris

  // Interactive States - Estados de interacción
  static const Color hover = Color(0x0F10B981); // Hover sutil (6% opacity)
  static const Color pressed = Color(0x1F10B981); // Pressed (12% opacity)
  static const Color focus = Color(0x1F10B981); // Focus (12% opacity)
  static const Color selected = Color(0x1F10B981); // Selected (12% opacity)
  static const Color disabled = Color(0x61000000); // Disabled (38% opacity)

  // Borders & Dividers
  static const Color border = Color(0xFFE5E7EB); // Borde estándar
  static const Color borderStrong = Color(0xFFD1D5DB); // Borde fuerte
  static const Color divider = Color(0xFFE5E7EB); // Divisor

  // Shadows - Sistema de sombras
  static const Color shadow = Color(0x0A000000); // Sombra suave (4% opacity)
  static const Color shadowMedium = Color(
    0x14000000,
  ); // Sombra media (8% opacity)
  static const Color shadowStrong = Color(
    0x1F000000,
  ); // Sombra fuerte (12% opacity)

  // Overlays - Capas de overlay
  static const Color overlay = Color(
    0x80000000,
  ); // Overlay oscuro (50% opacity)
  static const Color overlayLight = Color(
    0x40000000,
  ); // Overlay claro (25% opacity)

  // Special - Colores especiales
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Gradients - Gradientes predefinidos
  static const List<Color> primaryGradient = [
    Color(0xFF10B981), // primary
    Color(0xFF059669), // primaryDark
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFF59E0B), // secondary
    Color(0xFFD97706), // secondaryDark
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981), // success
    Color(0xFF34D399), // success light
  ];

  // ==================== LEGACY COMPATIBILITY COLORS ====================
  // Colores para mantener compatibilidad con código existente

  // Legacy light colors
  static const Color primaryBackground = background; // Alias
  static const Color secondaryBackground = backgroundSecondary; // Alias
  static const Color primaryText = textPrimary; // Alias
  static const Color secondaryText = textSecondary; // Alias
  static const Color mutedText = textTertiary; // Alias
  static const Color accent1 = primaryLight; // Alias
  static const Color accent2 = secondaryLight; // Alias
  static const Color accent3 = primaryDark; // Alias
  static const Color accent4 = tertiaryLight; // Alias
  static const Color alternate = surface; // Alias
  static const Color splash = hover; // Alias
  static const Color highlight = pressed; // Alias
  static const Color navBackground = surface; // Alias
  static const Color navBorder = border; // Alias
  static const Color errorContainer = errorLight; // Alias
  static const Color onErrorContainer = error; // Alias

  // ==================== DARK MODE COLORS ====================

  // Primary Palette Dark
  static const Color darkPrimary = Color(0xFF34D399); // Verde claro
  static const Color darkPrimaryLight = Color(0xFF6EE7B7); // Verde muy claro
  static const Color darkPrimaryDark = Color(0xFF10B981); // Verde medio
  static const Color darkOnPrimary = Color(0xFF111827); // Texto en primary

  // Secondary Palette Dark
  static const Color darkSecondary = Color(0xFFFBBF24); // Ámbar claro
  static const Color darkSecondaryLight = Color(0xFFFCD34D); // Ámbar muy claro
  static const Color darkSecondaryDark = Color(0xFFF59E0B); // Ámbar medio
  static const Color darkOnSecondary = Color(0xFF111827); // Texto en secondary

  // Tertiary Palette Dark
  static const Color darkTertiary = Color(0xFF22D3EE); // Cyan claro
  static const Color darkTertiaryLight = Color(0xFF67E8F9); // Cyan muy claro
  static const Color darkTertiaryDark = Color(0xFF06B6D4); // Cyan medio
  static const Color darkOnTertiary = Color(0xFF111827); // Texto en tertiary

  // Surface & Background Dark
  static const Color darkSurface = Color(0xFF111827); // Superficie principal
  static const Color darkSurfaceContainer = Color(
    0xFF1F2937,
  ); // Contenedor principal
  static const Color darkSurfaceContainerHigh = Color(
    0xFF374151,
  ); // Contenedor alto
  static const Color darkSurfaceContainerHighest = Color(
    0xFF4B5563,
  ); // Contenedor máximo
  static const Color darkBackground = Color(0xFF0F172A); // Fondo general
  static const Color darkBackgroundSecondary = Color(
    0xFF1E293B,
  ); // Fondo secundario

  // Text Colors Dark
  static const Color darkTextPrimary = Color(0xFFF9FAFB); // Texto principal
  static const Color darkTextSecondary = Color(0xFFD1D5DB); // Texto secundario
  static const Color darkTextTertiary = Color(0xFF9CA3AF); // Texto terciario

  // Semantic Colors Dark
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkSuccessLight = Color(0xFF064E3B);

  static const Color darkError = Color(0xFFF87171);
  static const Color darkErrorLight = Color(0xFF7F1D1D);

  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkWarningLight = Color(0xFF78350F);

  static const Color darkInfo = Color(0xFF60A5FA);
  static const Color darkInfoLight = Color(0xFF1E3A8A);

  // Statistics Colors Dark
  static const Color darkStatProtein = Color(0xFFA78BFA);
  static const Color darkStatCarbs = Color(0xFFF472B6);
  static const Color darkStatFats = Color(0xFF22D3EE);
  static const Color darkStatCalories = Color(0xFFFBBF24);
  static const Color darkStatCost = Color(0xFF34D399);

  // Shadows Dark (faltaba shadowMedium)
  static const Color darkShadowMedium = Color(0x29000000); // 16% opacity

  // Category Colors Dark
  static const Color darkCategoryDudas = Color(0xFF60A5FA);
  static const Color darkCategoryErrores = Color(0xFFF87171);
  static const Color darkCategorySugerencias = Color(0xFFA78BFA);
  static const Color darkCategoryCuenta = Color(0xFFFBBF24);
  static const Color darkCategoryMenus = Color(0xFF34D399);
  static const Color darkCategoryOtro = Color(0xFF9CA3AF);

  // Borders & Shadows Dark
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkShadow = Color(0x1F000000);

  // Legacy compatibility colors for dark mode
  static const Color darkOnSurface = darkTextPrimary;
  static const Color darkOnSurfaceVariant = darkTextSecondary;
  static const Color darkOutline = darkBorder;
  static const Color darkOutlineVariant = Color(0xFF4B5563);
  static const Color darkPrimaryText = darkTextPrimary;
  static const Color darkSecondaryText = darkTextSecondary;
  static const Color darkPrimaryBackground = darkBackground;
  static const Color darkSecondaryBackground = darkBackgroundSecondary;
  static const Color darkErrorContainer = darkErrorLight;
  static const Color darkOnErrorContainer = Color(0xFFFEE2E2);
  static const Color darkAlternate = darkSurface;
  static const Color darkWhite = Color(0xFFFFFFFF);
  static const Color darkAccent1 = darkPrimaryLight;
  static const Color darkAccent2 = darkSecondaryLight;
  static const Color darkAccent3 = darkPrimaryDark;
  static const Color darkAccent4 = darkTertiaryLight;
}

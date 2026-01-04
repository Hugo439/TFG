# Conjunto de Pruebas SmartMeal - TFG

Este documento describe el conjunto completo de pruebas implementadas para el proyecto SmartMeal, diseñadas para demostrar calidad de código y cobertura exhaustiva para el Trabajo de Fin de Grado (TFG).

## Estructura de Carpetas

**IMPORTANTE**: Las pruebas en Flutter siguen una estructura estándar:

```
SmartMealApp/
├── test/                    # Pruebas unitarias y de widgets
│   ├── unit/               # Tests de lógica de negocio
│   └── widget/             # Tests de componentes UI
├── integration_test/        # Pruebas de integración E2E (NO dentro de test/)
│   └── *.dart              # Tests que requieren emulador
└── lib/                    # Código fuente
```

**Nota**: `integration_test/` está en la raíz del proyecto, NO dentro de `test/`. Esta es la convención oficial de Flutter para pruebas E2E que requieren ejecutarse en un dispositivo o emulador real.

## Resumen de Pruebas

### Pruebas Unitarias (4 archivos, ~50+ tests)
- **calorie_calculator_test.dart**: Validación de cálculos calóricos (BMR, TDEE, ajustes por objetivo)
- **calorie_distribution_test.dart**: Distribución de calorías por comida (desayuno/comida/merienda/cena)
- **ingredient_aggregator_test.dart**: Deduplicación y agregación de ingredientes para lista de compras
- **value_objects_test.dart**: Validaciones de Value Objects (DisplayName, Height, Weight)

### Pruebas de Widgets (3 archivos, ~30+ tests)
- **home_view_test.dart**: Renderizado de pantalla principal con 6 tarjetas y navegación
- **theme_and_locale_test.dart**: Cambio dinámico de tema (light/dark) y localización (es/en)
- **weekly_menu_test.dart**: Visualización de menú semanal (7 días × 4 comidas = 28 recetas)

### Pruebas de Integración (2 archivos, ~5+ tests E2E)
- **full_app_flow_test.dart**: Flujo completo Login → Perfil → Menú → Shopping List
- **theme_and_locale_integration_test.dart**: Cambios globales de tema e idioma en toda la app

## Ejecutar Pruebas

### Requisitos Previos
```bash
# Verificar que Flutter está instalado
flutter --version

# Instalar dependencias
flutter pub get
```

### Ejecutar Todas las Pruebas Unitarias
```bash
flutter test test/unit/
```

### Ejecutar Prueba Unitaria Específica
```bash
# Cálculo de calorías
flutter test test/unit/calorie_calculator_test.dart

# Distribución de calorías
flutter test test/unit/calorie_distribution_test.dart

# Agregación de ingredientes
flutter test test/unit/ingredient_aggregator_test.dart

# Value Objects
flutter test test/unit/value_objects_test.dart
```

### Ejecutar Todas las Pruebas de Widgets
```bash
flutter test test/widget/
```

### Ejecutar Prueba de Widget Específica
```bash
# HomeView
flutter test test/widget/home_view_test.dart

# Tema e idioma
flutter test test/widget/theme_and_locale_test.dart

# Menú semanal
flutter test test/widget/weekly_menu_test.dart
```

### Ejecutar Pruebas de Integración (E2E)
```bash
# Nota: Requiere emulador o dispositivo conectado

# Flujo completo de la app
flutter test integration_test/full_app_flow_test.dart

# Cambios globales de configuración
flutter test integration_test/theme_and_locale_integration_test.dart
```

### Ejecutar TODAS las Pruebas (Unit + Widget)
```bash
flutter test
```

### Generar Reporte de Cobertura
```bash
# Generar cobertura
flutter test --coverage

# Ver reporte HTML (requiere lcov instalado)
genhtml coverage/lcov.info -o coverage/html
# Abrir coverage/html/index.html en navegador
```

## Descripción Detallada de Pruebas

### 1. Pruebas Unitarias

#### `calorie_calculator_test.dart`
**Objetivo**: Validar cálculos de necesidades calóricas usando la fórmula Mifflin-St Jeor.

**Casos de prueba principales**:
- BMR para hombre adulto promedio (70kg, 175cm, 25 años)
- BMR para mujer adulta promedio (60kg, 165cm, 28 años)
- Edge cases: persona mayor (70 años), persona joven (18 años)
- TDEE con diferentes niveles de actividad (sedentario, ligero, moderado, activo, muy activo)
- Ajustes calóricos por objetivo (perder peso, mantener, ganar músculo)
- Flujo completo: BMR → TDEE → Ajuste por objetivo

**Ejemplo de resultado esperado**:
- Mujer 28 años, 60kg, 165cm → BMR ≈ 1330 kcal/día
- Con actividad moderada → TDEE ≈ 2062 kcal/día
- Objetivo perder peso → Target ≈ 1562 kcal/día (déficit 500 kcal)

---

#### `calorie_distribution_test.dart`
**Objetivo**: Verificar distribución correcta de calorías entre las 4 comidas del día.

**Casos de prueba principales**:
- Distribución para 2000 kcal/día (caso típico)
- Distribución para 1500 kcal/día (déficit calórico)
- Distribución para 3000 kcal/día (superávit calórico)
- Comida siempre tiene el mayor rango calórico
- Merienda siempre tiene el menor rango calórico
- Merienda tiene mayor flexibilidad (±15% vs ±10%)

**Porcentajes de distribución**:
- Desayuno: 27.5% ±10% → [495-605] kcal en 2000 kcal/día
- Comida: 37.5% ±10% → [675-825] kcal
- Merienda: 12.5% ±15% → [212-287] kcal
- Cena: 27.5% ±10% → [495-605] kcal

---

#### `ingredient_aggregator_test.dart`
**Objetivo**: Verificar deduplicación y suma de ingredientes para lista de compras.

**Casos de prueba principales**:
- Agregar un solo ingrediente
- Agregar múltiples ingredientes diferentes
- Normalización: "Tomate", "TOMATE", "tomate" → mismo ingrediente
- Deduplicación: mismo ingrediente en 7 recetas → 1 entrada sumada
- Tracking de menús: registra en qué recetas aparece cada ingrediente
- Tipos de unidad: weight (g/kg), volume (ml/L), unit (uds)
- Ignorar ingredientes con nombre vacío

**Ejemplo de agregación**:
```
Input:
  - Pollo: 250g (Menu 1)
  - Pollo: 300g (Menu 2)
  - pollo: 200g (Menu 3)

Output:
  - Pollo: 750g (usado en Menu 1, Menu 2, Menu 3)
```

---

#### `value_objects_test.dart`
**Objetivo**: Validar restricciones de Value Objects del dominio.

**Casos de prueba principales**:

**DisplayName**:
- Nombre válido se crea correctamente
- Trim de espacios extra
- Lanza error si vacío o menos de 2 caracteres
- Lanza error si más de 50 caracteres
- `firstLetter` devuelve primera letra en mayúscula

**Height**:
- Altura válida (50-300 cm)
- `formatted`: "175 cm"
- `meters`: 1.75
- `fromString`: parsea "170" correctamente
- Lanza error si fuera de rango

**Weight**:
- Peso válido (20-500 kg)
- `formatted`: "75.5 kg"
- `calculateBMI`: 70kg / (1.75m)² = 22.86
- Lanza error si fuera de rango

---

### 2. Pruebas de Widgets

#### `home_view_test.dart`
**Objetivo**: Verificar renderizado correcto de la pantalla principal.

**Casos de prueba principales**:
- Renderiza HomeView sin errores
- Muestra título de bienvenida
- Renderiza exactamente 6 tarjetas (MenuCard)
- BottomNavigationBar con 5 tabs
- Tab Home (índice 1) seleccionado
- Tarjetas específicas con íconos correctos (person, restaurant_menu, shopping_cart, bar_chart, help_outline, settings)
- Responsive: 4 columnas (>1100px), 3 columnas (700-1100px), 2 columnas (<700px)
- Todas las tarjetas son interactivas (tienen onTap)
- Soporte de localización (español/inglés)

---

#### `theme_and_locale_test.dart`
**Objetivo**: Verificar cambios dinámicos de tema e idioma con Provider.

**Casos de prueba principales**:

**ThemeProvider**:
- Inicia con tema claro por defecto
- `toggleTheme()` cambia a tema oscuro
- Alterna correctamente entre claro y oscuro múltiples veces
- UI reacciona al cambio (colores cambian)

**LocaleProvider**:
- Inicia con español por defecto
- `setLocale(Locale('en'))` cambia a inglés
- Textos cambian al cambiar idioma
- Alterna correctamente entre idiomas

**Integración**:
- Cambio simultáneo de tema e idioma funciona correctamente

---

#### `weekly_menu_test.dart`
**Objetivo**: Verificar renderizado de menú semanal con 28 recetas.

**Casos de prueba principales**:
- WeeklyMenu tiene 7 días
- Cada DayMenu tiene 4 comidas
- Total de 28 recetas en menú semanal
- RecipeCard muestra nombre, calorías, tiempo de preparación
- RecipeCard es interactiva (onTap)
- Navegación entre días funciona correctamente
- Cada día muestra 4 RecipeCard
- Calorías diarias: 400 + 700 + 250 + 550 = 1900 kcal
- Calorías semanales: 1900 × 7 = 13300 kcal
- No hay recetas duplicadas en el mismo día
- dayNumber secuencial del 1 al 7

---

### 3. Pruebas de Integración (E2E)

#### `full_app_flow_test.dart`
**Objetivo**: Verificar flujo completo del usuario desde login hasta lista de compras.

**Flujo principal**:
1. **Login**: Autenticación con email/password
2. **Home**: Verificar 5 tabs en BottomNavigationBar
3. **Perfil**: Navegar y verificar campos de formulario
4. **Menú**: Navegar y generar/ver menú semanal
5. **Shopping**: Generar lista desde menú, marcar items, ver precio total
6. **Añadir ingrediente**: Abrir FAB y añadir ingrediente manual
7. **Navegación completa**: Verificar que todos los tabs funcionan sin errores

**Flujo secundario**:
- Editar perfil (cambiar peso)
- Regenerar menú con nuevas calorías
- Verificar que calorías se ajustaron

---

#### `theme_and_locale_integration_test.dart`
**Objetivo**: Verificar que cambios de configuración se aplican globalmente.

**Flujos**:
1. **Cambio de tema global**:
   - Ir a Configuración
   - Cambiar tema a oscuro
   - Navegar a Home, Perfil, Menú
   - Verificar que tema oscuro se aplicó en todas las pantallas
   - Volver a tema claro

2. **Cambio de idioma global**:
   - Ir a Configuración
   - Cambiar de español a inglés
   - Verificar textos en Home, Perfil
   - Volver a español

3. **Persistencia**:
   - Cambiar tema + idioma
   - Navegar entre pantallas
   - Verificar que configuración se mantiene

---

## Cobertura de Pruebas

### Áreas Cubiertas

#### Capa de Dominio
- Cálculo de calorías (BMR, TDEE, ajustes)
- Distribución de calorías por comida
- Agregación de ingredientes
- Validación de Value Objects

#### Capa de Presentación
- HomeView con navegación
- Cambio de tema (ThemeProvider)
- Cambio de idioma (LocaleProvider)
- Menú semanal con 28 recetas

#### Flujos de Usuario
- Login → Perfil → Menú → Shopping
- Editar perfil y regenerar menú
- Cambios globales de configuración

### Tipos de Pruebas
- **Unit Tests**: Lógica de negocio aislada
- **Widget Tests**: Componentes visuales individuales
- **Integration Tests**: Flujos completos de usuario

### Técnicas de Testing
- **Golden Tests**: No implementados (opcional)
- **Mocks**: Provider overrides para aislar componentes
- **Edge Cases**: Valores límite (min/max altura, peso, edad)
- **Happy Path**: Flujos exitosos esperados
- **Error Handling**: Validaciones de entrada inválida

---

## Troubleshooting

### Error: "No se encuentra el archivo"
```bash
# Asegúrate de estar en el directorio raíz del proyecto SmartMealApp
cd SmartMealApp

# Verifica que el archivo existe
ls test/unit/calorie_calculator_test.dart
```

### Error: "MissingPluginException"
```bash
# Las pruebas de integración requieren un emulador o dispositivo
flutter devices

# Si no hay dispositivos, inicia un emulador
flutter emulators --launch <emulator_id>
```

### Error: "Firebase no inicializado"
Las pruebas de integración requieren Firebase configurado. Asegúrate de tener:
- `google-services.json` en `android/app/`
- `firebase_options.dart` generado
- Emulador con Google Play Services

### Tests lentos
```bash
# Ejecutar tests en paralelo (más rápido)
flutter test --concurrency=4
```

### Fallo en tests de widget por timeout
```bash
# Aumentar timeout
flutter test --timeout=2m
```

---

## Recursos Adicionales

### Documentación Oficial
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

### Best Practices
- Mantén los tests independientes (no depender de orden de ejecución)
- Usa `setUp` y `tearDown` para inicialización/limpieza
- Nombres descriptivos: `test('Debe calcular BMR para hombre adulto', ...)`
- Comentarios AAA: Arrange (Given), Act (When), Assert (Then)

### Coverage Goals
- **Unit Tests**: >80% de cobertura en lógica de negocio
- **Widget Tests**: Componentes críticos de UI
- **Integration Tests**: Flujos principales de usuario

---

## Contacto y Soporte

Para cualquier duda sobre las pruebas:
- Revisar logs de error con `flutter test --verbose`
- Verificar versiones: `flutter doctor -v`
- Limpiar build: `flutter clean && flutter pub get`

---

**Última actualización**: Enero 2026
**Versión de Flutter**: 3.x
**Proyecto**: SmartMeal - TFG

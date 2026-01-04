# Cómo Ejecutar la Aplicación SmartMeal

## Requisitos Previos

### 1. Software Necesario
- **Flutter SDK** (versión 3.9.2 o superior)
  - Descargar desde: https://flutter.dev/docs/get-started/install
- **Android Studio** o **VS Code** con extensiones de Flutter/Dart
- **Git** para clonar el repositorio
- **Android SDK** (si se usa Android Studio)
- **Dispositivo Android** o **Emulador Android** configurado

### 2. Configuración de Firebase
La aplicación requiere Firebase para funcionar. Asegúrate de tener:
- Archivo `google-services.json` en `SmartMealApp/android/app/`
- Archivo `firebase_options.dart` en `SmartMealApp/lib/`

## Pasos para Ejecutar

### 1. Clonar el Repositorio
```bash
git clone https://github.com/Hugo439/TFG.git
cd TFG/SmartMealApp
```

### 2. Instalar Dependencias
```bash
flutter pub get
```

Este comando descarga todas las dependencias del proyecto especificadas en `pubspec.yaml`.

### 3. Verificar Configuración de Flutter
```bash
flutter doctor
```

Este comando verifica que todo esté correctamente configurado. Resuelve cualquier problema indicado con una ❌.

### 4. Conectar Dispositivo o Iniciar Emulador

#### Opción A: Dispositivo Físico Android
1. Habilita **Opciones de Desarrollador** en tu dispositivo Android
2. Activa **Depuración USB**
3. Conecta el dispositivo por USB
4. Verifica la conexión:
```bash
flutter devices
```

#### Opción B: Emulador Android
1. Abre Android Studio
2. Ve a **AVD Manager** (Android Virtual Device Manager)
3. Crea o inicia un emulador
4. Verifica que esté activo:
```bash
flutter devices
```

### 5. Ejecutar la Aplicación

#### Desde la Terminal (PowerShell)
```bash
cd \TFG\SmartMealApp
flutter run
```

#### Desde VS Code
1. Abre la carpeta `SmartMealApp` en VS Code
2. Presiona **F5** o usa el botón **Run > Start Debugging**
3. Selecciona el dispositivo si hay varios disponibles

#### Desde Android Studio
1. Abre el proyecto `SmartMealApp`
2. Selecciona el dispositivo en la barra superior
3. Click en el botón **Run** (▶️) o presiona **Shift+F10**

### 6. Hot Reload y Hot Restart

Durante el desarrollo:
- **Hot Reload (r)**: Recarga cambios sin perder el estado
  ```bash
  r
  ```
- **Hot Restart (R)**: Reinicia la app completamente
  ```bash
  R
  ```
- **Quit (q)**: Detiene la aplicación
  ```bash
  q
  ```

## Modos de Compilación

### Debug (Desarrollo)
```bash
flutter run
```
- Incluye logs y herramientas de debugging
- Más lento pero facilita el desarrollo

### Release (Producción)
```bash
flutter run --release
```
- Optimizado para rendimiento
- Sin herramientas de debugging

### Profile (Análisis de Rendimiento)
```bash
flutter run --profile
```
- Para analizar rendimiento con DevTools

## Generar Localización

Si modificas archivos `.arb` en `lib/l10n/`, regenera los archivos de localización:

```bash
flutter gen-l10n
```

O simplemente haz **Hot Restart (R)** en la app en ejecución.

## Compilar APK

Para generar un APK instalable:

```bash
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

## Solución de Problemas

### Error: "No devices found"
- Verifica que el dispositivo/emulador esté conectado: `flutter devices`
- Reinicia el servidor ADB: `adb kill-server && adb start-server`

### Error: "Gradle build failed"
- Limpia el proyecto: `flutter clean`
- Reinstala dependencias: `flutter pub get`
- Sincroniza Gradle en Android Studio

### Error: "Firebase not configured"
- Verifica que `google-services.json` esté en `android/app/`
- Verifica que `firebase_options.dart` exista en `lib/`

### Error de compilación con l10n
- Regenera archivos de localización: `flutter gen-l10n`
- Haz clean y rebuild: `flutter clean && flutter pub get`

### La app no refleja cambios de colores/temas
- Haz **Hot Restart** (R mayúscula) en lugar de Hot Reload (r minúscula)
- Los cambios en `const` requieren restart completo

## Comandos Útiles

| Comando | Descripción |
|---------|-------------|
| `flutter clean` | Limpia archivos temporales de compilación |
| `flutter pub get` | Instala/actualiza dependencias |
| `flutter pub upgrade` | Actualiza dependencias a últimas versiones |
| `flutter doctor` | Verifica configuración de Flutter |
| `flutter devices` | Lista dispositivos conectados |
| `flutter logs` | Muestra logs de la aplicación |
| `flutter analyze` | Analiza código en busca de errores |
| `flutter test` | Ejecuta tests unitarios |

## Estructura del Proyecto

```
SmartMealApp/
├── android/          # Configuración Android
├── assets/           # Imágenes, logos, branding
├── lib/              # Código fuente Dart
│   ├── core/         # Utilidades, DI, servicios
│   ├── data/         # Datasources, modelos, repositories
│   ├── domain/       # Entidades, use cases, contratos
│   ├── presentation/ # UI, widgets, viewmodels
│   └── l10n/         # Archivos de localización
├── test/             # Tests unitarios
└── pubspec.yaml      # Dependencias del proyecto
```

## Credenciales de Prueba

Para probar la aplicación, puedes usar estas credenciales:

**Usuario de prueba:**
- Email: `hugolaroca39@gmail.com`
- Contraseña: *(Proporcionada por separado)*

O crear una nueva cuenta usando el flujo de registro en la app.

## Notas Adicionales

- **Primera ejecución**: La primera compilación puede tardar varios minutos
- **Caché**: Flutter cachea compilaciones para acelerar ejecuciones posteriores
- **DevTools**: Usa `flutter pub global activate devtools` para herramientas avanzadas
- **Logs**: Los logs se muestran en la terminal mientras la app se ejecuta

## Soporte

Si encuentras problemas:
1. Revisa los logs en la terminal
2. Consulta la documentación de Flutter: https://flutter.dev/docs
3. Verifica que todas las dependencias estén actualizadas
4. Contacta al desarrollador: hugolaroca39@gmail.com

# 🧩 SmartMeal – Planificador inteligente de menús

---

## 1️⃣ Descripción general del proyecto

### 🏷️ Nombre tentativo

**SmartMeal – Planificador inteligente de menús**

### 🎯 Objetivo

Desarrollar una aplicación móvil multiplataforma que permita al usuario generar menús semanales equilibrados, crear automáticamente la lista de la compra y recibir recomendaciones de recetas según sus preferencias y restricciones alimenticias.

### 💡 Valor diferencial

* Usa **IA ligera (Kotlin)** para sugerir menús personalizados.
* Sincroniza los datos del usuario en la nube mediante **Firebase Firestore** (modo offline disponible).
* Permite detectar alimentos disponibles escaneando productos o registrando por voz.
* Interfaz moderna, fluida y accesible desarrollada con **Flutter** siguiendo las guías de **Material Design 3**.

---

## 2️⃣ Arquitectura técnica

```
+------------------------------------------------------+
|                     Flutter (Dart)                   |
|        IU moderna, responsive, multiplataforma       |
|          Basada en Material Design 3 (Google)        |
|                                                      |
|  ┌──────────────────────────────────────────────┐     |
|  | MethodChannel: comunicación nativa           |     |
|  |   - Kotlin: IA ligera de recomendación       |     |
|  |   - Kotlin: reconocimiento de voz / imagen   |     |
|  └──────────────────────────────────────────────┘     |
|                                                      |
|                    Firebase Cloud                    |
|      (Firestore, Auth, Storage, sincronización)      |
+------------------------------------------------------+
```

### 🧠 Flujo general MVVM

1. El usuario define preferencias (tipo de dieta, alergias, calorías).
2. La **vista (Flutter)** muestra un menú semanal generado por la **lógica en Kotlin** (ViewModel).
3. El **ViewModel** llama al **repositorio**, que gestiona la conexión con **Firebase Firestore**.
4. La **base de datos** almacena recetas, listas y configuraciones del usuario.
5. La **vista** se actualiza automáticamente al recibir los datos.
6. El usuario puede marcar ingredientes disponibles o pedir sugerencias nuevas.

**Diagrama ASCII simplificado MVVM:**

```
[Vista - Flutter] <--observa-- [ViewModel - Kotlin] <--usa-- [Repositorio - Firebase]
      |                                             ^
      |-- Interacción usuario -->                 |
      v                                             |
[Widgets, Screens]                               [Modelos]
```

---

## 3️⃣ Modelo de datos (Firebase Firestore)

### Colección: usuarios

```json
{
  "id": "u001",
  "nombre": "Hugo",
  "email": "hugo@example.com",
  "preferencias": {
    "tipo_dieta": "omnivora",
    "alergias": ["gluten"],
    "calorias_dia": 2200
  }
}
```

### Colección: menus

```json
{
  "id": "m001",
  "usuario_id": "u001",
  "semana": "2025-W42",
  "dias": [
    {"dia": "Lunes", "comida": "Pasta con verduras", "cena": "Ensalada César"},
    {"dia": "Martes", "comida": "Pollo al horno", "cena": "Sopa de lentejas"}
  ]
}
```

### Colección: lista_compra

```json
{
  "id": "l001",
  "usuario_id": "u001",
  "productos": [
    {"nombre": "Pollo", "cantidad": "500g", "comprado": false},
    {"nombre": "Lechuga", "cantidad": "1 unidad", "comprado": true}
  ]
}
```

### Colección: recetas

```json
{
  "id": "r001",
  "nombre": "Pasta con verduras",
  "ingredientes": ["pasta", "calabacín", "aceite", "ajo"],
  "calorias": 550,
  "tipo": "comida",
  "imagen_url": "https://...",
  "etiquetas": ["vegetariana", "rápida"]
}
```

---

## 4️⃣ Tecnologías y herramientas

| Capa              | Tecnología                      | Propósito                                      |
| ----------------- | ------------------------------- | ---------------------------------------------- |
| Frontend          | Flutter (Dart)                  | UI multiplataforma basada en Material Design 3 |
| Lógica nativa     | Kotlin                          | IA ligera de recomendaciones, voz, imagen      |
| Base de datos     | Firebase Firestore              | Datos de usuario y sincronización en la nube   |
| Autenticación     | Firebase Auth                   | Login con Google/email                         |
| IA ligera         | Kotlin + MLKit / TFLite         | Sugerencias inteligentes y reconocimiento      |
| OCR / voz         | MLKit Vision / SpeechRecognizer | Escanear productos o registrar por voz         |
| Hosting           | Firebase Cloud Storage          | Almacenamiento de imágenes y datos             |
| IDE               | Android Studio / VS Code        | Desarrollo completo                            |
| Control versiones | Git + GitHub                    | Repositorio TFG                                |

**Nota:** Tanto **Google ML Kit** como **TensorFlow Lite** se pueden usar **gratuitamente** para proyectos académicos. ML Kit ofrece reconocimiento de texto, imágenes y voz sin coste cuando se ejecuta en el dispositivo (offline), y TensorFlow Lite permite integrar modelos personalizados locales sin requerir servicios de pago.

---

## 5️⃣ Estructura base del proyecto (recomendada)

```
SmartMeal/
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── menu_screen.dart
│   │   │   └── lista_compra_screen.dart
│   │   ├── services/
│   │   │   ├── firebase_service.dart
│   │   │   └── kotlin_bridge.dart
│   │   ├── models/
│   │   │   ├── usuario.dart
│   │   │   ├── menu.dart
│   │   │   └── receta.dart
│   └── pubspec.yaml
│
├── android_native/
│   ├── app/src/main/java/com/smartmeal/
│   │   ├── IARecomendaciones.kt
│   │   ├── OCRProductos.kt
│   │   └── ConexionFirebase.kt
│
└── README.md
```

---

## 6️⃣ Flujo resumido de la app (Texto)

1. **Usuario** define sus preferencias: tipo de dieta, alergias, calorías.
2. **Flutter UI** solicita un menú semanal al **ViewModel (Kotlin)**.
3. **ViewModel** consulta el **Repositorio**, que maneja Firebase Firestore.
4. **Repositorio** devuelve recetas y lista de compra.
5. **Vista Flutter** se actualiza automáticamente.
6. Usuario marca productos disponibles o solicita nuevas sugerencias.
7. **IA ligera (Kotlin)** ajusta recomendaciones y sugiere cambios según historial y preferencias.

---

## 7️⃣ Usabilidad basada en Material Design 3

Material Design 3 (M3) es el estándar de diseño moderno de Google. Se centra en:

* **Estilo visual coherente:** uso de colores, tipografías y componentes nativos Flutter (botones, tarjetas, diálogos).
* **Accesibilidad:** interfaces claras con alto contraste, texto legible y navegación táctil intuitiva.
* **Consistencia:** todos los elementos visuales siguen el mismo patrón de interacción, garantizando una experiencia fluida y familiar.

Ejemplo de configuración en Flutter:

```dart
theme: ThemeData(
  colorSchemeSeed: Colors.green,
  useMaterial3: true,
)
```

Esto aplica automáticamente los componentes modernos del ecosistema de Google, logrando una interfaz profesional y accesible.

---

## 8️⃣ Valor académico y diferencial

* Separación clara de **responsabilidades con MVVM**, demostrando buenas prácticas en Flutter y Kotlin.
* Uso de **Firebase Firestore** como base de datos NoSQL moderna, sincronizada y multiplataforma.
* Implementación de **IA ligera y OCR** gratuita con **ML Kit** y **TensorFlow Lite**.
* Diseño basado en **Material Design 3**, garantizando accesibilidad y consistencia visual.
* Proyecto escalable y realista para un TFG de **Desarrollo de Aplicaciones Multiplataforma (DAM)**.

> Este documento Markdown sirve como base de tu memoria o README, y puede complementarse con capturas de pantalla de la app, diagramas UML y ejemplos de UI final.

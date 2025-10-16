# 🧩 SmartMeal – Planificador inteligente de menús

---

## 1️⃣ Descripción general del proyecto

### 🏷️ Nombre tentativo

**SmartMeal – Planificador inteligente de menús**

### 🎯 Objetivo

Desarrollar una aplicación móvil multiplataforma que permita al usuario generar menús semanales equilibrados, crear automáticamente la lista de la compra y recibir recomendaciones de recetas según sus preferencias y restricciones alimenticias.

### 💡 Valor diferencial

* Usa **IA ligera (Kotlin)** para sugerir menús personalizados.
* Sincroniza los datos del usuario en la nube mediante **MongoDB Realm** (modo offline disponible).
* Permite detectar alimentos disponibles escaneando productos o registrando por voz.
* Interfaz moderna y fluida desarrollada con **Flutter**.

---

## 2️⃣ Arquitectura técnica

```
+------------------------------------------------------+
|                     Flutter (Dart)                   |
|        IU moderna, responsive, multiplataforma       |
|                                                      |
|  ┌──────────────────────────────────────────────┐     |
|  | MethodChannel: comunicación nativa           |     |
|  |   - Kotlin: IA ligera de recomendación       |     |
|  |   - Kotlin: reconocimiento de voz / imagen   |     |
|  └──────────────────────────────────────────────┘     |
|                                                      |
|                  MongoDB Realm Cloud                 |
|         (Usuarios, menús, recetas, listas)           |
+------------------------------------------------------+
```

### 🧠 Flujo general MVVM

1. El usuario define preferencias (tipo de dieta, alergias, calorías).
2. La **vista (Flutter)** muestra un menú semanal generado por la **lógica en Kotlin** (ViewModel).
3. El **ViewModel** llama al **repositorio**, que gestiona la conexión con **MongoDB Realm**.
4. La **base de datos** almacena recetas, listas y configuraciones del usuario.
5. La **vista** se actualiza automáticamente al recibir los datos.
6. El usuario puede marcar ingredientes disponibles o pedir sugerencias nuevas.

**Diagrama ASCII simplificado MVVM:**

```
[Vista - Flutter] <--observa-- [ViewModel - Kotlin] <--usa-- [Repositorio - MongoDB]
      |                                             ^
      |-- Interacción usuario -->                 |
      v                                             |
[Widgets, Screens]                               [Modelos]
```

---

## 3️⃣ Modelo de datos (MongoDB)

### Colección: usuarios

```json
{
  "_id": "u001",
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
  "_id": "m001",
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
  "_id": "l001",
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
  "_id": "r001",
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

| Capa              | Tecnología                      | Propósito                             |
| ----------------- | ------------------------------- | ------------------------------------- |
| Frontend          | Flutter (Dart)                  | UI multiplataforma, Material Design 3 |
| Lógica nativa     | Kotlin                          | IA de recomendaciones, voz, imagen    |
| Base de datos     | MongoDB Realm                   | Datos de usuario y sincronización     |
| Autenticación     | Firebase Auth / Realm Auth      | Login con Google/email                |
| IA ligera         | Kotlin + MLKit / TFLite         | Sugerencias inteligentes              |
| OCR / voz         | MLKit Vision / SpeechRecognizer | Escanear productos o hablar           |
| Hosting           | MongoDB Atlas                   | Base de datos en la nube              |
| IDE               | Android Studio / VS Code        | Desarrollo completo                   |
| Control versiones | Git + GitHub                    | Repositorio TFG                       |

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
│   │   │   ├── mongo_service.dart
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
│   │   └── ConexionMongo.kt
│
└── README.md
```

---

## 6️⃣ Flujo resumido de la app (Texto)

1. **Usuario** define sus preferencias: tipo de dieta, alergias, calorías.
2. **Flutter UI** solicita un menú semanal al **ViewModel (Kotlin)**.
3. **ViewModel** consulta el **Repositorio**, que maneja MongoDB Realm.
4. **Repositorio** devuelve recetas y lista de compra.
5. **Vista Flutter** se actualiza automáticamente.
6. Usuario marca productos disponibles o solicita nuevas sugerencias.
7. **IA ligera (Kotlin)** ajusta recomendaciones y sugiere cambios según historial y preferencias.

---

## 7️⃣ Valor académico y diferencial

* Separación clara de **responsabilidades con MVVM**, demostrando buenas prácticas en Flutter y Kotlin.
* Uso de **IA ligera y OCR**, mostrando integración nativa con Flutter a través de **MethodChannel**.
* Sincronización **online/offline** con MongoDB Realm, un caso real de aplicaciones multiplataforma.
* Diseño **moderno y adaptable**, ideal para exponer en un TFG de Desarrollo de Aplicaciones Multiplataforma.

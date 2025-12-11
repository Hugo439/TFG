import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreInitService {
  static Future<void> initializePriceDatabase() async {
    final firestore = FirebaseFirestore.instance;

    try {
      if (kDebugMode) {
        print('📊 [FirestoreInit] Inicializando catálogo de precios...');
      }

      // Verificar si ya existe al menos un precio
      final catalogSnapshot = await firestore.collection('price_catalog').limit(1).get();
      if (catalogSnapshot.docs.isNotEmpty) {
        if (kDebugMode) {
          print('✅ [FirestoreInit] Catálogo de precios ya existe');
        }
        return;
      }

      // Crear documentos con precios en price_catalog
      final priceDataMap = {
        // ===== FRUTAS Y VERDURAS =====
        'frutas_verduras': {
          'manzana': {'min': 1.5, 'max': 3.0, 'avg': 2.0, 'unit': 'weight'},
          'platano': {'min': 1.2, 'max': 2.0, 'avg': 1.5, 'unit': 'weight'},
          'naranja': {'min': 1.5, 'max': 2.5, 'avg': 2.0, 'unit': 'weight'},
          'pera': {'min': 2.0, 'max': 3.5, 'avg': 2.5, 'unit': 'weight'},
          'kiwi': {'min': 3.0, 'max': 5.0, 'avg': 4.0, 'unit': 'weight'},
          'fresa': {'min': 4.0, 'max': 8.0, 'avg': 6.0, 'unit': 'weight'},
          'frambuesa': {'min': 8.0, 'max': 12.0, 'avg': 10.0, 'unit': 'weight'},
          'arandano': {'min': 6.0, 'max': 10.0, 'avg': 8.0, 'unit': 'weight'},
          'frutos rojos': {'min': 6.0, 'max': 10.0, 'avg': 8.0, 'unit': 'weight'},
          'mango': {'min': 3.0, 'max': 5.0, 'avg': 4.0, 'unit': 'weight'},
          'aguacate': {'min': 4.0, 'max': 8.0, 'avg': 6.0, 'unit': 'weight'},
          'limon': {'min': 2.0, 'max': 3.5, 'avg': 2.5, 'unit': 'weight'},
          'tomate': {'min': 1.5, 'max': 3.0, 'avg': 2.0, 'unit': 'weight'},
          'cebolla': {'min': 1.0, 'max': 2.0, 'avg': 1.5, 'unit': 'weight'},
          'lechuga': {'min': 1.0, 'max': 2.0, 'avg': 1.5, 'unit': 'weight'},
          'espinaca': {'min': 2.0, 'max': 4.0, 'avg': 3.0, 'unit': 'weight'},
          'brocoli': {'min': 2.0, 'max': 3.5, 'avg': 2.5, 'unit': 'weight'},
          'coliflor': {'min': 2.0, 'max': 3.5, 'avg': 2.5, 'unit': 'weight'},
          'zanahoria': {'min': 1.0, 'max': 2.0, 'avg': 1.5, 'unit': 'weight'},
          'pepino': {'min': 1.5, 'max': 2.5, 'avg': 2.0, 'unit': 'weight'},
          'pimiento': {'min': 2.5, 'max': 4.0, 'avg': 3.0, 'unit': 'weight'},
          'calabacin': {'min': 1.5, 'max': 3.0, 'avg': 2.0, 'unit': 'weight'},
          'berenjena': {'min': 2.0, 'max': 3.5, 'avg': 2.5, 'unit': 'weight'},
          'patata': {'min': 0.8, 'max': 1.5, 'avg': 1.0, 'unit': 'weight'},
          'batata': {'min': 1.5, 'max': 3.0, 'avg': 2.0, 'unit': 'weight'},
          'boniato': {'min': 1.5, 'max': 3.0, 'avg': 2.0, 'unit': 'weight'},
          'calabaza': {'min': 1.0, 'max': 2.0, 'avg': 1.5, 'unit': 'weight'},
          'champiñon': {'min': 4.0, 'max': 6.0, 'avg': 5.0, 'unit': 'weight'},
          'apio': {'min': 1.5, 'max': 2.5, 'avg': 2.0, 'unit': 'weight'},
          'esparrag': {'min': 6.0, 'max': 10.0, 'avg': 8.0, 'unit': 'weight'},
        },

        // ===== CARNES Y PESCADOS =====
        'carnes_pescados': {
          'pollo': {'min': 5.0, 'max': 8.0, 'avg': 6.5, 'unit': 'weight'},
          'pavo': {'min': 6.0, 'max': 9.0, 'avg': 7.5, 'unit': 'weight'},
          'carne res': {'min': 10.0, 'max': 20.0, 'avg': 15.0, 'unit': 'weight'},
          'cerdo': {'min': 6.0, 'max': 12.0, 'avg': 9.0, 'unit': 'weight'},
          'cordero': {'min': 12.0, 'max': 20.0, 'avg': 16.0, 'unit': 'weight'},
          'chorizo': {'min': 8.0, 'max': 15.0, 'avg': 12.0, 'unit': 'weight'},
          'bacon': {'min': 10.0, 'max': 15.0, 'avg': 12.5, 'unit': 'weight'},
          'salmon': {'min': 12.0, 'max': 25.0, 'avg': 18.0, 'unit': 'weight'},
          'merluza': {'min': 8.0, 'max': 15.0, 'avg': 12.0, 'unit': 'weight'},
          'bacalao': {'min': 15.0, 'max': 25.0, 'avg': 20.0, 'unit': 'weight'},
          'atun': {'min': 10.0, 'max': 20.0, 'avg': 15.0, 'unit': 'weight'},
          'gambas': {'min': 15.0, 'max': 30.0, 'avg': 22.0, 'unit': 'weight'},
          'langostinos': {'min': 18.0, 'max': 35.0, 'avg': 25.0, 'unit': 'weight'},
          'huevo': {'min': 0.15, 'max': 0.35, 'avg': 0.25, 'unit': 'piece'},
        },

        // ===== LÁCTEOS =====
        'lacteos': {
          'leche': {'min': 0.7, 'max': 1.5, 'avg': 1.0, 'unit': 'liter'},
          'yogur': {'min': 2.0, 'max': 5.0, 'avg': 3.5, 'unit': 'weight'},
          'yogur griego': {'min': 3.0, 'max': 6.0, 'avg': 4.5, 'unit': 'weight'},
          'queso': {'min': 8.0, 'max': 20.0, 'avg': 12.0, 'unit': 'weight'},
          'queso fresco': {'min': 6.0, 'max': 12.0, 'avg': 9.0, 'unit': 'weight'},
          'feta': {'min': 8.0, 'max': 15.0, 'avg': 12.0, 'unit': 'weight'},
          'queso parmesano': {'min': 15.0, 'max': 25.0, 'avg': 20.0, 'unit': 'weight'},
          'queso mozzarella': {'min': 8.0, 'max': 15.0, 'avg': 12.0, 'unit': 'weight'},
          'requeson': {'min': 5.0, 'max': 10.0, 'avg': 7.5, 'unit': 'weight'},
          'mantequilla': {'min': 6.0, 'max': 12.0, 'avg': 9.0, 'unit': 'weight'},
          'leche almendras': {'min': 1.5, 'max': 3.5, 'avg': 2.5, 'unit': 'liter'},
          'leche coco': {'min': 2.0, 'max': 4.0, 'avg': 3.0, 'unit': 'liter'},
          'leche soja': {'min': 1.2, 'max': 3.0, 'avg': 2.0, 'unit': 'liter'},
        },

        // ===== ACEITES Y CONDIMENTOS =====
        'otros': {
          'aceite oliva': {'min': 4.0, 'max': 8.0, 'avg': 6.0, 'unit': 'liter'},
          'aceite sesamo': {'min': 8.0, 'max': 15.0, 'avg': 12.0, 'unit': 'liter'},
          'aceite coco': {'min': 10.0, 'max': 18.0, 'avg': 14.0, 'unit': 'liter'},
          'vinagre': {'min': 1.5, 'max': 4.0, 'avg': 2.5, 'unit': 'liter'},
          'salsa soja': {'min': 2.0, 'max': 5.0, 'avg': 3.5, 'unit': 'liter'},
          'mostaza': {'min': 2.0, 'max': 5.0, 'avg': 3.5, 'unit': 'weight'},
          'sal': {'min': 0.5, 'max': 2.0, 'avg': 1.0, 'unit': 'weight'},
          'pimienta': {'min': 5.0, 'max': 15.0, 'avg': 10.0, 'unit': 'weight'},
          'arroz': {'min': 1.0, 'max': 3.0, 'avg': 2.0, 'unit': 'weight'},
          'arroz integral': {'min': 1.5, 'max': 4.0, 'avg': 2.5, 'unit': 'weight'},
          'arroz basmati': {'min': 2.0, 'max': 5.0, 'avg': 3.5, 'unit': 'weight'},
          'pasta': {'min': 1.0, 'max': 3.0, 'avg': 2.0, 'unit': 'weight'},
          'pasta integral': {'min': 1.5, 'max': 4.0, 'avg': 2.5, 'unit': 'weight'},
          'quinoa': {'min': 5.0, 'max': 10.0, 'avg': 7.5, 'unit': 'weight'},
          'cuscus': {'min': 2.0, 'max': 4.0, 'avg': 3.0, 'unit': 'weight'},
          'avena': {'min': 2.0, 'max': 4.0, 'avg': 3.0, 'unit': 'weight'},
          'lentejas': {'min': 1.5, 'max': 3.0, 'avg': 2.0, 'unit': 'weight'},
          'garbanzos': {'min': 1.5, 'max': 3.0, 'avg': 2.0, 'unit': 'weight'},
          'frijol negro': {'min': 2.0, 'max': 4.0, 'avg': 3.0, 'unit': 'weight'},
          'almendra': {'min': 8.0, 'max': 15.0, 'avg': 12.0, 'unit': 'weight'},
          'nuez': {'min': 10.0, 'max': 18.0, 'avg': 14.0, 'unit': 'weight'},
          'anacardo': {'min': 12.0, 'max': 20.0, 'avg': 16.0, 'unit': 'weight'},
          'pistacho': {'min': 15.0, 'max': 25.0, 'avg': 20.0, 'unit': 'weight'},
          'pasa': {'min': 4.0, 'max': 8.0, 'avg': 6.0, 'unit': 'weight'},
          'semillas chia': {'min': 8.0, 'max': 15.0, 'avg': 12.0, 'unit': 'weight'},
          'semillas girasol': {'min': 3.0, 'max': 6.0, 'avg': 4.5, 'unit': 'weight'},
          'semillas calabaza': {'min': 5.0, 'max': 10.0, 'avg': 7.5, 'unit': 'weight'},
          'tofu': {'min': 6.0, 'max': 12.0, 'avg': 9.0, 'unit': 'weight'},
          'tempeh': {'min': 8.0, 'max': 15.0, 'avg': 12.0, 'unit': 'weight'},
          'hummus': {'min': 4.0, 'max': 8.0, 'avg': 6.0, 'unit': 'weight'},
          'falafel': {'min': 5.0, 'max': 10.0, 'avg': 7.5, 'unit': 'weight'},
          'miel': {'min': 8.0, 'max': 20.0, 'avg': 14.0, 'unit': 'weight'},
          'sirope arce': {'min': 10.0, 'max': 25.0, 'avg': 18.0, 'unit': 'weight'},
          'proteina suero': {'min': 15.0, 'max': 40.0, 'avg': 25.0, 'unit': 'weight'},
          'mantequilla cacahuete': {'min': 4.0, 'max': 10.0, 'avg': 7.0, 'unit': 'weight'},
          'pesto': {'min': 6.0, 'max': 12.0, 'avg': 9.0, 'unit': 'weight'},
          'pasta curry': {'min': 4.0, 'max': 8.0, 'avg': 6.0, 'unit': 'weight'},
        },

        // ===== PANADERÍA =====
        'panaderia': {
          'pan': {'min': 0.5, 'max': 2.0, 'avg': 1.0, 'unit': 'piece'},
          'tortilla': {'min': 0.3, 'max': 0.8, 'avg': 0.5, 'unit': 'piece'},
          'granola': {'min': 6.0, 'max': 12.0, 'avg': 9.0, 'unit': 'weight'},
        },

        // ===== BEBIDAS =====
        'bebidas': {
          'agua': {'min': 0.3, 'max': 1.0, 'avg': 0.5, 'unit': 'liter'},
          'zumo': {'min': 1.5, 'max': 3.0, 'avg': 2.0, 'unit': 'liter'},
          'cafe': {'min': 6.0, 'max': 15.0, 'avg': 10.0, 'unit': 'weight'},
          'te': {'min': 3.0, 'max': 8.0, 'avg': 5.0, 'unit': 'weight'},
        },

        // ===== SNACKS =====
        'snacks': {
          'almendra': {'min': 8.0, 'max': 15.0, 'avg': 12.0, 'unit': 'weight'},
          'nuez': {'min': 10.0, 'max': 18.0, 'avg': 14.0, 'unit': 'weight'},
          'chocolate': {'min': 5.0, 'max': 15.0, 'avg': 10.0, 'unit': 'weight'},
          'galleta': {'min': 3.0, 'max': 8.0, 'avg': 5.0, 'unit': 'weight'},
        },
      };

      // Transformar estructura para price_catalog
      // Cada ingrediente será un documento con su categoría
      final batch = firestore.batch();
      priceDataMap.forEach((category, ingredients) {
        (ingredients as Map<String, dynamic>).forEach((ingredientName, priceData) {
          final docId = ingredientName.toLowerCase().replaceAll(' ', '_');
          final docRef = firestore.collection('price_catalog').doc(docId);
          
          batch.set(docRef, {
            'normalizedName': docId,
            'displayName': ingredientName,
            'category': category,
            'priceRef': ((priceData as Map<String, dynamic>)['avg'] as num).toDouble(),
            'unitKind': _convertUnitKind(priceData['unit'] as String?),
            'brand': 'Genérico',
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
      });
      
      await batch.commit();

      if (kDebugMode) {
        print('✅ [FirestoreInit] Catálogo de precios creado exitosamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [FirestoreInit] Error inicializando precios: $e');
      }
      rethrow;
    }
  }

  static String _convertUnitKind(String? oldUnit) {
    switch (oldUnit?.toLowerCase()) {
      case 'liter':
        return 'volume';
      case 'piece':
        return 'unit';
      case 'weight':
        return 'weight';
      default:
        return 'weight';
    }
  }
}
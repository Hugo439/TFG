import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> guardarPrueba() async {
    await _db.collection('pruebas').doc('test1').set({
      'mensaje': 'Hola desde Flutter 🚀',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> leerPrueba() async {
    final doc = await _db.collection('pruebas').doc('test1').get();
    return doc.data()?['mensaje'] ?? 'Sin datos';
  }
}

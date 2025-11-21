import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ShoppingDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> getShoppingItems() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shoppingItems')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  Future<void> addShoppingItem(String id, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shoppingItems')
        .doc(id)
        .set(data);
  }

  Future<void> updateShoppingItem(String id, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shoppingItems')
        .doc(id)
        .update(data);
  }

  Future<void> deleteShoppingItem(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shoppingItems')
        .doc(id)
        .delete();
  }

  Future<void> clearCheckedItems() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shoppingItems')
        .where('isChecked', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
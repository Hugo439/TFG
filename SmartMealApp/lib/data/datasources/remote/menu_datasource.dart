import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MenuDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> getMenuItems() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('menuItems')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getRecommendedMenuItems(int limit) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('menuItems')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getMenuItem(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('menuItems')
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return {
      'id': doc.id,
      ...doc.data()!,
    };
  }

  Future<void> createMenuItem(String id, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('menuItems')
        .doc(id)
        .set(data);
  }

  Future<void> updateMenuItem(String id, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('menuItems')
        .doc(id)
        .update(data);
  }

  Future<void> deleteMenuItem(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('menuItems')
        .doc(id)
        .delete();
  }
}
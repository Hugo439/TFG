import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDataSource {
  final FirebaseFirestore _firestore;

  FirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data);
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> deleteUserProfile(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}
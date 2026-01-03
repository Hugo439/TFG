import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmeal/core/constants/app_constants.dart'; //TODO: probar

class FirestoreDataSource {
  final FirebaseFirestore _firestore;
  final String usersCollection = AppConstants.usersCollection;

  FirestoreDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection(usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(usersCollection).doc(uid).set(data);
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(usersCollection).doc(uid).update(data);
  }

  Future<void> deleteUserProfile(String uid) async {
    await _firestore.collection(usersCollection).doc(uid).delete();
  }

  Future<void> saveFCMToken(String uid, String token) async {
    await _firestore.collection(usersCollection).doc(uid).update({'fcmToken': token});
  }
}

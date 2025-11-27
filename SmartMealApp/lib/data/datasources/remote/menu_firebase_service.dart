import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/recipe_model.dart';
import '../../models/weekly_menu_model.dart';

class MenuFirebaseService {
  // final FirebaseFirestore _firestore;

  // MenuFirebaseService({FirebaseFirestore? firestore})
  //     : _firestore = firestore ?? FirebaseFirestore.instance;

  // Future<String> saveRecipe(String userId, RecipeModel recipe) async {
  //   final docRef = await _firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('recipes')
  //       .add(recipe.toJson());
  //   return docRef.id;
  // }

  // Future<void> saveWeeklyMenu(String userId, WeeklyMenuModel menu) async {
  //   await _firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('weekly_menus')
  //       .doc(menu.id)
  //       .set(menu.toJson());
  // }

  // Future<WeeklyMenuModel?> getLastWeeklyMenu(String userId) async {
  //   final snapshot = await _firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('weekly_menus')
  //       .orderBy('createdAt', descending: true)
  //       .limit(1)
  //       .get();
  //   if (snapshot.docs.isEmpty) return null;
  //   final doc = snapshot.docs.first;
  //   return WeeklyMenuModel.fromJson(doc.data());
  // }
}
//TODO: no se usa
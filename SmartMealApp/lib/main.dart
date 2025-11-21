import 'package:flutter/material.dart';
import 'presentation/app/smart_meal_app.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const SmartMealApp());
}
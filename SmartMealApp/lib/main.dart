import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'presentation/app/smart_meal_app.dart';
import 'core/di/service_locator.dart';
import 'package:provider/provider.dart';
import 'domain/usecases/support/get_support_messages_usecase.dart';
import 'domain/repositories/support_message_repository.dart';
import 'core/services/fcm_service.dart';
import 'presentation/features/menu/viewmodel/menu_view_model.dart';
import 'package:smartmeal/core/services/firestore_init_service.dart';
import 'dart:async' show unawaited;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupServiceLocator();

  unawaited(FirestoreInitService.initializePriceDatabase());

  await FirebaseMessaging.instance.requestPermission();

  // Inicializar FCM y cargar menús cuando hay un usuario autenticado
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      sl<FCMService>().initialize();
      // Cargar menús automáticamente al autenticarse
      sl<MenuViewModel>().loadWeeklyMenus(user.uid);
    }
  });

  runApp(
    MultiProvider(
      providers: [
        // Providers globales
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        Provider<GetSupportMessagesUseCase>(
          create: (_) => sl<GetSupportMessagesUseCase>(),
        ),
        Provider<SupportMessageRepository>(
          create: (_) => sl<SupportMessageRepository>(),
        ),
      ],
      child: const SmartMealApp(),
    ),
  );
}
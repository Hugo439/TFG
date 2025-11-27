import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'presentation/app/smart_meal_app.dart';
import 'core/di/service_locator.dart';
import 'package:provider/provider.dart';
import 'domain/usecases/get_support_messages_usecase.dart';
import 'domain/repositories/support_message_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupServiceLocator();
  runApp(
    MultiProvider(
      providers: [
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